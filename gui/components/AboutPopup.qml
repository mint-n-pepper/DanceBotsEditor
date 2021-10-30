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

Popup{
  id: root
  parent: Overlay.overlay
  anchors.centerIn: parent
  height: appWindow.height
  modal: true
  property var textContent: AboutText{}

  Overlay.modal: Rectangle{
    color: Style.palette.ap_windowOverlay
  }

  background: Rectangle{
    color: "transparent"
  }

  contentItem: Item{
    Text{
      id: instructionText
      anchors.horizontalCenter: parent.horizontalCenter
      width: contentWidth + 2 * padding
      font.pixelSize: appWindow.width * Style.aboutPopup.textFontSize
      textFormat: Text.RichText
      text: textContent.helpText
      padding: appWindow.guiMargin
      Rectangle{
        anchors.fill:parent
        color: Style.palette.ap_background
        z: -1
      }
    }

    Text{
      anchors.top: instructionText.bottom
      anchors.horizontalCenter: instructionText.horizontalCenter
      id: creditsText
      width: instructionText.width
      wrapMode: Text.WordWrap
      font.pixelSize: appWindow.width * Style.aboutPopup.creditsTextSize
      textFormat: Text.RichText
      text: textContent.creditsText
      padding: appWindow.guiMargin
      onLinkActivated: Qt.openUrlExternally(link)
      Rectangle{
        anchors.fill:parent
        color: Style.palette.ap_background
        z: -1
      }
    }
  }
}
