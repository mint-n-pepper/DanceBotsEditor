#ifndef PRIMITIVE_TO_SIGNAL_H_
#define  PRIMITIVE_TO_SIGNAL_H_

#include "Primitive.h"
#include "AudioFile.h"

class PrimitiveToSignal {
public:
  PrimitiveToSignal(const std::vector<int>& beatFrames,
                    AudioFile& audioFile,
                    const size_t bitTimeZeroUS = 181u);

  void convert(const QList<QObject*>& motorPrimitives,
               const QList<QObject*>& ledPrimitives);

private:
  // CONSTANTS
  // default values if there is no primitive at a given beat
  static const qint8 defaultVelocity{ 0 };
  static const quint8 defaultLEDs{ 0 };
  static const double pi;

  // Structs:
  struct Data {
    qint8 velocityLeft{ defaultVelocity };
    qint8 velocityRight{ defaultVelocity };
    quint8 leds{ defaultLEDs };
  };

  // VARIABLES
  // audio and beat data:
  const std::vector<int>& mBeatFrames;
  AudioFile& mAudioFile;

  float mDataLevel{ 0.75 };
  quint8 mNknightRiderLeds{ 3 };
  quint8 mKnightRiderByte{ 0 };
  double mKnightRiderAmplitude{ 0.0 };

  // time multipliers for one and reset signal pulses
  size_t oneTimeMultiplier{ 3 };
  size_t resetTimeMultiplier{ 5 };

  // bit timings in microseconds (US) and samples given sample rate
  size_t mBitTimeZeroUS{ 181 };
  size_t mBitTimeOneUS{ 0 };
  size_t mBitTimeResetUS{ 0 };
  size_t mNzeroSamples{ 0 };
  size_t mNoneSamples{ 0 };
  size_t mNresetSamples{ 0 };

  // random led variables to keep track of periods and values
  const LEDPrimitive* mLastRandomLEDPrimitive{ nullptr };
  int mLastRandomLedPeriod{ -1 };
  quint8 mRandomLed{ 0 };

  // command buffer and variable to keep track of 
  std::vector<float> mCommandBuffer;
  float mCommandLevel;

  void generateRandomLed(void);

  void updateBitTimings(void);

  void processPrimitivesAtBeat(const size_t currentBeat,
                               const MotorPrimitive* const motorPrimitive,
                               const LEDPrimitive* const ledPrimitive);

  void getMotorVelocities(const double relativeBeat,
                          const MotorPrimitive* const motorPrimitive,
                          Data& data) const;

  void getLEDs(const double relativeBeat,
               const LEDPrimitive* const motorPrimitive,
               Data& data);

  size_t generateCommand(const Data& data);

  size_t writeByteToBuffer(const quint8 byte,
                           const size_t offset);

  quint8 velocityToByte(const qint8 velocity) const;

};

#endif
