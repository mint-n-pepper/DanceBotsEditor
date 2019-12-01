#ifndef PRIMITIVE_H_
#define PRIMITIVE_H_

#include<QObject>
#include<QDebug>
#include <QDataStream>

class BasePrimitive : public QObject {
  Q_OBJECT;
  Q_PROPERTY(int positionBeat MEMBER mPositionBeat NOTIFY positionBeatChanged);
  Q_PROPERTY(int lengthBeat MEMBER mLengthBeat NOTIFY lengthBeatChanged);
  Q_PROPERTY(double frequency MEMBER mFrequency NOTIFY frequencyChanged);


public:
  BasePrimitive(QObject* const parent) : QObject{ parent } {};
  virtual ~BasePrimitive() {};

  double mFrequency{ 1.0f };
  int mPositionBeat = 0u;
  int mLengthBeat = 0u;

  virtual void SerializeToStream(QDataStream& stream) const = 0;

signals:
  void positionBeatChanged(void);
  void lengthBeatChanged(void);
  void frequencyChanged(void);
};

class MotorPrimitive : public BasePrimitive {
  Q_OBJECT;
  // make sure enum is scoped in QML as well
  Q_CLASSINFO("RegisterEnumClassesUnscoped", "false");

  Q_PROPERTY(int velocity MEMBER mVelocity NOTIFY velocityChanged);
  Q_PROPERTY(int velocityRight MEMBER mVelocityRight NOTIFY velocityRightChanged);
  Q_PROPERTY(Type type MEMBER mType NOTIFY typeChanged);

public:
  enum class Type {
    Twist = 0,
    BackAndForth,
    Spin,
    Straight,
    Custom // leave custom as last as used for counting types
  };
  Q_ENUM(Type);

  MotorPrimitive(QObject* const parent = nullptr);
  MotorPrimitive(QDataStream& initStream,
                 QObject* const parent = nullptr);
  int mVelocity{ 0 };
  int mVelocityRight{ 0 };
  Type mType{ Type::Twist };

  void SerializeToStream(QDataStream& stream) const override;

signals:
  void velocityChanged(void);
  void velocityRightChanged(void);
  void typeChanged(void);
};

class LEDPrimitive : public BasePrimitive {
  Q_OBJECT;
  // make sure enum is scoped in QML as well
  Q_CLASSINFO("RegisterEnumClassesUnscoped", "false");

  Q_PROPERTY(std::vector<bool> leds MEMBER mLeds NOTIFY ledsChanged);
  Q_PROPERTY(Type type MEMBER mType NOTIFY typeChanged);

public:
  enum class Type {
    KnightRider = 0,
    Alternate,
    Blink,
    Constant,
    Random // leave random as last as used for counting types
  };
  Q_ENUM(Type);

  LEDPrimitive(QObject* const parent = nullptr);
  LEDPrimitive(QDataStream& initStream,
                 QObject* const parent = nullptr);
  std::vector<bool> mLeds;
  Type mType{ Type::KnightRider };

  void SerializeToStream(QDataStream& stream) const override;

signals:
  void ledsChanged(void);
  void typeChanged(void);
};

#endif // !PRIMITIVE_H_
