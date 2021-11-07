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

#include <chrono>
#include <iostream>
#include <random>
#include <string>

#include "src/utils.h"

namespace {
// Test Fixture Class that creates FFT class to run some tests on sample
// signals
class UtilsTest : public ::testing::Test {
 protected:
  UtilsTest(void) {}
};

TEST_F(UtilsTest, EdgeCases) {
  const std::vector<int> intervals{0, 10, 20};
  const std::vector<int> edgeValues{-10, 0, 20, 30};
  const std::vector<size_t> expectedIndices{0, 0, 0, 0};
  const std::vector<int> expectedReturns{-1, 0, -1, -1};
  const std::vector<utils::SearchMethod> methods{utils::SearchMethod::Binary,
                                                 utils::SearchMethod::Linear};

  for (const auto& m : methods) {
    for (size_t i = 0; i < edgeValues.size(); ++i) {
      size_t ind = 0;
      int rv = utils::findInterval<int>(edgeValues[i], intervals, &ind, m);
      EXPECT_EQ(rv, expectedReturns[i]);
      EXPECT_EQ(ind, expectedIndices[i]);
    }
  }
}

TEST_F(UtilsTest, Search) {
  const std::vector<size_t> arraySizes{10, 11, 100, 1000, 10000};
  const std::vector<utils::SearchMethod> methods{utils::SearchMethod::Binary,
                                                 utils::SearchMethod::Linear};
  std::vector<size_t> averageSearchTimes[2];
  averageSearchTimes[0].resize(arraySizes.size());
  averageSearchTimes[1].resize(arraySizes.size());

  const size_t N_EVALS = 10000;
  const int intervalSpan = 10;
  // seed rng:
  std::random_device
      rd;  // Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd());  // Standard mersenne_twister_engine seeded with rd()

  for (size_t iM = 0; iM < methods.size(); ++iM) {
    for (size_t iS = 0; iS < arraySizes.size(); ++iS) {
      // generate simple sample interval array:
      std::vector<int> intervals(arraySizes[iS]);
      std::generate(intervals.begin(), intervals.end(),
                    [&intervalSpan, n = -intervalSpan]() mutable {
                      n += intervalSpan;
                      return n;
                    });
      std::uniform_int_distribution<int> uniform(0, intervals.back() - 1);
      size_t averageDurationUs = 0;
      for (size_t iE = 0; iE < N_EVALS; ++iE) {
        // get random value:
        const int value = uniform(gen);
        size_t ind = 0;
        // time it:
        auto start = std::chrono::high_resolution_clock::now();
        int rv = utils::findInterval<int>(value, intervals, &ind, methods[iM]);
        auto end = std::chrono::high_resolution_clock::now();
        auto elapsed =
            std::chrono::duration_cast<std::chrono::nanoseconds>(end - start);

        averageDurationUs += elapsed.count();

        // check correct intervals:
        const int indCheck = value / intervalSpan;

        EXPECT_EQ(ind, indCheck) << "Failed with v = " << value << " method "
                                 << int(methods[iM]) << std::endl;
        EXPECT_EQ(rv, 0);
      }
      // put avg. duration into correct bin:
      averageSearchTimes[iM][iS] = averageDurationUs / N_EVALS;
    }
  }

#if 0
  // print results:
  std::vector<std::string> searchTypeStrings{"BINARY", "LINEAR"};
  for (size_t i = 0; i < 2; ++i) {
    std::cout << "Times for " << searchTypeStrings[i]
              << " search:" << std::endl;
    for (size_t j = 0; j < arraySizes.size(); ++j) {
      std::cout << "Size " << arraySizes[j] << ": " << averageSearchTimes[i][j]
                << "nS" << std::endl;
    }
  }
#endif
}
}  // namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
