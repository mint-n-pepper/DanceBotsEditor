#include "AudioFile.hpp"

#include <lame.h>
#include <QDataStream>
#include <sndfile.h>

// typedef sample_t to be able to include encoder.h that contains the en-/decoder
// delay defines
typedef float sample_t;
#include <encoder.h>

// class constants:
const QByteArray AudioFile::kDanceFileHeaderCode("DancebotsDancefile");
const double AudioFile::kMusicRMSTarget = 0.2f;

extern "C" {
  static void lame_print_f(const char* format, va_list ap) {
    return;
  }
}

AudioFile::AudioFile(const QString file_path)
  : path_(file_path) {

  // check if file exists:
  QFile file{ path_ };

  if (!file.exists()) {
    status_ = FileStatus::kFileDoesNotExist;
    return;
  }

  // the file exists, so load it:
  file.open(QIODevice::ReadOnly);

  // read file header to detect a dancefile
  const QByteArray header = file.read(kDanceFileHeaderCode.size());
  // TODO: Search further into the file for header in case user re-tagged and
  // a tag was written at the head of the file
  if (kDanceFileHeaderCode == header) {
    // check number of bytes in header data:
    const QByteArray header_n_data = file.read(kHeaderSizeNBytes);

    if (header_n_data.size() < kHeaderSizeNBytes) {
      status_ = FileStatus::kCorruptHeader;
      return;
    }

    const unsigned char* size_data = reinterpret_cast<const unsigned char*>(
      header_n_data.data());

    QDataStream n_data_str(header_n_data);
    n_data_str.setByteOrder(QDataStream::LittleEndian);
    quint32 n_data;
    n_data_str >> n_data;

    // verify that n_data is shorter than the file is long:
    if (file.pos() + n_data > file.size()) {
      status_ = FileStatus::kCorruptHeader;
      return;
    }

    // otherwise read header data:
    mp3_prepend_data_ = file.read(n_data);

    // ensure that the header is valid:
    const QByteArray header_end = file.read(kDanceFileHeaderCode.size());
    if (kDanceFileHeaderCode == header_end) {
      is_dancefile_ = true;
    }
    else {
      status_ = FileStatus::kCorruptHeader;
      return;
    }
  }

  // rewind file if it is not a dancefile but a regular mp3:
  if (!is_dancefile_) {
    file.seek(0);
  }

  // allocate space for mp3 data:
  raw_mp3_data_.resize(file.size() - file.pos());
  // and read it
  size_t n_read = file.read(raw_mp3_data_.data(), file.size() - file.pos());
  // ensure all is read:
  if (n_read < file.size() - file.pos()) {
    status_ = FileStatus::kIOError;
    return;
  }

  // read out the MP3 Tags:
  if (ReadTag()) {
    // the file is not an mp3 / mpeg file
    status_ = FileStatus::kNotAnMP3File;
    return;
  };

  // decode the MP3 data
  if (Decode() < 0) {
    // if Decode returns -1, there was a decoding error:
    status_ = FileStatus::kMP3DecodingError;
    return;
  };

  status_ = FileStatus::kOk;
}

void AudioFile::Save(const QString file)
{
  // 1. Encode MP3, 2. Write TAG info, 3. write to file with header pre-pend
  if (LameEncCodes::kEncodeSuccess != Encode()) {
    status_ = FileStatus::kMP3EncodingError;
    return;
  }

  // write tag info:
  if (WriteTag()) {
    // something went wrong with writing the tag
    status_ = FileStatus::kTagWriteError;
    return;
  }

  // otherwise save:
  QFile out_file(file);

  out_file.open(QIODevice::WriteOnly);

  // write header data:
  out_file.write(kDanceFileHeaderCode);

  // serialize header length to file:
  const quint32 kHeaderLength = mp3_prepend_data_.size();
  QByteArray size_bytes;
  QDataStream size_bytes_str(&size_bytes, QIODevice::WriteOnly);
  size_bytes_str.setByteOrder(QDataStream::LittleEndian);
  size_bytes_str << kHeaderLength;
  out_file.write( size_bytes);

  // write prepend data and finish with the header code again:
  out_file.write(mp3_prepend_data_);
  out_file.write(kDanceFileHeaderCode);

  // and, finally, add the mp3 data
  const auto end = raw_mp3_data_.end();
  auto data_it = raw_mp3_data_.begin();
  const size_t kWriteStep = 50 * 1024; // 50kb write step
  
  while (data_it != end) {
    size_t dist_to_end = std::distance(data_it, end);
    size_t n_feed = kWriteStep > dist_to_end ? dist_to_end : kWriteStep;

    out_file.write(&*data_it, n_feed);

    data_it += n_feed;
  }

  out_file.close();

}

int AudioFile::ReadTag(void) {
  // Setup 
  auto tag_frame_factory = TagLib::ID3v2::FrameFactory::instance();
  TagLib::ByteVectorStream bvs{ raw_mp3_data_ };
  TagLib::MPEG::File mpeg_file(&bvs,
                               tag_frame_factory,
                               true,
                               TagLib::AudioProperties::Accurate);

  // read out audio properties:
  auto audio_properties = mpeg_file.audioProperties();

  if (nullptr == audio_properties) {
    return 1;
  }

  // read sampling rate:
  sample_rate_ = audio_properties->sampleRate();
  length_ms_ = audio_properties->lengthInMilliseconds();

  // read mp3 song info:
  auto tag = mpeg_file.tag();

  if (!tag->artist().isNull()) {
    artist_ = tag->artist().to8Bit(true);
  }

  if (!tag->title().isNull()) {
    title_ = tag->title().to8Bit(true);
  }

  return 0;
}

int AudioFile::WriteTag(void)
{
  // Setup 
  auto tag_frame_factory = TagLib::ID3v2::FrameFactory::instance();
  
  // the byte vector stream for the MPEG file object copies the byte vector
  // since we want to operate on the raw mp3 data in the file's bytevector
  // create empty dummy to pass to the stream, swap its bytevector with the
  // file's mp3 data, and then swap back after adding a tag
  TagLib::ByteVector dummy;
  TagLib::ByteVectorStream bvs{ dummy };

  // swap in the file's byte-vector:
  bvs.data()->swap(raw_mp3_data_);

  TagLib::MPEG::File mpeg_file(&bvs,
                               tag_frame_factory,
                               true,
                               TagLib::AudioProperties::Accurate);

  // get the ID3V2 tag and set its fields according to data in file:
  auto tag = mpeg_file.ID3v2Tag(true);
  tag->setArtist(TagLib::String(artist_));
  tag->setTitle(TagLib::String(title_));
  tag->setComment("Music for Dancebots, not Humans");

  // save the tag to the data
  if (mpeg_file.save()) {
    // swap data back to raw mp3 data:
    raw_mp3_data_.swap(*bvs.data());
    return 0;
  }
  else {
    // saving failed
    return 1;
  }

}

int AudioFile::Decode(void)
{
  // estimate number of samples and reserve enough data in pcm vector
  // add 1 to ms in case it is rounded down (as s is in documentation)
  const size_t kNSamples = sample_rate_ * (length_ms_ + 1) / 1000;
  pcm_music_.reserve(kNSamples);
  pcm_data_.reserve(kNSamples);
  float_music_.reserve(kNSamples);

  const size_t kDecodeStepSize = 4096;

  // prep pcm buffers - TODO: Make the buffer size a function of the decode size
  // step if possible
  const size_t kPCMBufSize = 200000u;

  std::vector<qint16> pcm_l_buf;
  pcm_l_buf.resize(kPCMBufSize);
  std::vector<qint16> pcm_r_buf;
  pcm_r_buf.resize(kPCMBufSize);

  // decode the MP3 data into PCM data:
  hip_t dc_gfp = hip_decode_init();
  lame_report_function dummy_report_fun = &lame_print_f;
  hip_set_errorf(dc_gfp, dummy_report_fun);
  hip_set_debugf(dc_gfp, dummy_report_fun);
  hip_set_msgf(dc_gfp, dummy_report_fun);

  auto end = raw_mp3_data_.end();
  auto buf = raw_mp3_data_.begin();

  // Number of samples to cut from beginning that stem from encoder and decoder
  // delays

  const size_t N_SKIP = ENCDELAY + DECDELAY + 1;
  size_t skip_count = 0;

  while (buf != end) {
    size_t dist_to_end = std::distance(buf, end);
    size_t n_feed = kDecodeStepSize > dist_to_end ? dist_to_end : kDecodeStepSize;
    int n_read = hip_decode(dc_gfp,
                            reinterpret_cast<unsigned char*>(&*buf),
                            n_feed,
                            pcm_l_buf.data(),
                            pcm_r_buf.data());

    if (n_read) {
      if (n_read < 0) {
        return -1;
      }

      // read pcm data based on whether it is a dancefile or not
      if (!is_dancefile_) {
        for (size_t i = 0; i < n_read; ++i) {
          qint32 average = (static_cast<qint32>(pcm_l_buf[i]) + pcm_r_buf[i]) / 2;
          pcm_music_.push_back(static_cast<qint16>(average));
        }
      }
      else {
        // only consider left channel
        for (size_t i = 0; i < n_read; ++i) {
          if (skip_count < N_SKIP) {
            ++skip_count;
            continue;
          }
          pcm_music_.push_back(pcm_l_buf[i]);
        }
      }
    }
    buf += n_feed;
  }

  std::cout << "decoded " << pcm_music_.size() << " samples" << std::endl;

  // cut off extra sample block at end:
  if (is_dancefile_) {
    pcm_music_.resize(pcm_music_.size() - kMP3BlockSize);
  }
  // resize data to same length:
  pcm_data_.resize(pcm_music_.size());

  // calculate rms of music pcm data:
  quint64 sum = 0u;

  for (auto s : pcm_music_) {
    sum += static_cast<quint64>((static_cast<qint64>(s)
                                * static_cast<qint64>(s)));
  }

  quint64 average = sum / pcm_music_.size();

  const double target_average = kMusicRMSTarget * kMusicRMSTarget
    * static_cast<double>(MINSHORT) * static_cast<double>(MINSHORT);

  mp3_music_gain_ = sqrt(target_average / average);

  hip_decode_exit(dc_gfp);
  return 0;
}

auto AudioFile::Encode(void) -> LameEncCodes
{
  // in order to encode, both pcm buffers need to be non-empty
  // and of the same length:
  if (!pcm_data_.size()) {
    return LameEncCodes::kNoPCMData;
  }
  if (pcm_data_.size() != pcm_music_.size()) {
    return LameEncCodes::kPCMDataNotSameLength;
  }
  
  lame_t gfp;
  gfp = lame_init();
  lame_set_mode(gfp, STEREO);
  lame_set_quality(gfp, kMP3Quality);
  lame_set_in_samplerate(gfp, kSampleRate);
  lame_set_brate(gfp, kBitRateKB);
  lame_set_out_samplerate(gfp, kSampleRate);
  lame_set_bWriteVbrTag(gfp, 1);
  lame_set_VBR(gfp, vbr_off);
  lame_set_scale_left(gfp, static_cast<float>(mp3_music_gain_));

  lame_report_function dummy_report_fun = &lame_print_f;
  lame_set_errorf(gfp, dummy_report_fun);
  lame_set_debugf(gfp, dummy_report_fun);
  lame_set_msgf(gfp, dummy_report_fun);

  if (0 > lame_init_params(gfp)) {
    lame_close(gfp);
    return LameEncCodes::kLameInitFailed;
  }

  // resize pcm data to integer multiple of mp3 block size:
  const size_t kNBlocks = (pcm_music_.size() / kMP3BlockSize) + 1;
  pcm_music_.resize(kNBlocks * kMP3BlockSize, 0); // w. zero padding
  pcm_data_.resize(kNBlocks * kMP3BlockSize, 0);
  
  // create temporary mp3 data ByteVector:
  TagLib::ByteVector temp_mp3;
  const size_t kTempMP3Size = pcm_data_.size() * kBitRateKB * 1'000 / kSampleRate 
                              + 50'000;
  temp_mp3.resize(kTempMP3Size);

  const size_t kPCMEncodeStepSize = 40 * kMP3BlockSize;
  const size_t kMP3BufferSize = static_cast<size_t>(kPCMEncodeStepSize * 1.25
                                                    + 7200.0);

  std::vector<unsigned char> encode_buffer;
  encode_buffer.resize(kMP3BufferSize);

  const auto music_end = pcm_music_.end();
  auto music_it = pcm_music_.begin();
  auto data_it = pcm_data_.begin();

  auto mp3_out_it = temp_mp3.begin();

  while (music_it != music_end) {
    size_t dist_to_end = std::distance(music_it, music_end);
    size_t n_feed = kPCMEncodeStepSize > dist_to_end ?
      dist_to_end : kPCMEncodeStepSize;

    int n_encode = lame_encode_buffer(gfp, &*music_it, &*data_it, n_feed,
                       encode_buffer.data(), kMP3BufferSize);

    if (n_encode) {
      if (n_encode < 0) {
        // cast the return error code to the enum class return type
        return static_cast<LameEncCodes>(n_encode);
      }
      // otherwise, copy the buffer to the temp mp3 data:
      size_t pre = std::distance(temp_mp3.begin(), mp3_out_it);
      std::copy(encode_buffer.begin(),
                encode_buffer.begin() + n_encode,
                mp3_out_it);
      size_t post = std::distance(temp_mp3.begin(), mp3_out_it);
      mp3_out_it += n_encode;
    }
    music_it += n_feed;
    data_it += n_feed;
  }

  std::cout << "encoded " << std::distance(pcm_music_.begin(), music_it) << " samples" << std::endl;

  // flush lame buffers:
  const int n_flush = lame_encode_flush(gfp, encode_buffer.data(), kMP3BufferSize);
  if (n_flush > 0) {
    std::copy(encode_buffer.begin(), encode_buffer.begin() + n_flush, mp3_out_it);
    mp3_out_it += n_flush;
  }

  // get lame tag:
  const size_t tag_size = lame_get_lametag_frame(gfp,
                                                 encode_buffer.data(),
                                                 kMP3BufferSize);

  // and copy it to the first frame:
  std::copy(encode_buffer.begin(),
            encode_buffer.begin() + tag_size,
            temp_mp3.begin());

  // if all went well, truncate temp mp3 to number of bytes written
  const size_t n_bytes_out = std::distance(temp_mp3.begin(), mp3_out_it);
  temp_mp3.resize(n_bytes_out);

  // and swap it into the raw_mp3 data:
  raw_mp3_data_.swap(temp_mp3);

  std::cout << "N MP3 Encode bytes written = " << n_bytes_out << std::endl;

  lame_close(gfp);
  return LameEncCodes::kEncodeSuccess;
}

int AudioFile::SavePCM(const QString file) {

  SF_INFO out_format;
  out_format.channels = 2;
  out_format.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;
  out_format.samplerate = 44100;

  // otherwise save:
  SNDFILE* snd_file = sf_open(file.toStdString().c_str(), SFM_WRITE, &out_format);

  if (!snd_file) {
    // opening failed, return:
    return 1;
  }

  // prepare write buffer for stereo file:
  std::vector<qint16> write_buf;
  write_buf.reserve(2 * pcm_data_.size());
  
  for (size_t i = 0; i < pcm_data_.size(); ++i) {
    write_buf.push_back(pcm_music_[i]);
    write_buf.push_back(pcm_data_[i]);
  }

  sf_count_t n_write = sf_write_short(snd_file,
                                      write_buf.data(),
                                      write_buf.size());
  sf_write_sync(snd_file);
  // close the file
  sf_close(snd_file);
  return 0;
}