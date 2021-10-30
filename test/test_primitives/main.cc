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
#include <QByteArray>
#include <QDataStream>
#include <iostream>
#include <random>

#include "src/audio_file.h"
#include "src/primitive.h"

namespace {
// check functions:
void checkMotorPrimitivesEqual(const MotorPrimitive& prim,
                               const MotorPrimitive& checkPrim);
void checkLedPrimitivesEqual(const LEDPrimitive& prim,
                             const LEDPrimitive& checkPrim);

// Test Fixture Class that creates FFT class to run some tests on sample
// signals
class PrimitivesTest : public ::testing::Test {
 protected:
  PrimitivesTest(void) {}
};

TEST_F(PrimitivesTest, singleMotorTest) {
  SCOPED_TRACE("Single Motor Primitive Test");
  // test data:
  double frequency = 0.5;
  int position = 6;
  int length = 10;
  MotorPrimitive::Type type = MotorPrimitive::Type::Custom;
  int velocity = -4;
  int velocityRight = 5;

  // create a single motor primitive
  MotorPrimitive prim;
  prim.mFrequency = frequency;
  prim.mPositionBeat = position;
  prim.mLengthBeat = length;
  prim.mType = type;
  prim.mVelocity = velocity;
  prim.mVelocityRight = velocityRight;

  // create datastream
  QByteArray dataArray;
  QDataStream dataStream(&dataArray, QIODevice::ReadWrite);
  AudioFile::applyDataStreamSettings(&dataStream);

  // serialize primitive
  prim.serializeToStream(&dataStream);

  // and create a new primitive from the stream:
  dataStream.device()->reset();

  MotorPrimitive checkPrim(&dataStream);

  // and verify data:
  checkMotorPrimitivesEqual(prim, checkPrim);
}

TEST_F(PrimitivesTest, RandomMotorArrayTest) {
  SCOPED_TRACE("Array Motor Primitive Test");
  // init random:
  std::random_device
      rd;  // Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd());  // Standard mersenne_twister_engine seeded with rd()
  std::uniform_int_distribution<int> positionDis(0, 100);
  std::uniform_int_distribution<int> velocityDis(-100, 100);
  std::uniform_real_distribution<double> frequencyDis(0.25, 4.0);
  const int N_TYPES = static_cast<int>(MotorPrimitive::Type::Custom) + 1;
  const size_t N_CHECK = 100;
  std::vector<MotorPrimitive*> primitives(N_CHECK, new MotorPrimitive());
  primitives.reserve(N_CHECK);

  for (auto& p : primitives) {
    p->mFrequency = frequencyDis(gen);
    p->mPositionBeat = positionDis(gen);
    p->mLengthBeat = positionDis(gen);
    p->mVelocity = velocityDis(gen);
    p->mVelocityRight = velocityDis(gen);
    p->mType = static_cast<MotorPrimitive::Type>(positionDis(gen) % N_TYPES);
  }

  // serialize all to stream:
  QByteArray dataArray;
  QDataStream dataStream(&dataArray, QIODevice::ReadWrite);
  AudioFile::applyDataStreamSettings(&dataStream);

  // serialize primitive
  for (const auto& p : primitives) {
    p->serializeToStream(&dataStream);
  }

  // and recreate primitives from stream
  dataStream.device()->reset();

  for (size_t i = 0; i < primitives.size(); ++i) {
    MotorPrimitive checkPrim(&dataStream);
    checkMotorPrimitivesEqual(*primitives.at(i), checkPrim);
  }
}

TEST_F(PrimitivesTest, singleLedTest) {
  SCOPED_TRACE("Single LED Primitive Test");
  // test data:
  double frequency = 0.5;
  int position = 6;
  int length = 10;
  LEDPrimitive::Type type = LEDPrimitive::Type::Random;
  std::vector<bool> leds{true, false, true, true, false, true, true, false};

  // create a single motor primitive
  LEDPrimitive prim;
  prim.mFrequency = frequency;
  prim.mPositionBeat = position;
  prim.mLengthBeat = length;
  prim.mType = type;
  prim.mLeds = leds;

  // create datastream
  QByteArray dataArray;
  QDataStream dataStream(&dataArray, QIODevice::ReadWrite);
  AudioFile::applyDataStreamSettings(&dataStream);

  // serialize primitive
  prim.serializeToStream(&dataStream);

  // and create a new primitive from the stream:
  dataStream.device()->reset();

  LEDPrimitive checkPrim(&dataStream);

  // and verify data:
  checkLedPrimitivesEqual(prim, checkPrim);
}

TEST_F(PrimitivesTest, RandomLEDArrayTest) {
  SCOPED_TRACE("Array LED Primitive Test");
  // init random:
  std::random_device
      rd;  // Will be used to obtain a seed for the random number engine
  std::mt19937 gen(rd());  // Standard mersenne_twister_engine seeded with rd()
  std::uniform_int_distribution<int> positionDis(0, 100);
  std::uniform_real_distribution<double> frequencyDis(0.25, 4.0);
  const int N_TYPES = static_cast<int>(LEDPrimitive::Type::Random) + 1;
  const size_t N_CHECK = 100;
  std::vector<LEDPrimitive*> primitives(N_CHECK, new LEDPrimitive());
  primitives.reserve(N_CHECK);

  for (auto& p : primitives) {
    p->mFrequency = frequencyDis(gen);
    p->mPositionBeat = positionDis(gen);
    p->mLengthBeat = positionDis(gen);
    p->mType = static_cast<LEDPrimitive::Type>(positionDis(gen) % N_TYPES);
    for (auto&& e : p->mLeds) {
      e = !(positionDis(gen) % 2);
    }
  }

  // serialize all to stream:
  QByteArray dataArray;
  QDataStream dataStream(&dataArray, QIODevice::ReadWrite);
  AudioFile::applyDataStreamSettings(&dataStream);

  // serialize primitive
  for (const auto& p : primitives) {
    p->serializeToStream(&dataStream);
  }

  // and recreate primitives from stream
  dataStream.device()->reset();

  for (size_t i = 0; i < primitives.size(); ++i) {
    LEDPrimitive checkPrim(&dataStream);
    checkLedPrimitivesEqual(*primitives.at(i), checkPrim);
  }
}

void checkMotorPrimitivesEqual(const MotorPrimitive& prim,
                               const MotorPrimitive& checkPrim) {
  EXPECT_FLOAT_EQ(prim.mFrequency, checkPrim.mFrequency);
  EXPECT_EQ(prim.mPositionBeat, checkPrim.mPositionBeat);
  EXPECT_EQ(prim.mLengthBeat, checkPrim.mLengthBeat);
  EXPECT_EQ(prim.mType, checkPrim.mType);
  EXPECT_EQ(prim.mVelocity, checkPrim.mVelocity);
  EXPECT_EQ(prim.mVelocityRight, checkPrim.mVelocityRight);
}

void checkLedPrimitivesEqual(const LEDPrimitive& prim,
                             const LEDPrimitive& checkPrim) {
  EXPECT_FLOAT_EQ(prim.mFrequency, checkPrim.mFrequency);
  EXPECT_EQ(prim.mPositionBeat, checkPrim.mPositionBeat);
  EXPECT_EQ(prim.mLengthBeat, checkPrim.mLengthBeat);
  EXPECT_EQ(prim.mType, checkPrim.mType);
  EXPECT_EQ(prim.mLeds.size(), checkPrim.mLeds.size());
  for (size_t i = 0; i < prim.mLeds.size(); ++i) {
    EXPECT_EQ(prim.mLeds[i], checkPrim.mLeds[i]);
  }
}

}  // namespace

int main(int argc, char* argv[]) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
