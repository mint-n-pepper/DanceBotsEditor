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

#include <gtest/gtest.h>
#include <src/audio_file.h>

#include <QtCore/QFile>
#include <string>

#include "test/test_folder_path.h"

namespace {
class AudioFileTest : public ::testing::Test {
 protected:
  static void SetUpTestSuite(void) {
    // init
  }

  static void TearDownTestSuite(void) {
    // cleanup temp file
    std::remove(fileTemp.toStdString().c_str());
  }

  static constexpr float getPi(void) { return 3.14159265359f; }

  static const QString fileMusic44k;
  static const QString fileTemp;
  static const std::vector<QString> fileNames;
};

const QString AudioFileTest::fileMusic44k = testFolderPath + "in44100.mp3";
const QString AudioFileTest::fileTemp = testFolderPath + "temp_AT.mp3";
const std::vector<QString> AudioFileTest::fileNames{
    "in8000.mp3", "in11025.mp3", "in22050.mp3", "in32000.mp3", "in48000.mp3"};

TEST_F(AudioFileTest, testAudioFileNotExist) {
  // test opening a fake file:
  const QString fakeFileName("fakefakefile.mp3");

  AudioFile fakeFile{};
  auto result = fakeFile.load(testFolderPath + fakeFileName);

  EXPECT_EQ(result, AudioFile::Result::FileDoesNotExist);
  EXPECT_FALSE(fakeFile.hasData());

  // try to save empty audiofile
  result = fakeFile.save(fileTemp);

  EXPECT_EQ(result, AudioFile::Result::NoDataToSave);
}

TEST_F(AudioFileTest, testSave) {
  AudioFile mp3File44k{};
  mp3File44k.load(fileMusic44k);

  // test tag data:
  EXPECT_STREQ(mp3File44k.getArtist().c_str(), "Daft Punk");
  EXPECT_STREQ(mp3File44k.getTitle().c_str(), "Face To Face");

  // verify flags:
  EXPECT_FALSE(mp3File44k.isDancefile());
  EXPECT_TRUE(mp3File44k.hasData());

  // write new data:
  const std::string artist{"Roboto"};
  const std::string title{"BeepBeep"};
  mp3File44k.setArtist(artist);
  mp3File44k.setTitle(title);

  // write some header data
  const size_t nPrePendData = 128 + 16 + 2;

  for (size_t i = 0; i < nPrePendData; ++i) {
    mp3File44k.mMP3PrependData.append(static_cast<char>(i));
  }

  // save the file:
  mp3File44k.save(fileTemp);

  // load the file again:
  AudioFile checkFile{};

  AudioFile::Result result = checkFile.load(fileTemp);

  // check changed tag data
  EXPECT_STREQ(artist.c_str(), checkFile.getArtist().c_str());
  EXPECT_STREQ(artist.c_str(), checkFile.getArtist().c_str());

  // check header data:
  EXPECT_EQ(result, AudioFile::Result::Success);
  EXPECT_TRUE(checkFile.isDancefile());
  EXPECT_EQ(checkFile.mMP3PrependData.size(), nPrePendData);

  // go through header data:
  for (size_t i = 0; i < nPrePendData; ++i) {
    EXPECT_EQ(static_cast<char>(i), checkFile.mMP3PrependData.at(i));
  }
}

TEST_F(AudioFileTest, testResample) {
  // now load all files and check that sample numbers are close to 44k file
  AudioFile mp3File44k{};
  mp3File44k.load(fileMusic44k);
  const size_t nSamples = mp3File44k.mFloatMusic.size();
  const size_t sampleRange{44100 / 10 * 3};  // allow for 0.3s deviation
  // for 8k file, allow bigger deviation
  const size_t sampleRange8k{44100 / 10 * 7};  // allow for 0.7s deviation

  for (const auto& filename : fileNames) {
    size_t testRange = sampleRange;
    if (filename == "in8000.mp3") testRange = sampleRange8k;
    AudioFile resampleFile{};
    resampleFile.load(testFolderPath + filename);
    // ensure resampled total samples are close to 44.1k Hz file
    // because of large deviation in 8kHz file, have quite broad threshold
    EXPECT_GT(resampleFile.mFloatMusic.size(), nSamples - testRange)
        << " for file " << filename.toStdString();
    EXPECT_LT(resampleFile.mFloatMusic.size(), nSamples + testRange)
        << " for file " << filename.toStdString();
  }
}

TEST_F(AudioFileTest, test44kFile) {
  // test opening a music mp3 file:

  AudioFile mp3File44k{};
  auto result = mp3File44k.load(fileMusic44k);

  ASSERT_EQ(result, AudioFile::Result::Success);
  ASSERT_TRUE(mp3File44k.hasData());

  EXPECT_FALSE(mp3File44k.isDancefile());

  // make sure mp3 data is read from beginning of file
  // if test file is not a dance file
  QFile testFile{fileMusic44k};

  testFile.open(QIODevice::ReadOnly);

  const size_t kNRead = 100;
  QByteArray testData = testFile.read(kNRead);

  const char* mp3FileData = mp3File44k.getRawMP3Data();

  for (size_t i = 0; i < testData.size(); ++i) {
    EXPECT_EQ(mp3FileData[i], testData.data()[i]);
  }
}

TEST_F(AudioFileTest, testClear) {
  // test opening a music mp3 file:

  AudioFile mp3File44k{};
  auto result = mp3File44k.load(fileMusic44k);

  ASSERT_EQ(result, AudioFile::Result::Success);
  ASSERT_TRUE(mp3File44k.hasData());

  // clear data:
  mp3File44k.clear();

  EXPECT_TRUE(mp3File44k.mFloatData.empty());
  EXPECT_TRUE(mp3File44k.mFloatMusic.empty());
  EXPECT_TRUE(mp3File44k.mMP3PrependData.isEmpty());

  EXPECT_FALSE(mp3File44k.hasData());

  EXPECT_TRUE(mp3File44k.getArtist().empty());
  EXPECT_TRUE(mp3File44k.getTitle().empty());
}

TEST_F(AudioFileTest, testDeEnCodeCycles) {
  AudioFile mp3FileHeaderTest{};
  mp3FileHeaderTest.load(fileMusic44k);

  // save and load file to get steady-state data length that should be const
  mp3FileHeaderTest.save(fileTemp);
  mp3FileHeaderTest.load(fileTemp);

  const size_t nMP3Samples = mp3FileHeaderTest.mFloatData.size();

  for (uint a = 0; a < 10; ++a) {
    AudioFile mp3FileCycleTest{};
    mp3FileCycleTest.load(fileTemp);
    EXPECT_EQ(nMP3Samples, mp3FileCycleTest.mFloatData.size());
    mp3FileCycleTest.save(fileTemp);
  }
}

static bool vectorIsZero(const std::vector<float>& data,
                         const float tol = 0.001f) {
  bool isZero = true;

  for (const auto& e : data) {
    isZero &= e < tol;
  }
  return isZero;
}

TEST_F(AudioFileTest, testSwapChannels) {
  AudioFile mp3FileHeaderTest{};
  mp3FileHeaderTest.load(fileMusic44k);

  // save music:
  const std::vector<float> musicCopy = mp3FileHeaderTest.mFloatMusic;
  // load with swapped channels, should be equal:
  mp3FileHeaderTest.setSwapChannels(true);
  mp3FileHeaderTest.load(fileMusic44k);

  EXPECT_TRUE(musicCopy == mp3FileHeaderTest.mFloatMusic);
  mp3FileHeaderTest.setSwapChannels(false);  // reset

  auto& data = mp3FileHeaderTest.mFloatData;
  auto& music = mp3FileHeaderTest.mFloatMusic;

  EXPECT_TRUE(vectorIsZero(data));
  EXPECT_FALSE(vectorIsZero(music));

  // save with/without flag and ensure that loading is independent of
  // file state:
  for (uint saveWithFlag = 0u; saveWithFlag < 2u; ++saveWithFlag) {
    const bool swap = !!saveWithFlag;
    mp3FileHeaderTest.setSwapChannels(swap);
    // take care of header data:
    mp3FileHeaderTest.mMP3PrependData.clear();
    // create and open buffer to stream data into:
    QDataStream dataStream(&mp3FileHeaderTest.mMP3PrependData,
                           QIODevice::WriteOnly);
    AudioFile::applyDataStreamSettings(&dataStream);
    // write number of beats first:
    quint32 nBeats = static_cast<quint32>(5u);
    // process swap audio channels flag:
    if (swap) {
      nBeats |= AudioFile::SWAP_CHANNEL_FLAG_MASK;
    }
    dataStream << nBeats;
    mp3FileHeaderTest.save(fileTemp);

    mp3FileHeaderTest.setSwapChannels(true);
    mp3FileHeaderTest.load(fileTemp);
    EXPECT_EQ(swap, mp3FileHeaderTest.getSwapChannels());
    EXPECT_FALSE(vectorIsZero(music));
    EXPECT_TRUE(vectorIsZero(data));

    mp3FileHeaderTest.setSwapChannels(false);
    mp3FileHeaderTest.load(fileTemp);
    EXPECT_EQ(swap, mp3FileHeaderTest.getSwapChannels());
    EXPECT_FALSE(vectorIsZero(music));
    EXPECT_TRUE(vectorIsZero(data));
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
