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
  //** CONSTANTS ** //
  // Result enums that indicate processing outcomes
  enum class Result {
    kSuccess,
    kNotAnMP3File,
    kCorruptHeader,
    kIOError,
    kFileWriteError,
    kFileOpenError,
    kFileDoesNotExist,
    kMP3DecodingError,
    kMP3EncodingError,
    kTagWriteError
  };
  
  // string code at beginning and end of pre-pended header data
  static const QByteArray kDanceFileHeaderCode;
  // sample rate used internally and for MP3 output.
  // inputs that are not at that sample rate will be up- or downsampled to that
  // rate
  static const int kSampleRate{ 44100 };
  // Lame MP3 compression quality parameter
  static const int kMP3Quality{ 3 };
  // Lame output bitrate
  static const int kBitRateKB{ 160 };
  // using 44.1k will be MPEG 1 Layer III, which has a sample block size of 1152
  static const size_t kMP3BlockSize{ 1152 };
  // target RMS level of music [0.0 1.0] that music is normalized to:
  static const double kMusicRMSTarget;

  //** PUBLIC METHODS **//
  // default constructor that returns an empty AudioFile object
  explicit AudioFile(void);

  // Loads a file from an absoulte file_path and returns result of process.
  // Discards previous file data in object
  // Usage:
  // const QString kFilePath{ "C:/Users/philipp/Desktop/test.mp3" };
  // AudioFile file{};
  // const auto result = file.Load(kFilePath);
  // if(result != AudioFile::Result::kSuccess){
  //   // file failed to load, process error:
  //  process_load_error(result);
  // }
  //
  Result Load(const QString file_path);

  // Saves an MP3 file to an absoulte file_path and returns result of process.
  //
  // Usage:
  // const QString kFilePath{ "C:/Users/philipp/Desktop/test.mp3" };
  // const auto result = file.Save(kFilePath);
  // if(result != AudioFile::Result::kSuccess){
  //   // file failed to save, process error:
  //  process_save_error(result);
  // }
  //
  Result Save(const QString file_path);

  // Clears all data
  void Clear(void);

  // Flag that indicates whether the file is a dancefile as id'd by a valid
  // header present
  const bool is_dancefile(void) const {
    return is_dancefile_;
  }

  // Flag that indicates whether the file contains data or not
  const bool has_data(void) const {
    return has_data_;
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

  // public data members
  QByteArray mp3_prepend_data_;
  std::vector<float> float_data_;
  std::vector<float> float_music_;

  // saves music and data channels to PCM (WAV) file given by absoulte file_path
  // returns 0 if success and 1 if failure
  int SavePCM(const QString file_name);

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
  bool has_data_{ false };

	// audio file parameters:
  int sample_rate_ { 0 };
  int length_ms_{ 0 };
	std::string artist_;
	std::string title_;
  double mp3_music_gain_ = 1.0;

  // private functions:
  int ReadTag(void);
  int WriteTag(void);
  int Decode(void);
  LameEncCodes Encode(void);
};

#endif // AUDIO_FILE_H header guard
