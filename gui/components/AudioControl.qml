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
import dancebots.backend 1.0
import QtGraphicalEffects 1.12
import "../GuiStyle"

Item {
  id: root
  property alias sliderPosition: songPositionSlider.visualPosition
  height: songPositionSlider.height + playControlItem.height
          + appWindow.guiMargin

  property int sliderHeight: width * Style.audioControl.sliderHeight
  property bool robotSoundNeedsUpdate: false
  property bool startPlayAfterRobotSoundUpdate: false
  property real songPositionMS: 0.0

  enabled: false

  Connections{
    target: backend
    onDoneLoading:{
      if(result){
        enabled = true
        backend.audioPlayer.setNotifyInterval(30);
        songPositionMS = 0.0
        songPositionSlider.to =
          backend.getAudioLengthInFrames() / backend.getSampleRate() * 1000;
      }
    }
  }

  Connections{
    target: backend.audioPlayer
    onNotify:{
      // set slider to current position in music,
      // but only if user is not dragging slider at the moment:
      if(!songPositionSlider.pressed){
        songPositionMS = currentPosMS
      }
    }
  }

  function togglePlay(){
    // check if robot sound needs to be recompiled:
    if(!backend.audioPlayer.isPlaying)
    {
      if(robotHumanButtons.runRobotSound && root.robotSoundNeedsUpdate)
      {
        fileProcess.open()
        backend.setPlayBackForRobots()
        root.startPlayAfterRobotSoundUpdate = true
      }
      else
      {
        backend.audioPlayer.togglePlay()
      }
    }
    else
    {
      backend.audioPlayer.togglePlay()
    }
  }

  ScalableSlider{
    id: songPositionSlider
    from: 0.0
    to: 1.0
    // width: root.width
    width: parent.width - 2 * appWindow.guiMargin
    anchors.horizontalCenter: root.horizontalCenter
    height: sliderHeight
    focusPolicy: Qt.NoFocus
    value: songPositionMS

    onPressedChanged:{
      appWindow.grabFocus()
      if(!pressed){
        backend.audioPlayer.seek(value)
      }
    }
    sliderBarSize: Style.primitiveControl.sliderBarSize
    backgroundColor: Style.palette.ac_songPositionSliderBar
    backgroundActiveColor: Style.palette.ac_songPositionSliderBarActivePart
    handleColor: Style.palette.ac_songPositionSliderHandle
    handleBorderColor: Style.palette.ac_songPositionSliderHandleBorder
    handleBorderWidth: Style.audioControl.buttonHeight
  }

  Item{
    id: playControlItem
    width: parent.width - 2 * appWindow.guiMargin
    anchors.top: songPositionSlider.bottom
    anchors.topMargin: appWindow.guiMargin
    anchors.horizontalCenter: root.horizontalCenter
    height: sliderHeight * Style.audioControl.buttonHeight

    Row{
      id: buttonRow
      spacing: Style.audioControl.buttonSpacing * root.sliderHeight
      anchors.verticalCenter: playControlItem.verticalCenter
      anchors.horizontalCenter: playControlItem.horizontalCenter
      Button
      {
        id: playButton
        focusPolicy: Qt.NoFocus
        width: playControlItem.height
        height: playControlItem.height
        property color buttonColor: Style.palette.ac_button

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: playImage
            anchors.centerIn: parent
            source: "../icons/play.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: playImage
            source: playImage
            color: Style.palette.ac_buttonIcon
            antialiasing: true
            visible: !backend.audioPlayer.isPlaying
          }

          Image{
            id: pauseImage
            anchors.centerIn: parent
            source: "../icons/pause.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: pauseImage
            source: pauseImage
            color: Style.palette.ac_buttonIcon
            antialiasing: true
            visible: backend.audioPlayer.isPlaying
          }
        }

        background: Rectangle{
          anchors.fill: parent
          radius: parent.height / 2
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          root.togglePlay()
        }
      }
      Button
      {
        id: stopButton
        focusPolicy: Qt.NoFocus
        width: playControlItem.height
        height: playControlItem.height
        property color buttonColor: Style.palette.ac_button

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: stopImage
            anchors.centerIn: parent
            source: "../icons/stop.svg"
            sourceSize.height: parent.height * Style.audioControl.buttonIconSize
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: stopImage
            source: stopImage
            color: Style.palette.ac_buttonIcon
            antialiasing: true
          }
        }

        background: Rectangle{
          anchors.fill: parent
          radius: parent.height / 2
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          backend.audioPlayer.stop()
        }
      }
    }

    Text{
      anchors.left: playControlItem.left
      anchors.verticalCenter: playControlItem.verticalCenter
      property var minutes: Math.floor(songPositionSlider.value / 60000.0)
      property var seconds: (songPositionSlider.value / 1000.0 - minutes * 60.0)
      property var secondString: "0" + seconds.toFixed(1)
      text: {
        // cut off zero front pad in case more than 10 seconds
        secondString.length > 4 ?
              minutes.toFixed(0) + ":" + secondString.substr(1)
            : minutes.toFixed(0) + ":" + secondString
      }
      font.pixelSize: Style.audioControl.timerFontSize
                      * root.sliderHeight
      color: Style.palette.ac_timerFont
    }

    Row{
      id: robotHumanButtons
      // spacing: Style.audioControl.buttonSpacing * root.sliderHeight
      anchors.verticalCenter: playControlItem.verticalCenter
      anchors.right: playControlItem.right
      spacing: Style.fileControl.buttonSpacing * root.height * 0.3
      property var runRobotSound: false


      Connections{
          target: backend
          onDoneSettingSound:{
            fileProcess.close()
            if(robotHumanButtons.runRobotSound){
              root.robotSoundNeedsUpdate = false
              if(root.startPlayAfterRobotSoundUpdate)
              {
                backend.audioPlayer.togglePlay()
                root.startPlayAfterRobotSoundUpdate = false
              }
            }
          }
      }

      Item{
        width: playControlItem.height * 1.9
        height: playControlItem.height * 0.7

        Image{
          id: instaIcon
          source: "../icons/insta.svg"
          sourceSize.width: parent.height * 0.5
          antialiasing: true
          visible: true
        }

        ColorOverlay{
          anchors.fill: instaIcon
          source: instaIcon
          color: Style.palette.mp_yellow
          antialiasing: true
          visible: true
        }


        Item{
          width: playControlItem.height * 1.7
          height: playControlItem.height

          Text {
            id: instaText
            text: qsTr("INSTA")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            topPadding: playControlItem.height * 0.1
            leftPadding: playControlItem.height * 0.5
            color: Style.palette.mp_yellow
            font.pixelSize: parent.height * Style.fileControl.buttonTextHeight * 0.9
          }
        }

      }


      Button{
        id: robotSound
        focusPolicy: Qt.NoFocus
        width: playControlItem.height * 2
        height: playControlItem.height * 0.8
        text: qsTr("ROBOT")
        font.pixelSize: height * Style.fileControl.buttonTextHeight * 1
        property color buttonColor: enabled ? Style.palette.ac_instaPlayRobot
          : Style.palette.fc_buttonDisabled

        contentItem: Text{
          text: parent.text
          font: parent.font
          opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                           : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.fc_buttonText
                                : Style.palette.ac_instaPlayRobot
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
          opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                          : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.ac_instaPlayRobot
                                : Style.palette.mw_background
          border.color: Style.palette.ac_instaPlayRobot
          border.width: Style.fileControl.buttonBorderWidth * parent.height
          radius: height * Style.fileControl.buttonRadius
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          fileProcess.open()
          robotHumanButtons.runRobotSound = true
          backend.setPlayBackForRobots()
        }
      }

      Button{
        id: humanSound
        focusPolicy: Qt.NoFocus
        width: playControlItem.height * 2
        height: playControlItem.height * 0.8
        text: qsTr("HUMAN")
        font.pixelSize: height * Style.fileControl.buttonTextHeight * 1
        property color buttonColor: enabled ? Style.palette.ac_instaPlayHuman
          : Style.palette.fc_buttonDisabled

        contentItem: Text{
          text: parent.text
          font: parent.font
          opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                           : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.fc_buttonText
                                : Style.palette.ac_instaPlayHuman
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
          opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                          : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.ac_instaPlayHuman
                                : Style.palette.mw_background
          border.color: Style.palette.ac_instaPlayHuman
          border.width: Style.fileControl.buttonBorderWidth * parent.height
          radius: height * Style.fileControl.buttonRadius
        }

        onPressed: appWindow.grabFocus()
        onClicked:
        {
          fileProcess.open()
          robotHumanButtons.runRobotSound = false
          backend.setPlayBackForHumans()
        }
      }
    }
  } // play control item
}
