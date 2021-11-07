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
  modal: true
  width: appWindow.width * Style.confirmationDialog.width
  height: width * Style.confirmationDialog.heightRatio

  property var text: "Really close?"
  property var detailText: " "//"This will do something that is explained here."

  Overlay.modal: Rectangle{
    color: Style.palette.cd_windowOverlay
  }

  background: Rectangle{
    color: "transparent"
  }

  contentItem: Rectangle{
    id: bgRect
    width: root.width
    height: root.height
    color: Style.palette.cd_background
    Column{
      padding: appWindow.guiMargin
      spacing: appWindow.guiMargin
      width: bgRect.width
      anchors.horizontalCenter: bgRect.horizontalCenter
      Text{
        id: detailText
        text: root.detailText
        fontSizeMode: Text.Fit
        font.pixelSize: Style.confirmationDialog.detailTextFontSize
                        * bgRect.height
        width: parent.width - 2 * parent.padding
        horizontalAlignment: Text.AlignHCenter
        color: Style.palette.cd_textAndButtons
      }
      Text{
        id: questionText
        text: root.text
        font.pixelSize: root.height * Style.confirmationDialog.textFontSize
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: Style.palette.cd_textAndButtons
      }
    }

    Row{
      anchors.horizontalCenter: bgRect.horizontalCenter
      anchors.bottom: bgRect.bottom
      anchors.bottomMargin: appWindow.guiMargin
      spacing: appWindow.guiMargin * 2
      Button{
        id: yesButton
        width: bgRect.width * 0.2
        height: width * 0.7
        anchors.bottom: parent.bottom

        contentItem: Text{
          text: "YES"
          font.pixelSize: parent.height
                          * Style.confirmationDialog.buttonFontSize
          font.bold: true
          color: parent.pressed ? Style.palette.cd_buttonPressedText
                                : Style.palette.cd_textAndButtons
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
          color: parent.pressed ? Style.palette.cd_buttonPressedBG
                                : "transparent"
          border.color: Style.palette.cd_textAndButtons
          border.width: Style.confirmationDialog.buttonBorderWidth * height
          radius: Style.confirmationDialog.buttonRadius * height
        }

        onClicked:
        {
          yesClicked()
          root.close()
        }
      }

      Button{
        id: noButton
        width: bgRect.width * 0.2
        height: width * 0.7
        anchors.bottom: parent.bottom

        contentItem: Text{
          text: "NO"
          font.pixelSize: parent.height
                          * Style.confirmationDialog.buttonFontSize
          font.bold: true
          color: parent.pressed ? Style.palette.cd_buttonPressedText
                                : Style.palette.cd_textAndButtons
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
          color: parent.pressed ? Style.palette.cd_buttonPressedBG
                                : "transparent"
          border.color: Style.palette.cd_textAndButtons
          border.width: Style.confirmationDialog.buttonBorderWidth * height
          radius: Style.confirmationDialog.buttonRadius * height
        }

        onClicked:
        {
          noClicked()
          root.close()
        }
      }
    }
  }

  function yesClicked(){
    // functions to override on actions
  }

  function noClicked(){
    // functions to override on actions
  }
}
