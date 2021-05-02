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

#ifndef SRC_BEAT_DETECTOR_H_
#define SRC_BEAT_DETECTOR_H_

#include <memory>
#include <vector>

#include "lib/kissfft/kissfft.hh"
#include "lib/qm-vamp-plugins/plugins/BeatTrack.h"

/** \class BeatDetector
 * \brief Detects beats in mono music data using the Queen Mary VAMP plugins
 * https://vamp-plugins.org/plugin-doc/qm-vamp-plugins.html
 */
class BeatDetector {
 public:
  /**
   * \brief Constructs a beat detector object.
   *
   * \param[in] sampleRate in Hz of audio to be used in detection
   */
  explicit BeatDetector(const unsigned int sampleRate);

  /**
   * \brief Detect beats in raw music signal
   *
   * \param[in] monoMusicData - raw audio data in normalized float [-1.0 1.0]
   * format and sampled at sampleRate passed into constructor
   */
  std::vector<int> detectBeats(const std::vector<float>& monoMusicData);

  /**
   * \brief Check if init was successful
   */
  bool isInitialized(void) { return mInitSuccess; }

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

#endif  // SRC_BEAT_DETECTOR_H_
