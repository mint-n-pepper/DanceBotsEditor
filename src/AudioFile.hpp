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
    kEmpty,
    kNotAnMP3File,
    kCorruptHeader,
    kIOError,
    kFileDoesNotExist,
    kMP3DecodingError,
    kMP3EncodingError,
    kTagWriteError
  };
  
  explicit AudioFile(const QString file_path);

  // constants:
  static const QByteArray kDanceFileHeaderCode;

  const bool is_dancefile(void) const {
    return is_dancefile_;
  }

  const FileStatus GetStatus(void) const {
    return status_;
  }

  const char* GetRawMP3Data(void) const {
    return raw_mp3_data_.data();
  }

  void SetArtist(const std::string& artist) {
    artist_ = artist;
  }

  void SetTitle(const std::string& title) {
    title_ = title;
  }

  const std::string& GetArtist(void) const {
    return artist_;
  }

  const std::string& GetTitle(void) const{
    return title_;
  }

  int GetSampleRate(void) const {
    return sample_rate_;
  }

  void Save(const QString file);

  QByteArray& GetPrePendData(void) {
    return mp3_prepend_data_;
  }

  QByteArray mp3_prepend_data_;
  std::vector<qint16> pcm_music_;
  std::vector<qint16> pcm_data_;
  std::vector<double> double_music_;

  int SavePCM(const QString file);

private:
  enum class LameEncCodes {
    kEncodeSuccess = 0,
    kMP3BufTooSmall = -1,
    kMallocProblem = -2,
    kInitNotCalled = -3,
    kPsychoIssue = -4,
    kPCMDataNotSameLength = -5,
    kNoPCMData = -6,
    kLameInitFailed = -7
  };
  // file data containers:
  TagLib::ByteVector raw_mp3_data_;

  // file
  QString path_;
  bool is_dancefile_ = false;
  static const size_t kHeaderSizeNBytes{ 4 };
  FileStatus status_{ FileStatus::kEmpty };

	// audio file parameters:
  int sample_rate_ { 0 };
  int length_ms_{ 0 };
	std::string artist_;
	std::string title_;

  // private functions:
  int ReadTag(void);
  int WriteTag(void);
  int Decode(void);
  LameEncCodes Encode(void);
};

#endif // AUDIO_FILE_H header guard
