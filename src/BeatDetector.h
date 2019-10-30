#include<vector>
#include<memory>
#include <BeatTrack.h>
#include "kissfft.hh"

class BeatDetector {
public:
  explicit BeatDetector(const unsigned int sample_rate);

  std::vector<long> detectBeats(const std::vector<float>& monoMusicData);

  // check if init was successful
  bool isInitialized(void) { return mInitSuccess; };
private:
  const unsigned int mSampleRate;
  BeatTracker mBeatTracker;
  const size_t mStepSize;
  const size_t mBlockSize;
  std::vector<float> mPluginBuffer;
  std::vector<float> mHanningWindow;
  std::vector<float> mWindowedData;
  std::vector<kissfft<float>::cpx_t> mFFTOutput;
  Vamp::RealTime mRtAdjustment;
  kissfft<float> mKissFFT;

  bool mInitSuccess = false;

  static const float mPI;
};