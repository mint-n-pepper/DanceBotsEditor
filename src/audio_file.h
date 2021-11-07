/*
 *  Dancebots GUI - Create choreographies for Dancebots
 *  https://github.com/philippReist/dancebots_gui
 *
 *  Copyright 2019-2021 - mint & pepper
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

#ifndef SRC_AUDIO_FILE_H_
#define SRC_AUDIO_FILE_H_

#include <id3v2tag.h>
#include <mpegfile.h>
#include <mpegheader.h>
#include <tbytevectorstream.h>

#include <QDataStream>
#include <QtCore/QFile>
#include <string>
#include <vector>

/** \class AudioFile
 * \brief Loads, de- and encodes, and saves Dancebot audio MP3 files
 */
class AudioFile {
 public:
  // CONSTANTS //
  /** Result enum that indicates file processing outcomes
   */
  enum class Result {
    Success,
    NotAnMP3File,
    CorruptHeader,
    IOError,
    FileWriteError,
    FileOpenError,
    FileDoesNotExist,
    MP3DecodingError,
    MP3EncodingError,
    TagWriteError,
    NoDataToSave
  };

  // Flag for swap audio channels flag in number of beats uint32:
  static const quint32 SWAP_CHANNEL_FLAG_MASK = 0x80000000;

  /** String code at beginning and end of pre-pended header data */
  static const QByteArray danceFileHeaderCode;

  /** Settings for Qt stream serialization of header data  */
  static const QDataStream::ByteOrder dataByteOrder{QDataStream::BigEndian};
  static const QDataStream::Version dataStreamVersion{QDataStream::Qt_5_12};
  static const QDataStream::FloatingPointPrecision dataFloatPrecision{
      QDataStream::SinglePrecision};

  /** Sample rate used internally and for MP3 output.
   *
   * Inputs that are not at sampleRate will be up- or downsampled to match
   */
  static const int sampleRate{44100};
  /** Lame MP3 compression quality parameter */
  static const int mp3Quality{3};
  /** Lame output bitrate */
  static const int bitRateKB{192};
  /** MP3 block size. Using 44.1k will be MPEG 1 Layer III, which has a sample
   * block size of 1152
   */
  static const size_t mp3BlockSize{1152};
  /** target RMS level of music [0.0 1.0] that music is normalized to: */
  static const double musicRMSTarget;

  // PUBLIC METHODS //
  /** \brief Default constructor that returns an empty AudioFile object
   */
  AudioFile(void);

  /**
   * \brief Loads an MP3 file from a file path and returns processing result
   * Discards previous file data in object.
   *
   * Usage:
   * const QString kFilePath{ "C:/Users/philipp/Desktop/test.mp3" };
   * AudioFile file{};
   * const auto result = file.load(kFilePath);
   * if(result != AudioFile::Result::eSuccess){
   *   // file failed to load, process error:
   *   process_load_error(result);
   * }
   *
   * \param[in] filePath absolute path to MP3 file
   * \return Result enum of processing
   */
  Result load(const QString filePath);

  /**
   * \brief Saves an MP3 file and returns result of process
   *
   * Usage:
   * const QString kFilePath{ "C:/Users/philipp/Desktop/test.mp3" };
   * const auto result = file.save(kFilePath);
   * if(result != AudioFile::Result::eSuccess){
   *   // file failed to save, process error:
   *   process_save_error(result);
   * }
   *
   * \param[in] filePath absolute path to MP3 file
   * \return Result enum of processing
   */
  Result save(const QString filePath);

  /** \brief Clears all audio file data
   */
  void clear(void);

  /** \brief Flag that indicates whether the file is a dancefile as id'd by
   * a valid header present.
   */
  const bool isDancefile(void) const { return mIsDanceFile; }

  /** \brief Flag that indicates whether the file contains data or not
   */
  const bool hasData(void) const { return mHasData; }

  /** \brief Sets artist string
   */
  void setArtist(const std::string& artist) { mArtist = artist; }

  /** \brief Sets song title string
   */
  void setTitle(const std::string& title) { mTitle = title; }

  /** \brief Sets song comment string
   */
  void setComment(const std::string& comment) { mComment = comment; }

  /** \brief Get artist string
   */
  const std::string& getArtist(void) const { return mArtist; }

  /** \brief Get song title string
   */
  const std::string& getTitle(void) const { return mTitle; }

  /** \brief Get song comment string
   */
  const std::string& getComment(void) const { return mComment; }

  /** MP3 prepend data containing dance-file header, if available */
  QByteArray mMP3PrependData;
  /** Data channel of audio file (R) */
  std::vector<float> mFloatData;
  /** Music channel of audio file (L) */
  std::vector<float> mFloatMusic;

  /** \brief Saves music and data channels to PCM (WAV) file
   * \param[in] fileName absolute path to wav file to write
   * \return 0 if success and 1 if failure
   */
  int savePCM(const QString fileName);

  /** \brief Saves music and beat beep channels to PCM (WAV) file
   *  left channel is music and right channel is beat beeps at detecte locations
   * \param[in] fileName absolute path to wav file to write
   * \param[in] beatFrames vector of detected beats, location in frames/samples
   * \return 0 if success and 1 if failure
   */
  int savePCMBeats(const QString fileName, const std::vector<int>& beatFrames);

  /** \brief Returns pointer to raw MP3 file data
   * \return const pointer to data
   */
  const char* getRawMP3Data(void) const { return mRawMP3Data.data(); }

  /** \brief Sets swap channels property
   *  By default, the music is put into the left channel and the robot command
   * data into the right.
   *
   *  With this parameter set, the channels are swapped when saving and loading.
   *
   *  \param[in] swap Value to set swap channels property to (true: swap, false:
   * do not swap)
   */
  void setSwapChannels(const bool swap) { mSwapChannels = swap; }

  /** \brief Returns swap channels property
   * \return Swap channels property (true = swap)
   */
  bool getSwapChannels(void) const { return mSwapChannels; }

  /** \brief Returns total length in frames
   * \return length in frames
   */
  size_t getLengthInFrames(void) const { return mFloatMusic.size(); }

  /** \brief Applies data stream settings to QDataStream
   */
  static void applyDataStreamSettings(QDataStream* stream);

  /** \brief Gets number of beats from dancefile header data
   * \return number of beats in header data read from dancefile
   */
  quint32 getNumBeats(void) const;

 private:
  /** Lame encoding status enum */
  enum class LameEncCodes {
    EncodeSuccess = 0,
    MP3BufferTooSmall = -1,
    MallocProblem = -2,
    InitNotCalled = -3,
    PsychoIssue = -4,
    PCMDataNotSameLength = -5,
    NoPCMData = -6,
    LameInitFailed = -7
  };

  quint32 mNumBeats = 0u;     /**< Number of beats read from dancefile header */
  bool mSwapChannels = false; /**< Enable to swap music and data channels */

  /** MP3 file data container: */
  TagLib::ByteVector mRawMP3Data;

  QString mPath;             /**< file path */
  bool mIsDanceFile = false; /**< dance file flag (valid header detected) */
  /** number of bytes that make up the total bytes in header unsigned int */
  static const size_t headerSizeNBytes{4};
  bool mHasData{false}; /** flag indicating data available in object */

  /** Sample rate read from load file tags - only for internal use as all
   * music data will be resampled to the static const sampleRate = 44.1kHz
   */
  int mLoadFileSampleRate{0};
  int mLengthMS{0};     /**< length of music in ms from mp3 tag*/
  std::string mArtist;  /**< song artist (extracted from tag) */
  std::string mTitle;   /**< song title */
  std::string mComment; /**< song comment */

  /** Calculated music gain to ensure music rms stays at musicRMSTarget */
  double mMP3MusicGain = 1.0;

  /** \brief read mp3 tag from raw mp3 data into
   * \return 0 if success, 1 if failure
   */
  int readTag(void);

  /** \brief write artist and title to mp3 tag in raw mp3 data
   * \return 0 if success, 1 if failure
   */
  int writeTag(void);

  /** \brief decode raw mp3 data
   * \return 0 if success, 1 if failure
   */
  int decode(void);

  /** \brief find first occurance of header code in MP3 file
   * \param[in] file - to search
   * \return position of first occurance, or size of file if not found
   */
  size_t findHeaderCode(QFile* file);

  /** \brief encode data in music and data stream to raw mp3 data
   * \return Lame Encoder status codes, see above
   */
  LameEncCodes encode(void);
};

#endif  // SRC_AUDIO_FILE_H_
