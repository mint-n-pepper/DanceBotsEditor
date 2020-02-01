/*
 *  Dancebots GUI - Create choreographies for Dancebots
 *  https://github.com/philippReist/dancebots_gui
 *
 *  Copyright 2020 - mint & pepper
 *
 *  This program is free software : you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 *  See the GNU General Public License for more details, available in the
 *  LICENSE file included in the repository.
 */

#include "src/audio_file.h"
// typedef sample_t to include encoder.h that contains the en-/decoder
// delay defines
typedef float sample_t;
#include <encoder.h>
#include <lame.h>
#include <limits.h>
#include <sndfile.h>

#include <algorithm>
#include <cmath>

#include "dsp/rateconversion/Resampler.h"

// class constants:
const QByteArray AudioFile::danceFileHeaderCode("DancebotsDancefile");
const double AudioFile::musicRMSTarget = 0.16f;

// Dummy reporting function for Lame
extern "C" {
static void lame_print_f(const char* format, va_list ap) { return; }
}

// Constructor, empty
AudioFile::AudioFile(void) {}

auto AudioFile::load(const QString filePath) -> Result {
  // check if file exists:
  QFile file{filePath};

  if (!file.exists()) {
    return Result::FileDoesNotExist;
  }

  // the file exists, so open it:
  file.open(QIODevice::ReadOnly);

  // find header code:
  size_t headerInd = findHeaderCode(&file);
  // and seek to the position - if there is no header, the end of the file is
  // seeked, and the header compare below will fail
  file.seek(headerInd);

  // read file header to detect a dancefile
  const QByteArray header = file.read(danceFileHeaderCode.size());

  // check if a valid header is present
  if (danceFileHeaderCode == header) {
    // check number of bytes in header data:
    const QByteArray headerNData = file.read(headerSizeNBytes);

    // check if we could read all header-size bytes:
    if (headerNData.size() < headerSizeNBytes) {
      // could not read them, header "corrupt", i.e file ends prematurely
      return Result::CorruptHeader;
    }

    // convert size bytes to size int nData
    QDataStream nDataStream(headerNData);
    applyDataStreamSettings(&nDataStream);
    quint32 nData;
    nDataStream >> nData;

    // verify that nData is shorter than the file is long:
    if (file.pos() + nData > file.size()) {
      // file is too small to contain header size as given in nData
      return Result::CorruptHeader;
    }

    // at this point the data will be loaded and we purge any exising data
    clear();
    // store file path
    mPath = filePath;

    // Read header data:
    mMP3PrependData = file.read(nData);

    // ensure that the header is valid by checking header code at end of
    // header
    const QByteArray headerEnd = file.read(danceFileHeaderCode.size());
    if (danceFileHeaderCode == headerEnd) {
      // code match
      mIsDanceFile = true;
    } else {
      // code mismatch, report corrupt header
      clear();
      return Result::CorruptHeader;
    }
  } else {
    // the header is not equal to the dancefile code
    mIsDanceFile = false;
  }

  // rewind file if it is not a dancefile but a regular mp3:
  if (!mIsDanceFile) {
    file.seek(0);
  }

  // allocate space for mp3 data:
  mRawMP3Data.resize(file.size() - file.pos());
  // and read it
  size_t nRead = file.read(mRawMP3Data.data(), file.size() - file.pos());
  // ensure all is read:
  if (nRead < file.size() - file.pos()) {
    clear();
    return Result::IOError;
  }

  // read out the MP3 Tags:
  if (readTag()) {
    // the file is not an mp3 / mpeg file
    clear();
    return Result::NotAnMP3File;
  }

  // decode the MP3 data
  if (decode() < 0) {
    // if decode returns -1, there was a decoding error
    clear();
    return Result::MP3DecodingError;
  }

  mHasData = true;
  return Result::Success;
  // do not need to close the file as the QFile destructor will take care of it
}

auto AudioFile::save(const QString file) -> Result {
  // ensure there is data available:
  if (!mHasData) {
    return Result::NoDataToSave;
  }

  // 1. encode MP3, 2. Write TAG info, 3. write to file with header pre-pend
  if (LameEncCodes::EncodeSuccess != encode()) {
    return Result::MP3EncodingError;
  }

  // write tag info:
  if (writeTag()) {
    // something went wrong with writing the tag
    return Result::TagWriteError;
  }

  // otherwise save:
  QFile outFile(file);

  if (!outFile.open(QIODevice::WriteOnly)) {
    return Result::FileOpenError;
  }

  // write header data:
  outFile.write(danceFileHeaderCode);

  // serialize header length to file:
  const quint32 kHeaderLength = mMP3PrependData.size();
  QByteArray sizeBytes;
  QDataStream sizeBytesStream(&sizeBytes, QIODevice::WriteOnly);
  applyDataStreamSettings(&sizeBytesStream);

  sizeBytesStream << kHeaderLength;
  outFile.write(sizeBytes);

  // write prepend data and finish with the header code again:
  outFile.write(mMP3PrependData);
  outFile.write(danceFileHeaderCode);

  // and, finally, add the mp3 data
  const auto end = mRawMP3Data.end();
  auto dataIt = mRawMP3Data.begin();
  const size_t kWriteStep = 50 * 1024;  // 50kb write step

  while (dataIt != end) {
    size_t distToEnd = std::distance(dataIt, end);
    size_t nFeed = kWriteStep > distToEnd ? distToEnd : kWriteStep;

    const qint64 res = outFile.write(&*dataIt, nFeed);

    if (res < 0) {
      return Result::FileWriteError;
    }
    dataIt += res;
  }

  // do not need to close file as QFile destructor will take care of it
  return Result::Success;
}

void AudioFile::clear(void) {
  // clear all data containers
  mHasData = false;
  mIsDanceFile = false;
  mMP3PrependData.clear();
  mRawMP3Data.clear();
  mFloatData.clear();
  mFloatMusic.clear();

  // clear the mp3 info:
  mLoadFileSampleRate = 0;
  mLengthMS = 0;
  mArtist.clear();
  mTitle.clear();
  mComment.clear();
  mPath.clear();
}

int AudioFile::readTag(void) {
  // Setup
  auto tagFrameFactory = TagLib::ID3v2::FrameFactory::instance();
  TagLib::ByteVectorStream bvs{mRawMP3Data};
  TagLib::MPEG::File mpegFile(&bvs, tagFrameFactory, true,
                              TagLib::AudioProperties::Accurate);

  // read out audio properties:
  auto audioProperties = mpegFile.audioProperties();

  if (nullptr == audioProperties) {
    return 1;
  }

  // read sampling rate and length of audio:
  mLoadFileSampleRate = audioProperties->sampleRate();
  mLengthMS = audioProperties->lengthInMilliseconds();

  // read mp3 song info:
  auto tag = mpegFile.tag();

  if (!tag->artist().isNull()) {
    mArtist = tag->artist().to8Bit(true);
  } else {
    // if no tag is present, set to Unknown
    mArtist = "Unknown";
  }

  if (!tag->title().isNull()) {
    mTitle = tag->title().to8Bit(true);
  } else {
    mTitle = "Unknown";
  }

  if (!tag->comment().isNull()) {
    mComment = tag->comment().to8Bit(true);
  } else {
    mComment = "Unknown";
  }

  return 0;
}

int AudioFile::writeTag(void) {
  // Setup
  auto tagFrameFactory = TagLib::ID3v2::FrameFactory::instance();

  // the byte vector stream for the MPEG file object copies the byte vector
  // since we want to operate on the raw mp3 data in the file's bytevector
  // create empty dummy to pass to the stream, swap its bytevector with the
  // file's mp3 data, and then swap back after adding a tag
  TagLib::ByteVector dummy;
  TagLib::ByteVectorStream bvs{dummy};

  // swap in the file's byte-vector:
  bvs.data()->swap(mRawMP3Data);

  TagLib::MPEG::File mpegFile(&bvs, tagFrameFactory, true,
                              TagLib::AudioProperties::Accurate);

  // get the ID3V2 tag and set its fields according to data in file:
  auto tag = mpegFile.ID3v2Tag(true);
  tag->setArtist(TagLib::String(mArtist));
  tag->setTitle(TagLib::String(mTitle));
  if (mComment.empty()) {
    tag->setComment("Music for Dancebots, not humans.");
  } else {
    tag->setComment(TagLib::String(mComment));
  }

  // save the tag to the data
  if (mpegFile.save()) {
    // swap data back to raw mp3 data:
    mRawMP3Data.swap(*bvs.data());
    return 0;
  } else {
    // saving failed
    return 1;
  }
}

int AudioFile::decode(void) {
  // estimate number of samples and reserve enough data in pcm vector
  // add 1 to ms in case it is rounded down (as s is in documentation)
  // cast to size_t before calculation to avoid arithmethic overflow
  const size_t kNSamples = static_cast<size_t>(mLoadFileSampleRate) *
                           (static_cast<size_t>(mLengthMS) + 1) / 1000;
  mFloatData.reserve(kNSamples);
  mFloatMusic.reserve(kNSamples);

  const size_t kDecodeStepSize = 4096;

  // prep pcm buffers - TODO: Make the buffer size a function of the decode size
  // step if possible
  const size_t kPCMBufSize = 200000u;

  std::vector<qint16> pcmBufL;
  pcmBufL.resize(kPCMBufSize);
  std::vector<qint16> pcmBufR;
  pcmBufR.resize(kPCMBufSize);

  // decode the MP3 data into PCM data:
  hip_t dcGFP = hip_decode_init();
  lame_report_function dummyReportFunction = &lame_print_f;
  hip_set_errorf(dcGFP, dummyReportFunction);
  hip_set_debugf(dcGFP, dummyReportFunction);
  hip_set_msgf(dcGFP, dummyReportFunction);

  auto end = mRawMP3Data.end();
  auto buf = mRawMP3Data.begin();

  // Number of samples to cut from beginning that stem from encoder and decoder
  // delays
  const size_t kNSkip = ENCDELAY + DECDELAY + 1;
  size_t skipCount = 0;

  quint64 sum = 0u;  // running sum of ^2 pcm samples for rms calculation

  while (buf != end) {
    size_t distToEnd = std::distance(buf, end);
    size_t nFeed = kDecodeStepSize > distToEnd ? distToEnd : kDecodeStepSize;
    int nRead = hip_decode(dcGFP, reinterpret_cast<unsigned char*>(&*buf),
                           nFeed, pcmBufL.data(), pcmBufR.data());

    if (nRead) {
      if (nRead < 0) {
        return -1;
      }

      // read pcm data based on whether it is a dancefile or not
      if (!mIsDanceFile) {
        for (size_t i = 0; i < nRead; ++i) {
          qint32 average = (static_cast<qint32>(pcmBufL[i]) + pcmBufR[i]) / 2;
          mFloatMusic.push_back(static_cast<float>(average) / 32768.f);
          sum += static_cast<quint64>(
              (static_cast<qint64>(average) * static_cast<qint64>(average)));
        }
      } else {
        // only consider left channel
        for (size_t i = 0; i < nRead; ++i) {
          // skip encoder delay samples
          if (skipCount < kNSkip) {
            ++skipCount;
            continue;
          }
          mFloatMusic.push_back(static_cast<float>(pcmBufL[i]) / 32768.f);
          sum += static_cast<quint64>((static_cast<qint64>(pcmBufL[i]) *
                                       static_cast<qint64>(pcmBufL[i])));
        }
      }
    }
    buf += nFeed;
  }

  // cut off extra sample block at end:
  if (mIsDanceFile) {
    mFloatMusic.resize(mFloatMusic.size() - mp3BlockSize)
  }

  // calculate rms of music pcm data:
  quint64 average = sum / mFloatMusic.size();

  const double targetAverage = musicRMSTarget * musicRMSTarget *
                               static_cast<double>(SHRT_MIN) *
                               static_cast<double>(SHRT_MIN);

  mMP3MusicGain = sqrt(targetAverage / average);

  // resample the data if the sample rate is not 44.1kHz
  if (mLoadFileSampleRate != sampleRate) {
    std::vector<double> resampleDataIn;
    resampleDataIn.reserve(mFloatMusic.size());

    std::transform(mFloatMusic.cbegin(), mFloatMusic.cend(),
                   std::back_inserter(resampleDataIn),
                   [](float in) -> double { return static_cast<double>(in); });

    const auto resampleDataOut =
        Resampler::resample(mLoadFileSampleRate, sampleRate,
                            resampleDataIn.data(), resampleDataIn.size());
    // and write to float data vector:
    mFloatMusic.clear();
    mFloatMusic.reserve(resampleDataOut.size());

    std::transform(resampleDataOut.cbegin(), resampleDataOut.cend(),
                   std::back_inserter(mFloatMusic),
                   [](double in) -> float { return static_cast<float>(in); });

    // recalculate duration based on resampled sample length
    mLengthMS = mFloatMusic.size() * 1000 / sampleRate;
  }

  // resize music and data to integer multiple of mp3 block size:
  const size_t kNBlocks = (mFloatMusic.size() / mp3BlockSize) + 1;
  mFloatMusic.resize(kNBlocks * mp3BlockSize, 0);  // w. zero padding
  mFloatData.resize(kNBlocks * mp3BlockSize, 0);

  hip_decode_exit(dcGFP);
  return 0;
}

size_t AudioFile::findHeaderCode(QFile* file) {
  int headerInd{0};
  size_t filePosition{0};
  const size_t fileReadStep{1024};

  // allocate byte array to store read data:
  QByteArray readData;
  readData.resize(fileReadStep);

  qint64 nRead = file->read(readData.data(), fileReadStep);

  // keep searching while there is data available and no match is found:
  while (nRead > 0) {
    // match read data to current match position in header code
    for (int i = 0; i < nRead; ++i) {
      if (readData[i] == danceFileHeaderCode[headerInd]) {
        ++headerInd;
        // found match
        if (headerInd == danceFileHeaderCode.size()) {
          filePosition += (static_cast<size_t>(i) + 1 -
                           static_cast<size_t>(danceFileHeaderCode.size()));
          break;
        }
      } else {
        // reset to first character if not found
        headerInd = 0;
      }
    }

    // if found match, break out of while
    if (headerInd == danceFileHeaderCode.size()) {
      break;
    } else {
      // otherwise keep reading
      filePosition += nRead;
      nRead = file->read(readData.data(), fileReadStep);
    }
  }
  return filePosition;
}

auto AudioFile::encode(void) -> LameEncCodes {
  // in order to encode, both pcm buffers need to be non-empty
  // and of the same length:
  if (!mFloatData.size()) {
    return LameEncCodes::NoPCMData;
  }
  if (mFloatData.size() != mFloatMusic.size()) {
    return LameEncCodes::PCMDataNotSameLength;
  }

  lame_t gfp;
  gfp = lame_init();
  lame_set_mode(gfp, STEREO);
  lame_set_quality(gfp, mp3Quality);
  lame_set_in_samplerate(gfp, sampleRate);
  lame_set_brate(gfp, bitRateKB);
  lame_set_out_samplerate(gfp, sampleRate);
  lame_set_bWriteVbrTag(gfp, 1);
  lame_set_VBR(gfp, vbr_off);
  lame_set_scale_left(gfp, static_cast<float>(mMP3MusicGain));

  lame_report_function dummy_report_fun = &lame_print_f;
  lame_set_errorf(gfp, dummy_report_fun);
  lame_set_debugf(gfp, dummy_report_fun);
  lame_set_msgf(gfp, dummy_report_fun);

  if (0 > lame_init_params(gfp)) {
    lame_close(gfp);
    return LameEncCodes::LameInitFailed;
  }

  // create temporary mp3 data ByteVector:
  TagLib::ByteVector tempMP3;
  const size_t kTempMP3Size =
      mFloatData.size() * bitRateKB * 1'000 / sampleRate + 50'000;
  tempMP3.resize(kTempMP3Size);

  const size_t kPCMEncodeStepSize = 32 * mp3BlockSize;
  // See lame.h for calculation of buffer worst-case size
  const size_t kMP3BufferSize =
      static_cast<size_t>(kPCMEncodeStepSize * 1.25 + 7200.0);

  std::vector<unsigned char> encodeBuffer;
  encodeBuffer.resize(kMP3BufferSize);

  const auto musicEnd = mFloatMusic.end();
  auto musicIT = mFloatMusic.begin();
  auto dataIT = mFloatData.begin();

  auto mp3OutIt = tempMP3.begin();

  while (musicIT != musicEnd) {
    size_t distToEnd = std::distance(musicIT, musicEnd);
    size_t nFeed =
        kPCMEncodeStepSize > distToEnd ? distToEnd : kPCMEncodeStepSize;

    int nEncode = lame_encode_buffer_ieee_float(
        gfp, &*musicIT, &*dataIT, nFeed, encodeBuffer.data(), kMP3BufferSize);

    if (nEncode) {
      if (nEncode < 0) {
        // cast the return error code to the enum class return type
        return static_cast<LameEncCodes>(nEncode);
      }
      // otherwise, copy the buffer to the temp mp3 data:
      std::copy(encodeBuffer.begin(), encodeBuffer.begin() + nEncode, mp3OutIt);
      mp3OutIt += nEncode;
    }
    musicIT += nFeed;
    dataIT += nFeed;
  }

  // flush lame buffers:
  const int nFlush =
      lame_encode_flush(gfp, encodeBuffer.data(), kMP3BufferSize);
  if (nFlush > 0) {
    std::copy(encodeBuffer.begin(), encodeBuffer.begin() + nFlush, mp3OutIt);
    mp3OutIt += nFlush;
  }

  // get lame tag:
  const size_t tagSize =
      lame_get_lametag_frame(gfp, encodeBuffer.data(), kMP3BufferSize);

  // and copy it to the first frame:
  std::copy(encodeBuffer.begin(), encodeBuffer.begin() + tagSize,
            tempMP3.begin());

  // if all went well, truncate temp mp3 to number of bytes written
  const size_t nBytesOut = std::distance(tempMP3.begin(), mp3OutIt);
  tempMP3.resize(nBytesOut);

  // and swap it into the raw_mp3 data:
  mRawMP3Data.swap(tempMP3);

  lame_close(gfp);
  return LameEncCodes::EncodeSuccess;
}

int AudioFile::savePCM(const QString fileName) {
  if (!mHasData) {
    // no data, abort
    return 1;
  }

  SF_INFO outFormat;
  outFormat.channels = 2;
  outFormat.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;
  outFormat.samplerate = 44100;

  // otherwise save:
  SNDFILE* sndFile =
      sf_open(fileName.toStdString().c_str(), SFM_WRITE, &outFormat);

  if (!sndFile) {
    // opening failed, return:
    return 1;
  }

  // prepare write buffer for stereo file:
  std::vector<float> writeBuffer;
  writeBuffer.reserve(2 * mFloatData.size());

  for (size_t i = 0; i < mFloatData.size(); ++i) {
    writeBuffer.push_back(mFloatMusic[i]);
    writeBuffer.push_back(mFloatData[i]);
  }

  sf_write_float(sndFile, writeBuffer.data(), writeBuffer.size());
  sf_write_sync(sndFile);
  // close the file
  sf_close(sndFile);
  return 0;
}

int AudioFile::savePCMBeats(const QString fileName,
                            const std::vector<int>& beatFrames) {
  if (!mHasData) {
    // no data, abort
    return 1;
  }

  SF_INFO outFormat;
  outFormat.channels = 2;
  outFormat.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;
  outFormat.samplerate = sampleRate;

  // otherwise save:
  SNDFILE* sndFile =
      sf_open(fileName.toStdString().c_str(), SFM_WRITE, &outFormat);

  if (!sndFile) {
    // opening failed, return:
    return 1;
  }

  // prepare beep data:
  std::vector<float> beeps(mFloatData.size(), 0.0f);

  const float beepDuration = 0.2f;  // beep duration in seconds
  const float amp = 0.2;            // beep signal amplitude [0.0 1.0]
  const int fbeep = 441;            // beep frequency in Hz
  // number of samples per full beep period
  const size_t nSampBeepPeriod = sampleRate / fbeep;
  // number of periods in beep duration, rounded down by integer conversion
  const size_t nPeriods = beepDuration * static_cast<float>(sampleRate) /
                          static_cast<float>(nSampBeepPeriod);
  // number of samples in beep duration
  const size_t nbeepSamples = nPeriods * nSampBeepPeriod;
  // discrete-time beep frequency
  const float beepFreqDT = 2.0 * 3.14159 / nSampBeepPeriod;

  // calculate and write beeps into data audio
  for (const auto& b : beatFrames) {
    for (size_t i = b; i < b + nbeepSamples; ++i) {
      beeps[i] = amp * std::sin((i - b) * beepFreqDT);
    }
  }

  // prepare write buffer for stereo file:
  std::vector<float> writeBuffer;
  writeBuffer.reserve(2 * mFloatData.size());

  // write music and beep data interleaved to WAV data buffers
  for (size_t i = 0; i < mFloatData.size(); ++i) {
    writeBuffer.push_back(mFloatMusic[i]);
    writeBuffer.push_back(beeps[i]);
  }

  // write to wav file
  sf_write_float(sndFile, writeBuffer.data(), writeBuffer.size());
  sf_write_sync(sndFile);
  // close the file
  sf_close(sndFile);
  return 0;
}

void AudioFile::applyDataStreamSettings(QDataStream* stream) {
  stream->setVersion(dataStreamVersion);
  stream->setByteOrder(dataByteOrder);
  stream->setFloatingPointPrecision(dataFloatPrecision);
}
