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

#ifndef SRC_PRIMITIVE_H_
#define SRC_PRIMITIVE_H_

#include <QDataStream>
#include <QDebug>
#include <QObject>
#include <vector>

/** \class BasePrimitive
 * \brief Base class providing common data members position, length, and
 * frequency to derived motor and led primitive classes.
 */
class BasePrimitive : public QObject {
  Q_OBJECT;
  Q_PROPERTY(int positionBeat MEMBER mPositionBeat NOTIFY positionBeatChanged);
  Q_PROPERTY(int lengthBeat MEMBER mLengthBeat NOTIFY lengthBeatChanged);
  Q_PROPERTY(double frequency MEMBER mFrequency NOTIFY frequencyChanged);

 public:
  explicit BasePrimitive(QObject* const parent) : QObject{parent} {}
  virtual ~BasePrimitive() {}

  // public members
  double mFrequency{1.0f};
  int mPositionBeat = 0u;
  int mLengthBeat = 0u;

  /**
   * \brief Serialize primitive to data stream
   */
  virtual void serializeToStream(QDataStream* stream) const = 0;

 signals:
  void positionBeatChanged(void);
  void lengthBeatChanged(void);
  void frequencyChanged(void);
};

/** \class MotorPrimitive
 * \brief Class providing data members for motor primitives.
 */
class MotorPrimitive : public BasePrimitive {
  Q_OBJECT;
  // make sure enum is scoped in QML as well
  Q_CLASSINFO("RegisterEnumClassesUnscoped", "false");

  Q_PROPERTY(int velocity MEMBER mVelocity NOTIFY velocityChanged);
  Q_PROPERTY(
      int velocityRight MEMBER mVelocityRight NOTIFY velocityRightChanged);
  Q_PROPERTY(Type type MEMBER mType NOTIFY typeChanged);

 public:
  enum class Type {
    Twist = 0,
    BackAndForth,
    Spin,
    Straight,
    Custom  // leave custom as last as used for counting types
  };
  Q_ENUM(Type);

  explicit MotorPrimitive(QObject* const parent = nullptr);

  /**
   * \brief Construct motor primitive from data stream
   */
  explicit MotorPrimitive(QDataStream* initStream,
                          QObject* const parent = nullptr);

  // public members
  int mVelocity{0};
  int mVelocityRight{0};
  Type mType{Type::Twist};

  /**
   * \brief Serialize motor primitive to data stream
   */
  void serializeToStream(QDataStream* stream) const override;

 signals:
  void velocityChanged(void);
  void velocityRightChanged(void);
  void typeChanged(void);
};

/** \class LEDPrimitive
 * \brief Class providing data members for LED primitives.
 */
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
    Random  // leave random as last as used for counting types
  };
  Q_ENUM(Type);

  explicit LEDPrimitive(QObject* const parent = nullptr);

  /**
   * \brief Construct motor primitive from data stream
   */
  explicit LEDPrimitive(QDataStream* initStream,
                        QObject* const parent = nullptr);

  // public members
  std::vector<bool> mLeds;
  Type mType{Type::KnightRider};

  /**
   * \brief Serialize motor primitive to data stream
   */
  void serializeToStream(QDataStream* stream) const override;

  /**
   * \brief Convert LED vector to single byte
   */
  quint8 getLedByte(void) const;

 signals:
  void ledsChanged(void);
  void typeChanged(void);
};

#endif  // SRC_PRIMITIVE_H_
