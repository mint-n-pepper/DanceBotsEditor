#include "Primitive.h"

MotorPrimitive::MotorPrimitive(QObject* const parent)
  : BasePrimitive{ parent } {
}

MotorPrimitive::MotorPrimitive(QDataStream& initStream, QObject* const parent)
  : BasePrimitive{ parent } {
  // and initialize members from data stream
  quint16 beatPosition = 0;
  quint16 beatLength = 0;
  quint8 type = 0;
  double frequency = 0.0;
  qint8 velocity = 0;
  qint8 velocityRight = 0;

  // get from stream:
  initStream >> beatPosition >> beatLength >> type >> frequency >> velocity
    >> velocityRight;

  // and write to members:
  mPositionBeat = beatPosition;
  mLengthBeat = beatLength;
  mType = static_cast<Type>(type);
  mFrequency = frequency;
  mVelocity = velocity;
  mVelocityRight = velocityRight;
}

void MotorPrimitive::serializeToStream(QDataStream& stream) const {
  // convert data members to suitable small data types
  quint16 beatPosition = static_cast<quint16>(mPositionBeat);
  quint16 beatLength = static_cast<quint16>(mLengthBeat);
  quint8 type = static_cast<quint8>(mType);
  double frequency = mFrequency;
  qint8 velocity = static_cast<qint8>(mVelocity);
  qint8 velocityRight = static_cast<qint8>(mVelocityRight);

  // and save to stream:
  stream << beatPosition << beatLength << type << frequency << velocity
    << velocityRight;
}

LEDPrimitive::LEDPrimitive(QObject* const parent)
  : BasePrimitive{ parent },
  mLeds(8, true)
{
};

LEDPrimitive::LEDPrimitive(QDataStream& initStream, QObject* const parent)
  : BasePrimitive{ parent },
  mLeds(8, true) {
  // and initialize members from data stream
  quint16 beatPosition = 0;
  quint16 beatLength = 0;
  quint8 type = 0;
  double frequency = 0.0;
  quint8 leds = 0;

  // get from stream:
  initStream >> beatPosition >> beatLength >> type >> frequency >> leds;

  // and write to members:
  mPositionBeat = beatPosition;
  mLengthBeat = beatLength;
  mType = static_cast<Type>(type);
  mFrequency = frequency;

  for(size_t i = 0; i < mLeds.size(); ++i) {
    mLeds[i] = leds & (1u << i);
  }
}

void LEDPrimitive::serializeToStream(QDataStream& stream) const {
  // convert data members to suitable small data types
  quint16 beatPosition = static_cast<quint16>(mPositionBeat);
  quint16 beatLength = static_cast<quint16>(mLengthBeat);
  quint8 type = static_cast<quint8>(mType);
  double frequency = mFrequency;

  // create single unsigned byte from LED array
  quint8 leds = getLedByte();

  // and save to stream:
  stream << beatPosition << beatLength << type << frequency << leds;
}

quint8 LEDPrimitive::getLedByte(void) const{
  quint8 leds = 0u;
  for(size_t i = 0; i < mLeds.size(); ++i) {
    if(mLeds[i]) {
      leds |= (1u << i);
    }
  }
  return leds;
}