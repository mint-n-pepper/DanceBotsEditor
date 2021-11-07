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

import QtQuick 2.6
import QtQuick.Controls 2.12

Slider {
  id: root
  leftPadding: 0
  rightPadding: 0
  topPadding: 0
  bottomPadding: 0

  // size of slider bar relative to available height
  property real sliderBarSize: 0.2
  property real tickMarkHeight: 1.5
  property real tickMarkWidth: 1.0
  property real tickDX: bgRect.width / (numberOfSteps - 1)

  // color definitions
  property color backgroundColor: "grey"
  property color ticksColor: "grey"
  property color handleColor: "white"
  property color handleBorderColor: "black"
  property real handleBorderWidth: 0

  property int numberOfSteps: 2

  from: 0.0
  to: numberOfSteps - 1
  stepSize: 1
  snapMode: Slider.SnapAlways
  live: true

  background:Rectangle{
    id: bgRect
    width: root.availableWidth - root.availableHeight
    height: root.availableHeight * sliderBarSize
    x: root.leftPadding + root.availableHeight / 2
    y: root.topPadding + (root.availableHeight - height) / 2
    color: backgroundColor

    Repeater{
      id: tickMarks
      model: numberOfSteps
      property real tickHeight: bgRect.height * root.tickMarkHeight
      property real tickWidth: bgRect.height * root.tickMarkWidth

      Rectangle{
        y: (bgRect.height - tickMarks.tickHeight) / 2
        x: -tickMarks.tickWidth/2 + (root.tickDX * index)
        width: tickMarks.tickWidth
        height: tickMarks.tickHeight
        radius: height/2
        color: ticksColor
      }
    }
  }

  handle: Rectangle{
    x: root.leftPadding + root.visualPosition * bgRect.width
    y: root.topPadding
    height: root.availableHeight
    width: root.availableHeight
    radius: width/2
    color: handleColor
    border.color: handleBorderColor
    border.width: handleBorderWidth
  }
}
