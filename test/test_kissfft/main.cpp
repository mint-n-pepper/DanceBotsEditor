#include <cstdint>
#include <iostream>
#include <array>
#include <math.h>

#include <gtest/gtest.h>
#include "kissfft.hh"


namespace {
	// Test Fixture Class that creates FFT class to run some tests on sample
  // signals
	class FooTest : public ::testing::Test {
	protected:

		FooTest(void) :
      mFFTEngine(mNFFT, false),
      mOutput{}{

		}

		void SetUp(void) override {
			std::cout << "Setting up FooTest" << std::endl;
		}

		void TearDown(void) override {
			std::cout << "Tearing Down FooTest" << std::endl;
		}

    kissfft<float> mFFTEngine;
    static const size_t mNFFT = 64;
    static const float mPI;
    std::array<kissfft<float>::cpx_t, mNFFT> mOutput;
	};

  const float FooTest::mPI = 3.14159265358979323846f;

	TEST_F(FooTest, DCTest) {
    std::unique_ptr<float[]> input = std::make_unique<float[]>(mNFFT * 2);
    std::fill(input.get(), input.get() + mNFFT * 2, 0.4f);

    mFFTEngine.transform_real(input.get(), mOutput.data());

    EXPECT_FLOAT_EQ(0.4, mOutput.at(0).real()/(mNFFT*2));
	}

  TEST_F(FooTest, NyquistTest) {
    std::array<float, mNFFT * 2> input;

    float last_input = 0.4;
    for (auto &e : input) {
      e = last_input;
      last_input = -last_input;
    }


    mFFTEngine.transform_real(input.data(), mOutput.data());

    EXPECT_FLOAT_EQ(0.4, mOutput.at(0).imag() / (mNFFT * 2));
  }

  TEST_F(FooTest, BaseFreqTest) {
    std::array<float, mNFFT * 2> input;

    const float amp = 0.4;
    const float phase = mPI / 2.0f;
    const float frequency = mPI / mNFFT;
    float time = 0.0f;
    for (auto& e : input) {
      e = amp * std::cos(time * frequency + phase);
      time += 1.0f;
    }

    mFFTEngine.transform_real(input.data(), mOutput.data());

    const float amp_fft = std::sqrtf(mOutput.at(1).imag() * mOutput.at(1).imag()
      + mOutput.at(1).real() * mOutput.at(1).real()) / mNFFT;

    const float phase_fft = std::atan2(mOutput.at(1).imag(),
      mOutput.at(1).real());

    EXPECT_FLOAT_EQ(amp, amp_fft);
    EXPECT_FLOAT_EQ(phase, phase_fft);
  }

}// namespace


int main(int argc, char* argv[]) {
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}