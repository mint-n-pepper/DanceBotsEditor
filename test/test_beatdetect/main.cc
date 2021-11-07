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

#include <QDir>
#include <QtCore/QFile>
#include <string>

#include "src/audio_file.h"
#include "src/beat_detector.h"
#include "test/test_folder_path.h"

namespace {
class BeatDetectTest : public ::testing::Test {
 public:
  BeatDetectTest() : mBeatDetector(mSampleRate) {}

 protected:
  static void SetUpTestSuite(void) {
    // init
  }

  static void TearDownTestSuite(void) {
    // teardown
    // cleanup temp file
    std::remove(fileTemp.toStdString().c_str());
  }

  void printBeats(const std::vector<int>& beats);
  void compareBeats(const std::vector<int>& beatsA,
                    const std::vector<int>& beatsB);
  BeatDetector mBeatDetector;

  static const int mSampleRate{44100};
  static const QString fullFilesFolder;
  static const QString dpTestFile;
  static const QString fileTemp;
};

const int BeatDetectTest::mSampleRate;
const QString BeatDetectTest::fullFilesFolder{"fullFiles/"};
const QString BeatDetectTest::dpTestFile{testFolderPath +
                                         "dp_getlucky_20s.mp3"};
const QString BeatDetectTest::fileTemp{testFolderPath + "temp_BDT.mp3"};

TEST_F(BeatDetectTest, beatConsistency) {
  // see if there is a full files folder:
  QDir fullFileFolder{testFolderPath + fullFilesFolder};

  QStringList testFiles;

  if (fullFileFolder.exists()) {
    auto mp3FileList = fullFileFolder.entryList({"*.mp3", "*.MP3"});
    for (const auto& e : mp3FileList) {
      testFiles.append(fullFileFolder.filePath(e));
    }
  }

  testFiles.append(dpTestFile);

  // now test all files:

  for (const auto& testFile : testFiles) {
    // announce new testing file:
    std::cout << "Now testing on file " << testFile.toStdString() << std::endl;

    AudioFile mp3File44k{};
    AudioFile::Result res = mp3File44k.load(testFile);

    // do not proceed if file fails to load
    ASSERT_EQ(res, AudioFile::Result::Success);

    std::vector<int> firstBeats =
        mBeatDetector.detectBeats(mp3File44k.mFloatMusic);

    // write some data to file:
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

    const int nChecks = 50;  // run 50 cycles to check beat consistency

    // allow for >100ms beat-time deviation at most maxNdeviate times:
    const int maxDeviation = 0.1 * mSampleRate;
    int maxNdeviate = 2 * firstBeats.size() / 100;
    if (maxNdeviate < 1) maxNdeviate = 1;

    for (int i = 0; i < nChecks; ++i) {
      // load the temp file:
      AudioFile checkFile{};
      AudioFile::Result result = checkFile.load(fileTemp);

      // loading must succeed to proceed
      ASSERT_EQ(result, AudioFile::Result::Success);

      // make sure same number of audio samples:
      EXPECT_EQ(mp3File44k.mFloatMusic.size(), checkFile.mFloatMusic.size());

      // now verify that number of beats is the same and that beats are roughly
      // at the same location
      std::vector<int> checkBeats =
          mBeatDetector.detectBeats(checkFile.mFloatMusic);

      // number of beats, abort if not equal number as comparison below
      // will fail
      ASSERT_EQ(checkBeats.size(), firstBeats.size());

      // individual beats:
      int nDiff = 0;
      size_t maxDiff = 0;
      int deviated = 0;
      for (int j = 0; j < firstBeats.size(); ++j) {
        int absDiff = abs(firstBeats[j] - checkBeats[j]);

        if (absDiff) nDiff++;

        if (absDiff > maxDeviation) {
          deviated++;
        }
        if (absDiff > maxDiff) {
          maxDiff = absDiff;
        }
      }

      std::cout << "Check cycle " << i << " of " << nChecks
                << ": max diff = " << maxDiff
                << " frames and # of differing beats = " << nDiff
                << " out of a total of " << checkBeats.size() << std::endl;

      // print all beats if deviation is too large
      if (!(deviated < maxNdeviate)) {
        checkFile.savePCMBeats(testFolderPath + "deviated.wav", firstBeats);
        mp3File44k.savePCMBeats(testFolderPath + "original.wav", firstBeats);
        compareBeats(checkBeats, firstBeats);
      }
      checkFile.save(fileTemp);

      // check if number of deviated beats does not exceed max:
      ASSERT_LT(deviated, maxNdeviate);
    }
  }  // testfiles for loop
}

void BeatDetectTest::printBeats(const std::vector<int>& beats) {
  std::cout << "detected " << beats.size() << " beats" << std::endl;
  size_t i = 0;
  for (const auto& b : beats) {
    std::cout << "beat " << i++ << " is at frame " << b << std::endl;
  }
}

void BeatDetectTest::compareBeats(const std::vector<int>& beatsA,
                                  const std::vector<int>& beatsB) {
  std::cout << "detected " << beatsA.size() << " beats in A and "
            << beatsB.size() << " beats in B" << std::endl;
  const size_t minSize =
      beatsA.size() < beatsB.size() ? beatsA.size() : beatsB.size();

  for (size_t i = 0; i < minSize; ++i) {
    std::cout << "beat " << i << " is at frames " << beatsA[i] << " for A and "
              << beatsB[i]
              << " for B with absDiff = " << abs(beatsA[i] - beatsB[i])
              << std::endl;
  }
}
}  // namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
