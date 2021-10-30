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
import QtQuick.Controls 2.0
import "../GuiStyle"

Slider {
  id: root
  leftPadding: 0
  rightPadding: 0
  topPadding: 0
  bottomPadding: 0

  // size of slider bar relative to available height
  property real sliderBarSize: 0.2

  // color definitions
  property color backgroundColor: "white"
  property color backgroundActiveColor: "#444444"
  property color handleColor: "white"
  property color handleBorderColor: "black"
  property real handleBorderWidth: 0

  background:Rectangle{
    id: bgRect
    width: root.availableWidth
    height: root.availableHeight * sliderBarSize
    x: root.leftPadding
    y: root.topPadding + (root.availableHeight - height) / 2
    color: backgroundColor
    radius: height/2
    Rectangle{
      width: root.visualPosition * bgRect.width
      height: bgRect.height
      radius: bgRect.radius
      color: backgroundActiveColor
    }
  }

  handle: Rectangle{
    x: root.leftPadding
       + root.visualPosition * (root.availableWidth
                                - height)
    y: root.topPadding
    height: root.availableHeight
    width: root.availableHeight
    radius: width/2
    color: handleColor
    border.color: handleBorderColor
    border.width: handleBorderWidth
  }
}
