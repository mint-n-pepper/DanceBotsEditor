#ifndef PRIMITIVE_H_
#define PRIMITIVE_H_

#include<QObject>
#include<QDebug>

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
    eStraight = 0,
    eSpin,
    eTwist,
    eBackAndForth,
    eConstant
  };
  Q_ENUM(Type);

public:
  MotorPrimitive(QObject* const parent = nullptr) : BasePrimitive{ parent } {
  };
  int mVelocity{ 0 };
  int mVelocityRight{ 0 };
  Type mType{ Type::eTwist };

signals:
  void velocityChanged(void);
  void velocityRightChanged(void);
  void typeChanged(void);
};

#endif // !PRIMITIVE_H_
