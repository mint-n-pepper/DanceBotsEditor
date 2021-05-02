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
#include <math.h>

#include <array>
#include <cstdint>
#include <iostream>

#include "lib/kissfft/kissfft.hh"

namespace {
// Test Fixture Class that creates FFT class to run some tests on sample
// signals
class FFTTest : public ::testing::Test {
 protected:
  FFTTest(void) : mFFTEngine(mNFFT, false), mOutput{} {}

  kissfft<float> mFFTEngine;
  static const size_t mNFFT = 64;
  static const float mPI;
  std::array<kissfft<float>::cpx_t, mNFFT> mOutput;
};

const float FFTTest::mPI = 3.14159265358979323846f;

TEST_F(FFTTest, DCTest) {
  // create dc signal with amplitude 0.4
  std::unique_ptr<float[]> input = std::make_unique<float[]>(mNFFT * 2);
  std::fill(input.get(), input.get() + mNFFT * 2, 0.4f);

  // transform and check that DC component is correct
  mFFTEngine.transform_real(input.get(), mOutput.data());
  EXPECT_FLOAT_EQ(0.4, mOutput.at(0).real() / (mNFFT * 2));
}

TEST_F(FFTTest, NyquistTest) {
  // create signal at Nyquist frequency
  std::array<float, mNFFT * 2> input;

  float last_input = 0.4;
  for (auto& e : input) {
    e = last_input;
    last_input = -last_input;
  }

  // transform and verify that amplitude is indeed 0.4
  mFFTEngine.transform_real(input.data(), mOutput.data());
  EXPECT_FLOAT_EQ(0.4, mOutput.at(0).imag() / (mNFFT * 2));
}

TEST_F(FFTTest, BaseFreqTest) {
  // create signal at first FFT frequency bin
  std::array<float, mNFFT * 2> input;

  const float amp = 0.4;
  const float phase = mPI / 2.0f;
  const float frequency = mPI / mNFFT;
  float time = 0.0f;
  for (auto& e : input) {
    e = amp * std::cos(time * frequency + phase);
    time += 1.0f;
  }

  // transform and verify amplitude and phase
  mFFTEngine.transform_real(input.data(), mOutput.data());

  const float ampFFT = std::sqrt(mOutput.at(1).imag() * mOutput.at(1).imag() +
                                 mOutput.at(1).real() * mOutput.at(1).real()) /
                       mNFFT;

  const float phaseFFT = std::atan2(mOutput.at(1).imag(), mOutput.at(1).real());

  EXPECT_FLOAT_EQ(amp, ampFFT);
  EXPECT_FLOAT_EQ(phase, phaseFFT);
}

}  // namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
