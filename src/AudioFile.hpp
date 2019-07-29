#ifndef AUDIO_FILE_H_
#define AUDIO_FILE_H_

#include <vector>
#include <QtCore/QFile>

#include <tbytevectorstream.h>
#include <mpegfile.h>
#include <mpegheader.h>
#include <id3v2tag.h>

class AudioFile {
public:
  enum class FileStatus {
    kOk = 0,
    kCorruptHeader,
    kIOError,
    kFileDoesNotExist
  };
  
  explicit AudioFile(void) {};
  explicit AudioFile(const QString file_path) : path_(file_path){};

  const FileStatus LoadFile(const QString file_path = { "" });

  // constants:
  static const QByteArray kDanceFileHeaderCode;

  const bool is_dancefile(void) const {
    return is_dancefile_;
  }

private:
  // file data containers:
  TagLib::ByteVector raw_mp3_data_;
  QByteArray mp3_prepend_data_;
	std::vector<qint16> pcl_data_left_;
	std::vector<qint16> pcl_data_right_;

  // file
  QString path_;
  bool is_dancefile_ = false;
  static const size_t kHeaderSizeNBytes = 4u;

	// audio file parameters:
	quint32 sample_rate = 0;
	std::string artist;
	std::string title;
  std::string album;
};

#endif // AUDIO_FILE_H header guard
