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

#include "src/beat_detector.h"

BeatDetector::BeatDetector(const unsigned int sampleRate)
    : mSampleRate{sampleRate},
      mBeatTracker{static_cast<float>(sampleRate)},
      mStepSize{mBeatTracker.getPreferredStepSize()},
      mBlockSize{mBeatTracker.getPreferredBlockSize()},
      mPluginBuffer(mBlockSize + 2u, 0.0f),
      mHanningWindow(mBlockSize, 0.0f),
      mWindowedData(mBlockSize, 0.0f),
      mFFTOutput(mStepSize, {0.0f, 0.0f}),
      mRtAdjustment{
          Vamp::RealTime::frame2RealTime(mBlockSize / 2u, sampleRate)},
      mKissFFT(mStepSize, false) {
  // NOTE: plugin buffer initialized to block size + 2 because frequency domain
  // processing has DC and Nyquist elements that have complex parts = 0, making
  // up the extra two samples

  // init the beattracker:
  mInitSuccess = mBeatTracker.initialise(1u,  // init for single channel
                                         mStepSize, mBlockSize);

  // init the hanning window:
  size_t index = 0;
  for (auto& e : mHanningWindow) {
    e = 0.5f - 0.5f * std::cos(2.f * mPI * index / (mBlockSize - 1));
    ++index;
  }
}

const float BeatDetector::mPI = 3.14159265358979323846f;

std::vector<int> BeatDetector::detectBeats(
    const std::vector<float>& monoMusicData) {
  std::vector<int> retVal{};
  if (!mInitSuccess) {
    // failed to init in constructor, return and leave vector empty
    return retVal;
  }

  const size_t kDataLength = monoMusicData.size();

  if (kDataLength < 2 * mBlockSize) {
    // not enough data in vector
    return retVal;
  }

  // push all data into beattracker
  for (size_t i = 0; i < kDataLength; i += mStepSize) {
    // figure out if we can process an entire block or if we need to
    // figure out how many samples to process
    size_t count = kDataLength - i;
    count = count > mBlockSize ? mBlockSize : count;

    // fill window buffer with count samples
    for (size_t j = 0; j < count; ++j) {
      mWindowedData[j] = monoMusicData[j + i] * mHanningWindow[j];
    }

    // zero fill if necessary:
    for (size_t j = 0; j < mBlockSize - count; ++j) {
      mWindowedData[j] = 0.0f;
    }

    // Get DFT:
    mKissFFT.transform_real(mWindowedData.data(), mFFTOutput.data());

    // now place the result into the proper subbins:
    // DC
    mPluginBuffer[0] = mFFTOutput[0].real();
    // element 1 will be initialized to zero
    // Nyquist:
    mPluginBuffer[mBlockSize] = mFFTOutput[0].imag();
    // element mBlockSize + 1 will be initialized to zero

    // now populate the remaining elements:
    for (size_t i = 1; i < mStepSize; ++i) {
      mPluginBuffer[2 * i] = mFFTOutput[i].real();
      mPluginBuffer[2 * i + 1] = mFFTOutput[i].imag();
    }

    Vamp::RealTime rt = Vamp::RealTime::frame2RealTime(i, mSampleRate);

    const float* pBuf = mPluginBuffer.data();
    // none of the features will be detected in this phase, so do not have to
    // process return value
    Vamp::Plugin::FeatureSet f_ = mBeatTracker.process(&pBuf, rt);
  }

  Vamp::Plugin::FeatureSet features = mBeatTracker.getRemainingFeatures();
  // calculate adjustment as feature is detected at center of block size
  // for frequency domain feature detection
  Vamp::RealTime adjustment =
      Vamp::RealTime::frame2RealTime(mStepSize, mSampleRate);
  // see if any beat features were detected
  if (features.find(0) != features.end()) {
    // Get remaining beats
    for (auto feature : features[0]) {
      if (feature.hasTimestamp) {
        retVal.push_back(static_cast<int>(Vamp::RealTime::realTime2Frame(
            feature.timestamp + adjustment, mSampleRate)));
      }
    }
  }

  mBeatTracker.reset();

  return retVal;
}
