/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2019 - mint & pepper
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
  modal: true
  width: appWindow.width * Style.aboutPopup.width
  height: appWindow.height - 2 * appWindow.guiMargin
  padding: appWindow.guiMargin

  property var textContent: AboutText{}

  Overlay.modal: Rectangle{
    color: Style.palette.ap_windowOverlay
  }

  background: Rectangle{
    color: "transparent"
  }

  contentItem: Rectangle{
    id: ciRect
    width: root.width
    height: root.height
    color: Style.palette.ap_background
    
    Column{
      spacing: 2
      width: parent.width - appWindow.guiMargin * 2

      Text{
        id: instructionText
        width: parent.width - appWindow.guiMargin * 2
        font.pixelSize: root.width * Style.aboutPopup.textFontSize
        textFormat: Text.RichText
        text: textContent.helpText
        padding: appWindow.guiMargin
      }

      Text{
        id: creditsText
        width: parent.width - appWindow.guiMargin * 2
        wrapMode: Text.WordWrap
        font.pixelSize: root.width * Style.aboutPopup.creditsTextSize
        textFormat: Text.RichText
        text: textContent.creditsText
        padding: appWindow.guiMargin
        onLinkActivated: Qt.openUrlExternally(link)
      }
    }
  }
}
