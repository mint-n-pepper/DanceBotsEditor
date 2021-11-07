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

pragma Singleton
import QtQuick 2.6

QtObject {
  id:root
  // frequency slider for motions
  property var motionFrequency:{
    'How many times the robot repeats the motion per beat'
  }
  // speed left wheel for custom motion
  property var speedLeft:{
    'Speed of left wheel'
  }
  // speed right wheel for custom motion
  property var speedRight:{
    'Speed of right wheel'
  }
  // speed for straight
  property var speedStraight:{
    'Speed of both wheels'
  }
  // speed for spin
  property var speedSpin:{
    'Speed of spin'
  }
  // amplitude for twist
  property var amplitudeTwist:{
    'How far the robot turns for the twists'
  }
  // amplitude for back and forth
  property var amplitudeBackAndForth:{
    'How far forward and backward the robot moves'
  }
  // Direction for left wheel
  property var directionLeftWheel:{
    'Direction of left wheel'
  }
  // Direction for right wheel
  property var directionRightWheel:{
    'Direction of right wheel'
  }
  // Direction for spin/straight
  property var directionSpinStraight:{
    'Direction of motion'
  }
  // Motion start direction for twist and back and forth
  property var startDirectionTwistBackAndForth:{
    'Start direction of motion'
  }

  // LEDS //

  // Frequency tooltips
  property var freqKnightRider:{
    'How many times per beat the three active LEDs travel back and forth'
  }
  property var freqRandom:{
    'How many times per beat the LEDs randomly change'
  }
  property var freqBlink:{
    'How many times per beat the LEDs turn on and off'
  }
  property var freqAlternate:{
    'How many times per beat the LEDs switch'
  }
  // LED selection tooltips:
  property var ledAlternate:{
    'Robot switches between selected and unselected LEDs'
  }
  property var ledBlink:{
    'Robot blinks selected LEDs'
  }
  property var ledConstant:{
    'Robot keeps on selected LEDs'
  }
}