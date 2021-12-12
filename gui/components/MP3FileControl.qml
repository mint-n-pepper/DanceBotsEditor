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
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12

import "../GuiStyle"

Rectangle{
	id: root

  height: Style.fileControl.height * width
  color: Style.palette.fc_background

  Component.onCompleted:{
    setDisabled()
    backend.setErrorDisplayTime(Style.fileControl.errorDisplayTimeMS)
  }

  property real controlWindowWidth

	function setEnabled(){
    textFields.enabled = true
		swapChannel.enabled = true
	}

	function setDisabled(){
		textFields.enabled = false
		swapChannel.enabled = false
	}

	Connections{
		target: backend
		onDoneLoading:{
      fileProcess.close()
      if(result){
        songTitleText.text = backend.songTitle
        songArtistText.text = backend.songArtist
        // update radio button from possible file-saved swap flag
        swapChannel.checked = backend.swapAudioChannels
        setEnabled()
      }
		}
	}

  Connections{
    target: backend
    onDoneSaving:{
      fileProcess.close()
    }
  }


  ConfirmPopup{
    id: loadConfirmPopup
		detailText: "Loading clears all moves and lights"
		text: "Are you sure?"
		function yesClicked(){
      loadDialog.open()
		}
	}

	ConfirmPopup{
		id: clearPopup
		detailText: "Clear all moves and lights"
		text: "Are you sure?"
		function yesClicked(){
      backend.motorPrimitives.clear()
      backend.ledPrimitives.clear()
		}
	}

  AboutPopup{
    id: aboutPopup
  }

  FileDialog {
    id: saveDialog
    folder: shortcuts.desktop
    nameFilters: [ "MP3 Files (*.mp3)"]
    title: "Save Dancebot Choreo"
    selectExisting: false
    selectMultiple: false
    sidebarVisible: true
    onAccepted: {
      fileProcess.open()
      var res = backend.saveMP3(saveDialog.fileUrl.toString())
    }
  }

	FileDialog {
		id: loadDialog
		folder: "file:///" + applicationDirPath + "/mp3_samples"
		nameFilters: [ "MP3 Files (*.mp3)"]
		title: "Select MP3 File to Load"
		selectExisting: true
		selectMultiple: false
    sidebarVisible: true
		onAccepted: {
      fileProcess.open()
      var res = backend.loadMP3(loadDialog.fileUrl.toString())
      var folder = fileUrl.toString()
      saveDialog.folder=folder.substr(0, folder.lastIndexOf("/"))
		}
	}

  Row{
    id: buttonRow
    anchors.right: root.right
    anchors.verticalCenter: root.verticalCenter
    spacing: Style.fileControl.buttonSpacing * root.height
		anchors.rightMargin: appWindow.guiMargin

		CheckBox{ //Swap Channel Checkbox
			id: swapChannel
      height: root.height * Style.fileControl.itemHeight * 0.8
			anchors.verticalCenter: parent.verticalCenter
			onCheckedChanged:
      {
        backend.swapAudioChannels = checked
        setRobotDataChanged()
        backend.audioPlayer.pause()
        appWindow.grabFocus()

      }
			focusPolicy: Qt.NoFocus
			font.pixelSize: height * Style.fileControl.buttonTextHeight * 1
			text: qsTr("Swap Audio")
			property color buttonColor: enabled ? Style.palette.fc_buttonDisabled
                                          : Style.palette.fc_buttonDisabled
      Component.onCompleted: checked = backend.swapAudioChannels // read initial swap state

			contentItem: Text {
				text: swapChannel.text
				font: swapChannel.font
				opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
        color: Style.palette.fc_buttonText
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				leftPadding: swapChannel.indicator.width + swapChannel.spacing * 1.1
			}

			indicator: Rectangle {
				width: root.height * Style.fileControl.itemHeight * 0.4
				height: root.height * Style.fileControl.itemHeight * 0.4
				x: swapChannel.leftPadding
				y: parent.height / 2 - height / 2
				radius: width / 2
				opacity: enabled ? Style.fileControl.buttonOpacityEnabled
												 : Style.fileControl.buttonOpacityDisabled
				color: Style.palette.fc_textfieldBoxBackground

				Rectangle {
					width: parent.width * 0.5
					height: parent.width * 0.5
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					radius: width / 2
					color: Style.palette.mp_yellow
					visible: swapChannel.checked
				}
			}

			background: Rectangle{
				anchors.fill: parent
				opacity: Style.fileControl.buttonOpacityDisabled
				color: parent.buttonColor
				radius: height * Style.fileControl.buttonRadius
			}
		}

    Button
    {
      id: loadButton
      width: root.height * Style.fileControl.buttonWidth
      height: root.height * Style.fileControl.itemHeight
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: height * Style.fileControl.buttonTextHeight
      font.bold: true
      text: "LOAD"
      focusPolicy: Qt.NoFocus
      property color buttonColor: enabled ? Style.palette.fc_buttonEnabled
                                          : Style.palette.fc_buttonDisabled

      contentItem: Text{
        text: parent.text
        font: parent.font
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                         : Style.fileControl.buttonOpacityDisabled
        color: Style.palette.fc_buttonText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }

      background: Rectangle{
        anchors.fill: parent
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                         : Style.fileControl.buttonOpacityDisabled
        color: parent.pressed ? Style.palette.fc_buttonPressed
               : parent.buttonColor
        border.color: Style.palette.fc_buttonText
        border.width: Style.fileControl.buttonBorderWidth * parent.height
        radius: height * Style.fileControl.buttonRadius

      }

      onClicked:
      {
        appWindow.grabFocus()
        appWindow.cleanDraggers()
        // confirm with user if the choreography is not empty
        if(motorBar.isNotEmpty || ledBar.isNotEmpty){
          loadConfirmPopup.open()
        }else{
          // otherwise, load directly
          loadDialog.open()
        }
      }
    }
    Button
    {
      id: saveButton
      width: root.height *Style.fileControl.buttonWidth
      height: root.height * Style.fileControl.itemHeight
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: height * Style.fileControl.buttonTextHeight
      enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
      font.bold: true
      text: "SAVE"
      focusPolicy: Qt.NoFocus
      property color buttonColor: enabled ? Style.palette.fc_buttonEnabled
                                          : Style.palette.fc_buttonDisabled

      contentItem: Text{
        text: parent.text
        font: parent.font
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
        color: Style.palette.fc_buttonText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }

      background: Rectangle{
        anchors.fill: parent
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                         : Style.fileControl.buttonOpacityDisabled
        color: parent.pressed ? Style.palette.fc_buttonPressed
               : parent.buttonColor
        border.color: Style.palette.fc_buttonText
        border.width: Style.fileControl.buttonBorderWidth * parent.height
        radius: height * Style.fileControl.buttonRadius
      }

      onClicked:
      {
        backend.audioPlayer.pause()
        appWindow.grabFocus()
        saveDialog.open()
      }
    }
    Button
    {
      id: clearButton
      width: root.height * Style.fileControl.buttonWidth
      height: root.height * Style.fileControl.itemHeight
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: height * Style.fileControl.buttonTextHeight
      font.bold: true
      text: "CLEAR"
      enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
      focusPolicy: Qt.NoFocus
      property color buttonColor: enabled ? Style.palette.fc_buttonEnabled
                                          : Style.palette.fc_buttonDisabled

      contentItem: Text{
        text: parent.text
        font: parent.font
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                         : Style.fileControl.buttonOpacityDisabled
        color: Style.palette.fc_buttonText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }

      background: Rectangle{
        anchors.fill: parent
        opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
        color: parent.pressed ? Style.palette.fc_buttonPressed
               : parent.buttonColor
        border.color: Style.palette.fc_buttonText
        border.width: Style.fileControl.buttonBorderWidth * parent.height
        radius: height * Style.fileControl.buttonRadius
      }

      onClicked:
      {
        backend.audioPlayer.pause()
        appWindow.grabFocus()
				clearPopup.open()
      }
    }
    Button
    {
      id: aboutButton
      height: root.height * Style.fileControl.itemHeight
      width: height
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: height * Style.fileControl.buttonTextHeight
      font.bold: true
      text: "?"
      focusPolicy: Qt.NoFocus
      property color buttonColor: Style.palette.fc_buttonEnabled

      contentItem: Text{
        text: parent.text
        font: parent.font
        color: Style.palette.fc_buttonText
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
      }

      background: Rectangle{
        anchors.fill: parent
        color: parent.pressed ? Style.palette.fc_buttonPressed
                              : parent.buttonColor
        border.color: Style.palette.fc_buttonText
        border.width: Style.fileControl.buttonBorderWidth * parent.height
        radius: height / 2
      }

      onClicked:
      {
        aboutPopup.open()
      }
    }
  } // buttons row

  Row{ // text fields column
    id: textFields
    anchors.left: root.left
    anchors.leftMargin: appWindow.guiMargin
    anchors.verticalCenter: root.verticalCenter
    spacing: controlWindowWidth * Style.fileControl.textBoxSpacing
    opacity: enabled ? Style.fileControl.buttonOpacityEnabled
                     : Style.fileControl.buttonOpacityDisabled
    Row{
      id: artistRow
      spacing: 0
      Rectangle {
        id: artistLabelBox
        height: root.height * Style.fileControl.itemHeight
        width: (controlWindowWidth - textFields.spacing - 2 * songTitleText.width)/2.0
        anchors.verticalCenter: parent.verticalCenter
        color: Style.palette.fc_labelBoxBackground

        Text{ // label
          id: artistLabel
          anchors.centerIn: parent
          text: "ARTIST"
          color: Style.palette.fc_labelBoxText
          font.pixelSize: Style.fileControl.labelTextSize
                          * songArtistText.height
        }
      }

      TextField{ // text edit field
        id: songArtistText
        selectByMouse: true
        color: Style.palette.fc_textFieldText
        maximumLength: 30 // fixed from mp3 tag limitation
        placeholderText: "Type Artist name..."
        font.pixelSize: Style.fileControl.textFieldTextSize * height
        anchors.verticalCenter: parent.verticalCenter
        width: controlWindowWidth * Style.fileControl.textBoxWidth
        height: root.height * Style.fileControl.itemHeight

        background: Rectangle {
          color: Style.palette.fc_textfieldBoxBackground
          border.color: Style.palette.fc_textfieldActiveBorder
          border.width:
            {parent.focus ?
                   parent.height * Style.fileControl.textBoxActiveBorderSize
                 : 0}
        }

        onFocusChanged: {
          if(!focus){
            backend.songArtist = text
          }
        }
        onAccepted: {
          appWindow.grabFocus()
        }
        Keys.onTabPressed: {
          songTitleText.focus = true
        }
      }
    }

    Row{
      id: titleRow
      spacing: 0
      Rectangle {
        id: titleLabelBox
        height: root.height * Style.fileControl.itemHeight
        width: (controlWindowWidth - textFields.spacing - 2 * songTitleText.width)/2.0
        anchors.verticalCenter: parent.verticalCenter
        color: Style.palette.fc_labelBoxBackground

        Text{ // label
          id: titleLabel
          anchors.centerIn: parent
          text: "TITLE"
          color: Style.palette.fc_labelBoxText
          font.pixelSize: Style.fileControl.labelTextSize * songTitleText.height
        }
      }


      TextField{
        id: songTitleText
        color: Style.palette.fc_textFieldText
        selectByMouse: true
        placeholderTextColor: Style.palette.fc_textFieldAltText
        maximumLength: 30 // fixed from mp3 tag limitation
        placeholderText: qsTr("Type Song title...")
        font.pixelSize: Style.fileControl.textFieldTextSize * height
        anchors.verticalCenter: parent.verticalCenter
        width: controlWindowWidth * Style.fileControl.textBoxWidth
        height: root.height * Style.fileControl.itemHeight

        background: Rectangle {
          color: Style.palette.fc_textfieldBoxBackground
          border.color: Style.palette.fc_textfieldActiveBorder
          border.width:{
            parent.focus ?
                   parent.height * Style.fileControl.textBoxActiveBorderSize
                 : 0
          }
        }

        onFocusChanged: {
          if(!focus){
            backend.songTitle = text
          }
        }
        onAccepted: {
          appWindow.grabFocus()
        }
        Keys.onTabPressed: {
          songArtistText.focus = true
        }
      }
    } // title row
  } // text row
} // box
