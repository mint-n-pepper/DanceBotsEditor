#include <AudioFile.h>

#include <gtest/gtest.h>
#include <QtCore/QFile>
#include <string>

#include "BeatDetector.h"

namespace {
  class BeatDetectTest : public ::testing::Test {

  public:
    BeatDetectTest() : mBeatDetector(mSampleRate) {};

  protected:
    static void SetUpTestSuite(void) {
      // init
    }

    static void TearDownTestSuite(void) {
      // teardown
      // cleanup temp file
      std::remove(fileTemp.toStdString().c_str());
    }

    void printBeats(const std::vector<long>& beats);
    void compareBeats(const std::vector<long>& beatsA,
      const std::vector<long>& beatsB);
    BeatDetector mBeatDetector;

    static const int mSampleRate{ 44100 };
    static const QString fileFolderPath;
    static const QString dpTestFile;
    static const QString fileTemp;
  };

  const int BeatDetectTest::mSampleRate;
  const QString BeatDetectTest::fileFolderPath{ "./../test_mp3_files/" };
  const QString BeatDetectTest::dpTestFile{ fileFolderPath + "dp_getlucky_20s.mp3" };
  const QString BeatDetectTest::fileTemp{ fileFolderPath + "temp.mp3" };

  TEST_F(BeatDetectTest, beatConsistency) {
    
    
    AudioFile mp3File44k{ };
    mp3File44k.load(dpTestFile);

    std::vector<long> firstBeats = mBeatDetector.detectBeats(
      mp3File44k.mFloatMusic);

    // write some data to file:
    const std::string artist{ "Roboto" };
    const std::string title{ "BeepBeep" };
    mp3File44k.setArtist(artist);
    mp3File44k.setTitle(title);

    // write some header data
    const size_t nPrePendData = 128 + 16 + 2;

    for(size_t i = 0; i < nPrePendData; ++i) {
      mp3File44k.mMP3PrependData.append(static_cast<char>(i));
    }

    // save the file:
    mp3File44k.save(fileTemp);

    const int nChecks = 50; // run 50 cycles to check beat consistency

    for(int i = 0; i < nChecks; ++i) {
      // load the temp file:
      AudioFile checkFile{};
      AudioFile::Result result = checkFile.load(fileTemp);

      // make sure same number of audio samples:
      EXPECT_EQ(mp3File44k.mFloatMusic.size(),
        checkFile.mFloatMusic.size());

      // now verify that number of beats is the same and that beats are roughly
      // at the same location, allowing for a 100ms deviation at most:
      const long maxDeviation = 0.1 * mSampleRate;

      std::vector<long> checkBeats = mBeatDetector.detectBeats(
        checkFile.mFloatMusic);

      // number of beats, abort if not equal number as comparison below
      // will fail
      ASSERT_EQ(checkBeats.size(), firstBeats.size());

      // individual beats:
      int nDiff = 0;
      long maxDiff = 0;
      for(int j = 0; j < firstBeats.size(); ++j) {
        long absDiff = abs(firstBeats[j] - checkBeats[j]);
        
        if(absDiff) nDiff++;

        EXPECT_TRUE( absDiff < maxDeviation);
        if(absDiff > maxDiff) {
          maxDiff = absDiff;
        }
      }

      std::cout << "Check cycle " << i << " of " << nChecks << 
        ": max diff = " << maxDiff
        << " frames and number of differing beats = " << nDiff << std::endl;

      // print all beats if deviation is too large
      if(maxDiff > maxDeviation) {
        compareBeats(checkBeats, firstBeats);
      }
      checkFile.save(fileTemp);
    }


  }

  void BeatDetectTest::printBeats(const std::vector<long>& beats) {
    std::cout << "detected " << beats.size() << " beats" << std::endl;
    size_t i = 0;
    for(const auto& b : beats) {
      std::cout << "beat " << i++ << " is at frame " << b << std::endl;
    }
  }

  void BeatDetectTest::compareBeats(const std::vector<long>& beatsA,
    const std::vector<long>& beatsB) {
    std::cout << "detected " << beatsA.size() << " beats in A and " 
      << beatsB.size() << " beats in B" << std::endl;
    const size_t minSize = beatsA.size() < beatsB.size() ? beatsA.size() : beatsB.size();

    for(size_t i = 0; i < minSize; ++i) {
      std::cout << "beat " << i << " is at frames " 
        << beatsA[i] << "for A and " 
        << beatsB[i] << "for B with absDiff = " << abs(beatsA[i] - beatsB[i])
        << std::endl;
    }
  }

} // anon namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}