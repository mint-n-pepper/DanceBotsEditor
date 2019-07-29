#include "AudioFile.hpp"

// class constants:
const QByteArray AudioFile::kDanceFileHeaderCode("DancebotsDancefile");

auto AudioFile::LoadFile(const QString file_path) -> const FileStatus {
  
  if (file_path.size()) {
    path_ = file_path;
  }

  // check if file exists:
  QFile file{ path_ };

  if (!file.exists()) {
    return FileStatus::kFileDoesNotExist;
  }

  // if it exists, load it:
  file.open(QIODevice::ReadOnly);

  // read header to detect a dancefile
  size_t file_position = kDanceFileHeaderCode.size();
  const QByteArray header = file.read(file_position);

  if (kDanceFileHeaderCode == header) {
    // check number of bytes in header data:
    file_position += kHeaderSizeNBytes;
    const QByteArray header_n_data = file.read(kHeaderSizeNBytes);

    if (header_n_data.size() < kHeaderSizeNBytes) {
      return FileStatus::kCorruptHeader;
    }

    size_t n_data = static_cast<quint32>(header_n_data[0]);
    n_data += static_cast<quint32>(header_n_data[1]) << 8u;
    n_data += static_cast<quint32>(header_n_data[2]) << 16u;
    n_data += static_cast<quint32>(header_n_data[3]) << 24u;

    // verify that n_data is shorter than the file is long:
    if (file_position + n_data > file.size()) {
      return FileStatus::kCorruptHeader;
    }

    // otherwise read header data:
    file_position += n_data;
    mp3_prepend_data_ = file.read(n_data);

    // ensure that the header is valid:
    file_position += kDanceFileHeaderCode.size();
    const QByteArray header_end = file.read(kDanceFileHeaderCode.size());
    if (kDanceFileHeaderCode == header_end) {
      is_dancefile_ = true;
    }
    else {
      return FileStatus::kCorruptHeader;
    }

    // read in raw mp3 data:
    raw_mp3_data_.resize(file.size() - file_position);

    size_t n_read = file.read(raw_mp3_data_.data(), file.size() - file_position);
    
    if (n_read < file.size() - file_position) {
      return FileStatus::kIOError;
    }

    // now get MP3 tag and file properties
    auto tag_frame_factory = TagLib::ID3v2::FrameFactory::instance();
    TagLib::ByteVectorStream bvs{ raw_mp3_data_ };
    TagLib::MPEG::File mpeg_file(&bvs,
                                 tag_frame_factory,
                                 true,
                                 TagLib::AudioProperties::Accurate);

};

  return FileStatus::kOk;
}