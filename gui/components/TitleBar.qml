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
import QtGraphicalEffects 1.12
import "../GuiStyle"

Rectangle{
  id: root
  height: width * Style.titleBar.height
  color: Style.palette.tb_background

  Text{
    anchors.verticalCenter: titleBar.verticalCenter
    color: Style.palette.tb_font
    text: "DanceBots Editor"
    font.pixelSize: titleBar.height * Style.titleBar.fontSize
    font.letterSpacing: Style.titleBar.fontLetterSpacing
    font.bold: Style.primitives.textBold
    leftPadding: titleBar.height * Style.titleBar.horizontalPadding
  }

  Image {
    id: mintPepperLogo
    anchors.verticalCenter: titleBar.verticalCenter
    source: "../icons/mp_logo.svg"
    sourceSize.height: titleBar.height * Style.titleBar.logoSize
    anchors.right: titleBar.right
    anchors.rightMargin: titleBar.height * Style.titleBar.horizontalPadding
    antialiasing: true
    visible: false
  }
  ColorOverlay{
    anchors.fill: mintPepperLogo
    source: mintPepperLogo
    color: Style.palette.tb_logo
    antialiasing: true
  }
}
