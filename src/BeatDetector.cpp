#include "BeatDetector.h"

BeatDetector::BeatDetector(const unsigned int sample_rate) :
  mSampleRate{sample_rate},
  mBeatTracker{static_cast<float>(sample_rate)},
  mStepSize{ mBeatTracker.getPreferredStepSize() },
  mBlockSize{ mBeatTracker.getPreferredBlockSize() },
  mPluginBuffer{std::make_unique<float[]>(mBlockSize + 2u)},
  mRtAdjustment{ Vamp::RealTime::frame2RealTime( mBlockSize / 2u, sample_rate)}
{
  // NOTE: plugin buffer initialized to block size + 2 because detection function
  // frequency domain processing demands extra two samples in buffer

  // init the beattracker:
  mInitSuccess = mBeatTracker.initialise(1u, // init for single channel
                                         mStepSize,
                                         mBlockSize);
}

std::vector<long> BeatDetector::detectBeats(const std::vector<float>& monoMusicData)
{
  std::vector<long> retVal{};
  if (!mInitSuccess) {
    // failed to init in constructor, return and leave vector empty
    return retVal;
  }

  const size_t kDataLength = monoMusicData.size();

  if (!kDataLength) {
    // no data in vector
    // TODO: Check that some min length is satisfied, too (e.g. min 1 block)
    return retVal;
  }

  // push all data into beattracker
  for (long i = 0; i < kDataLength; i += mStepSize) {
    // figure out if we can process an entire block or if we need to
    // 
    // figure out how many samples to process
    size_t count = kDataLength - i;
    count = count > mBlockSize ? mBlockSize : count;
    
    // fill buffer with count data
    for (size_t j = 0; j < count; ++j) {
      mPluginBuffer[j] = monoMusicData[j + i];
    }

    // zero fill if necessary:
    for (size_t j = 0; j < mBlockSize - count; ++j) {
      mPluginBuffer[j] = 0.0f;
    }

    Vamp::RealTime rt = Vamp::RealTime::frame2RealTime(i, mSampleRate);

    const float* pBuf = mPluginBuffer.get();
    mBeatTracker.process(&pBuf, rt);  
  }

  Vamp::Plugin::FeatureSet features = mBeatTracker.getRemainingFeatures();
  Vamp::RealTime adjustment = Vamp::RealTime::frame2RealTime(mStepSize,
                                                             mSampleRate);
  // see if any beat features were detected
  if (features.find(0) != features.end()) {
    // for all features
    for (auto feature : features[0]) {
      if (feature.hasTimestamp) {
        retVal.push_back(Vamp::RealTime::realTime2Frame(feature.timestamp + adjustment, mSampleRate));
      }
    }
  }

  mBeatTracker.reset();

  return retVal;
}
