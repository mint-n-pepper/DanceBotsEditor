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

#ifndef SRC_PRIMITIVE_TO_SIGNAL_H_
#define SRC_PRIMITIVE_TO_SIGNAL_H_

#include <vector>

#include "src/audio_file.h"
#include "src/primitive.h"

/** \class PrimitiveToSignal
 * \brief Converts motor and led primitives to data audio signal for Dancebot
 * to parse.
 */
class PrimitiveToSignal {
 public:
  /**
   * \brief Constructs a primitive to data signal converter
   *
   * \param[in] beatFrames - location of beats in audio frames
   * \param[in] audioFile - audioFile to write data signal to
   * \param[in] bitTimeZeroUS - zero bit timing in micro seconds
   */
  explicit PrimitiveToSignal(const std::vector<int>& beatFrames,
                             AudioFile* audioFile,
                             const size_t bitTimeZeroUS = 181u);

  /**
   * \brief Converts primitives to data signal
   *
   * \param[in] motorPrimitives - motor primitives to process
   * \param[in] ledPrimitives - led primitives to process
   */
  void convert(const QList<QObject*>& motorPrimitives,
               const QList<QObject*>& ledPrimitives);

 private:
  // CONSTANTS
  // default values if there is no primitive at a given beat
  static const qint8 defaultVelocity{0};
  static const quint8 defaultLEDs{0};
  static const double pi;

  // Structs:
  struct Data {
    qint8 velocityLeft{defaultVelocity};
    qint8 velocityRight{defaultVelocity};
    quint8 leds{defaultLEDs};
  };

  // VARIABLES
  // audio and beat data:
  const std::vector<int>& mBeatFrames;
  AudioFile* mAudioFile;

  float mDataLevel{0.75};
  quint8 mNknightRiderLeds{3};
  quint8 mKnightRiderByte{0};
  double mKnightRiderAmplitude{0.0};

  // time multipliers for one and reset signal pulses
  size_t oneTimeMultiplier{3};
  size_t resetTimeMultiplier{5};

  // bit timings in microseconds (US) and samples given sample rate
  size_t mBitTimeZeroUS{181};
  size_t mBitTimeOneUS{0};
  size_t mBitTimeResetUS{0};
  size_t mNzeroSamples{0};
  size_t mNoneSamples{0};
  size_t mNresetSamples{0};

  // random led variables to keep track of periods and values
  const LEDPrimitive* mLastRandomLEDPrimitive{nullptr};
  int mLastRandomLedPeriod{-1};
  quint8 mRandomLed{0};

  // command buffer and variable to keep track of command signal level
  std::vector<float> mCommandBuffer;
  float mCommandLevel;

  /**
   * \brief Generate random bits in mRandomLed for random primitive
   */
  void generateRandomLed(void);

  /**
   * \brief Calculate bit timings based on mBitTimeZeroUS and the multiplier
   * constants.
   */
  void updateBitTimings(void);

  /**
   * \brief Processes primitives for a single beat, writing the commands to the
   * audiofile member data signal. Should be called consecutively as it relies
   * on correct tracking of current data signal level (timings are read out by
   * edges on the signal so actual levels are not important)
   *
   * \param[in] currentBeat - the current beat location
   * \param[in] motorPrimitive - the motor primitive at the current beat, which
   * is active until the next beat. It may be null if there is no primitive set
   * at the beat. In this case, the default values defined above are used.
   * \param[in] ledPrimitive - the led primitive at the current beat.
   */
  void processPrimitivesAtBeat(const size_t currentBeat,
                               const MotorPrimitive* const motorPrimitive,
                               const LEDPrimitive* const ledPrimitive);

  /**
   * \brief Calculate current motor velocity based on primitive and current
   * time, expressed as beats, relative to the start beat of the primitive.
   *
   * \param[in] relativeBeat - the current beat time relative to the start of
   * the primitive
   * \param[in] motorPrimitive - the motor primitive to use for the calculation
   * \param[in] data - the command data to populate with calculated values
   */
  void getMotorVelocities(const double relativeBeat,
                          const MotorPrimitive* const motorPrimitive,
                          Data* data) const;

  /**
   * \brief Calculate current led states based on primitive and current
   * time, expressed as beats, relative to the start beat of the primitive.
   *
   * \param[in] relativeBeat - the current beat time relative to the start of
   * the primitive
   * \param[in] ledPrimitive - the led primitive to use for the calculation
   * \param[in] data - the command data to populate with calculated values
   */
  void getLEDs(const double relativeBeat,
               const LEDPrimitive* const ledPrimitive, Data* data);
  /**
   * \brief Writes given command data to data audio signal buffer
   *
   * \param[in] data - the command data to write to the data signal
   * \return The length of the command in audio samples
   */
  size_t generateCommand(const Data* const data);

  /**
   * \brief Writes a single byte to the command buffer
   *
   * \param[in] byte - the byte to write
   * \param[in] offset - the byte # offset in the command buffer
   * \return length of byte in audio samples
   */
  size_t writeByteToBuffer(const quint8 byte, const size_t offset);

  /**
   * \brief Converts a velocity to a byte to write to buffer, where bits 0..6
   * represent the velocity and bit 7 represents the direction (1=fwd)
   *
   * \param[in] velocity - the velocity to convert
   * \return the velocity in the above representation
   */
  quint8 velocityToByte(const qint8 velocity) const;
};

#endif  // SRC_PRIMITIVE_TO_SIGNAL_H_
