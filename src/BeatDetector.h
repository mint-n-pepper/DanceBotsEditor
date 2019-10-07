#include<vector>
#include<memory>
#include <BeatTrack.h>

class BeatDetector {
public:
  explicit BeatDetector(const unsigned int sample_rate);

  std::vector<long> detectBeats(const std::vector<float>& monoMusicData);
  
  // check if init was successful
  bool isInitialized(void) { return mInitSuccess; };
private:
  unsigned int mSampleRate;
  BeatTracker mBeatTracker;
  size_t mStepSize;
  size_t mBlockSize;
  Vamp::RealTime mRtAdjustment;
  bool mInitSuccess = false;
  std::unique_ptr<float[]> mPluginBuffer;
};