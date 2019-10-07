#ifndef PRIMITIVE_H_
#define PRIMITIVE_H_

#include<QObject>

class BasePrimitive : public QObject {
  Q_OBJECT;

public:
  BasePrimitive(QObject* const parent) : QObject{ parent } {};

  quint32 mPositionBeat = 0u;
  quint32 mLengthBeat = 0u;
};

class MotorPrimitive : public BasePrimitive {
  Q_OBJECT
  // make sure enum is scoped in QML as well
  Q_CLASSINFO("RegisterEnumClassesUnscoped", "false")

public:
  enum class Type {
    eStraight,
    eSpin,
    eTwist,
    eBackAndForth,
    eConstant
  };
  Q_ENUM(Type);

public:
  MotorPrimitive(QObject* const parent = nullptr) : BasePrimitive{ parent } {};

  qreal mFrequency{ 1.0f };
  qint8 mVelocity{ 0 };
  qint8 mVelocityRight{ 0 };
  Type mType{ Type::eTwist };
};

#endif // !PRIMITIVE_H_
