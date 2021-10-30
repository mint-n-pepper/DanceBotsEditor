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
import "../GuiStyle"

// fade rectangles:
Item{
  id: root
  property var contentPosition: 0
  property var contentWidth: 0
  property var distanceFromRight: contentWidth
                                  - contentPosition
                                  - width
  Item{
    id: fadeLeft
    height: parent.height
    width: parent.width * Style.timerBar.faderWidth;
    anchors.left: parent.left
    Rectangle{
      height: parent.width
      width: parent.height
      y: parent.height
      opacity: root.contentPosition / parent.width
      transform: Rotation { origin.x: 0; origin.y: 0; angle: -90}
      gradient: Gradient {
          GradientStop { position: 1.0; color: "transparent" }
          GradientStop { position: 0.0; color: Style.palette.tim_endFadeColor }
      }
    }
  }
  Item{
    id: fadeRight
    height: parent.height
    width: parent.width * Style.timerBar.faderWidth;
    anchors.right: parent.right
    Rectangle{
      height: parent.width
      width: parent.height
      y: parent.height
      opacity: root.distanceFromRight / parent.width
      transform: Rotation { origin.x: 0; origin.y: 0; angle: -90}
      gradient: Gradient {
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: Style.palette.tim_endFadeColor }
      }
    }
  }
}
