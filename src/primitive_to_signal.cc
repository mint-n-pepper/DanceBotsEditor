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

#include "src/primitive_to_signal.h"

#include <algorithm>
#include <cmath>
#include <random>

PrimitiveToSignal::PrimitiveToSignal(const std::vector<int>& beatFrames,
                                     AudioFile* audioFile,
                                     const size_t bitTimeZeroUS)
    : mBeatFrames{beatFrames},
      mAudioFile{audioFile},
      mBitTimeZeroUS{bitTimeZeroUS} {
  // initialize other bit timings based on zero time
  updateBitTimings();
  mCommandLevel = mDataLevel;
};

const double PrimitiveToSignal::pi{3.14159265358979323846};

void PrimitiveToSignal::generateRandomLed(void) {
  static std::default_random_engine gen;
  static std::uniform_int_distribution<int> dist(0, 255u);

  mRandomLed = static_cast<quint8>(dist(gen));
}

void PrimitiveToSignal::updateBitTimings(void) {
  // set one and reset timings based on zero time:
  mBitTimeOneUS = oneTimeMultiplier * mBitTimeZeroUS;
  mBitTimeResetUS = resetTimeMultiplier * mBitTimeZeroUS;

  // and convert to sample timings:
  mNzeroSamples = (mBitTimeZeroUS * mAudioFile->sampleRate) / 1e6 + 1;
  mNoneSamples = (mBitTimeOneUS * mAudioFile->sampleRate) / 1e6 + 1;
  mNresetSamples = (mBitTimeResetUS * mAudioFile->sampleRate) / 1e6 + 1;
}

void PrimitiveToSignal::convert(const QList<QObject*>& motorPrimitives,
                                const QList<QObject*>& ledPrimitives) {
  // first, create an array of primitive pointers to have a straightforward map
  // between beats and primitives:
  std::vector<const MotorPrimitive*> motorPrimitiveMap(mBeatFrames.size() - 1,
                                                       nullptr);
  std::vector<const LEDPrimitive*> ledPrimitiveMap(mBeatFrames.size() - 1,
                                                   nullptr);

  for (const QObject* const qo : motorPrimitives) {
    const MotorPrimitive* const mp =
        reinterpret_cast<const MotorPrimitive*>(qo);
    size_t start = mp->mPositionBeat;
    size_t end = start + mp->mLengthBeat;
    for (size_t i = mp->mPositionBeat; i < end; ++i) {
      motorPrimitiveMap[i] = mp;
    }
  }

  for (const QObject* const qo : ledPrimitives) {
    const LEDPrimitive* const lp = reinterpret_cast<const LEDPrimitive*>(qo);
    size_t start = lp->mPositionBeat;
    size_t end = start + lp->mLengthBeat;
    for (size_t i = lp->mPositionBeat; i < end; ++i) {
      ledPrimitiveMap[i] = lp;
    }
  }

  // prepare some primitive variables:
  mKnightRiderByte = 0u;
  for (size_t i = 0; i < mNknightRiderLeds; ++i) {
    mKnightRiderByte |= (1u << i);
  }
  mKnightRiderAmplitude = (8.0 - mNknightRiderLeds) / 2.0;
  mLastRandomLEDPrimitive = nullptr;

  // reset the data level and prepare the command buffer:
  mCommandLevel = mDataLevel;
  mCommandBuffer.resize(mNresetSamples + 24 * mNoneSamples);

  // now iterate through all beats, processing the primitives at the given beat
  for (size_t i = 0; i < mBeatFrames.size() - 1; ++i) {
    processPrimitivesAtBeat(i, motorPrimitiveMap[i], ledPrimitiveMap[i]);
  }

  // Done!
}

void PrimitiveToSignal::processPrimitivesAtBeat(
    const size_t currentBeat, const MotorPrimitive* const motorPrimitive,
    const LEDPrimitive* const ledPrimitive) {
  // init current and final frame, and their difference
  const size_t startFrame = mBeatFrames[currentBeat];
  const size_t endFrame = mBeatFrames[currentBeat + 1];
  const size_t nFrames = endFrame - startFrame;
  size_t currentFrame = startFrame;

  // go through all beat frames
  while (currentFrame < endFrame) {
    // struct to write velocities and leds to
    Data data;
    // current beat fraction based on current frame
    double beatFraction =
        static_cast<double>(currentFrame - startFrame) / nFrames;

    // get motor velocities, if there is a motor primitive:
    if (motorPrimitive) {
      double relativeBeat =
          (currentBeat - motorPrimitive->mPositionBeat) + beatFraction;
      getMotorVelocities(relativeBeat, motorPrimitive, &data);
    }

    if (ledPrimitive) {
      double relativeBeat =
          (currentBeat - ledPrimitive->mPositionBeat) + beatFraction;
      getLEDs(relativeBeat, ledPrimitive, &data);
    }
    float tempCommandLevel = mCommandLevel;
    size_t commandLength = generateCommand(&data);
    if (commandLength + currentFrame < endFrame) {
      // the command fits, write to audio data:
      std::copy(mCommandBuffer.begin(), mCommandBuffer.begin() + commandLength,
                mAudioFile->mFloatData.begin() + currentFrame);
      currentFrame += commandLength;
    } else {
      // not enough space to write command. Restore command level to last:
      mCommandLevel = tempCommandLevel;
      // Either write an additional zero or not, depending on
      // distance to next beat:
      if (endFrame - currentFrame < mNzeroSamples / 2) {
        // do not toggle level but let next reset pulse finish off last command
        // of this beat
        mCommandLevel = -mCommandLevel;
      }
      for (size_t i = currentFrame; i < endFrame; ++i) {
        mAudioFile->mFloatData[i] = mCommandLevel;
      }
      currentFrame = endFrame;
      mCommandLevel = -mCommandLevel;
    }
  }
}

void PrimitiveToSignal::getMotorVelocities(
    const double relativeBeat, const MotorPrimitive* const motorPrimitive,
    Data* data) const {
  switch (motorPrimitive->mType) {
    case MotorPrimitive::Type::BackAndForth: {
      double angle = relativeBeat * motorPrimitive->mFrequency * 2.0 * pi;
      data->velocityLeft =
          static_cast<qint8>(round(motorPrimitive->mVelocity * sin(angle)));
      data->velocityRight = data->velocityLeft;
      break;
    }
    case MotorPrimitive::Type::Custom:
      data->velocityLeft = motorPrimitive->mVelocity;
      data->velocityRight = motorPrimitive->mVelocityRight;
      break;
    case MotorPrimitive::Type::Spin:
      data->velocityLeft = -motorPrimitive->mVelocity;
      data->velocityRight = motorPrimitive->mVelocity;
      break;
    case MotorPrimitive::Type::Straight:
      data->velocityLeft = motorPrimitive->mVelocity;
      data->velocityRight = motorPrimitive->mVelocity;
      break;
    case MotorPrimitive::Type::Twist: {
      double angle = relativeBeat * motorPrimitive->mFrequency * 2.0 * pi;
      data->velocityLeft =
          static_cast<qint8>(-round(motorPrimitive->mVelocity * sin(angle)));
      data->velocityRight = -data->velocityLeft;
      break;
    }
  }
}

void PrimitiveToSignal::getLEDs(const double relativeBeat,
                                const LEDPrimitive* const ledPrimitive,
                                Data* data) {
  switch (ledPrimitive->mType) {
    case LEDPrimitive::Type::Alternate: {
      quint32 period =
          static_cast<quint32>(relativeBeat * 2.0 * ledPrimitive->mFrequency);
      if (period % 2) {
        // inverted
        data->leds = ~ledPrimitive->getLedByte();
      } else {
        data->leds = ledPrimitive->getLedByte();
      }
      break;
    }
    case LEDPrimitive::Type::Blink: {
      quint32 period =
          static_cast<quint32>(relativeBeat * 2.0 * ledPrimitive->mFrequency);
      if (period % 2) {
        // turn off
        data->leds = 0;
      } else {
        data->leds = ledPrimitive->getLedByte();
      }
      break;
    }
    case LEDPrimitive::Type::Constant:
      data->leds = ledPrimitive->getLedByte();
      break;
    case LEDPrimitive::Type::KnightRider: {
      double angle = ledPrimitive->mFrequency * relativeBeat * 2.0 * pi;
      quint8 pos = static_cast<quint8>(
          round(mKnightRiderAmplitude * (1.0 + sin(angle))));
      data->leds = mKnightRiderByte << pos;
      break;
    }
    case LEDPrimitive::Type::Random: {
      // check if new primitive is active:
      if (mLastRandomLEDPrimitive != ledPrimitive) {
        mLastRandomLedPeriod = -1;
        mLastRandomLEDPrimitive = ledPrimitive;
      }
      // get current period
      int period = static_cast<int>(relativeBeat * ledPrimitive->mFrequency);

      if (period != mLastRandomLedPeriod) {
        generateRandomLed();
        mLastRandomLedPeriod = period;
      }

      data->leds = mRandomLed;
      break;
    }
  }
}

size_t PrimitiveToSignal::generateCommand(const Data* const data) {
  size_t length = mNresetSamples;
  for (size_t i = 0; i < mNresetSamples; ++i) {
    mCommandBuffer[i] = mCommandLevel;
  }
  // flip command level
  mCommandLevel = -mCommandLevel;

  quint8 leftVelByte = velocityToByte(data->velocityLeft);
  quint8 rightVelByte = velocityToByte(data->velocityRight);

  length += writeByteToBuffer(leftVelByte, length);
  length += writeByteToBuffer(rightVelByte, length);
  length += writeByteToBuffer(data->leds, length);
  return length;
}

size_t PrimitiveToSignal::writeByteToBuffer(const quint8 byte,
                                            const size_t offset) {
  size_t length = 0;

  for (int i = 0; i < 8; ++i) {
    const size_t nFrameWrite = byte & (1u << i) ? mNoneSamples : mNzeroSamples;
    for (size_t j = 0; j < nFrameWrite; ++j) {
      mCommandBuffer[j + offset + length] = mCommandLevel;
    }
    length += nFrameWrite;
    mCommandLevel = -mCommandLevel;
  }
  return length;
}

quint8 PrimitiveToSignal::velocityToByte(const qint8 velocity) const {
  quint8 velocityByte = 0;
  if (velocity <= 0) {
    velocityByte = (-velocity) & 0x7F;
  } else {
    velocityByte = velocity | 0x80;
  }
  return velocityByte;
}
