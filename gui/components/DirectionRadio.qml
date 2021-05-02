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
import "../GuiStyle"

RadioButton {
  id: root
  leftPadding: 0
  rightPadding: 0
  bottomPadding: 0
  topPadding: 0
  indicator: Rectangle{
    id: indicatorBg
    height: root.height
    width: height
    radius: height / 2
    anchors.verticalCenter: root.verticalCenter
    color: Style.palette.pc_directionRadioBG
    Rectangle{
      height: parent.height * Style.primitiveControl.directionRadioIndicatorSize
      width: height
      radius: height / 2
      x: (parent.height - height) / 2
      y: x
      color: Style.palette.pc_directionRadioIndicator
      visible: root.checked
    }
  }

  contentItem: Text{
    text: root.text
    font.pixelSize: root.height * Style.primitiveControl.directionRadioTextSize
    leftPadding: parent.height * (1.0 + Style.primitiveControl.directionRadioTextSpacing)
    verticalAlignment: Text.AlignVCenter
    color: Style.palette.pc_controlsFonts
  }
}
