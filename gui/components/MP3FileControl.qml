import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13

import "../GuiStyle"

Rectangle{
	id: root

  height: Style.fileControl.height * width
  color: Style.palette.fc_background

	Component.onCompleted: setDisabled()

	function setEnabled(){
    textFields.enabled = true
	}

	function setDisabled(){
		textFields.enabled = false
	}

	Connections{
		target: backend
		onDoneLoading:{
      fileProcess.close()
      if(result){
        songTitleText.text = backend.songTitle
        songArtistText.text = backend.songArtist
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

  MessageDialog {
    id: loadConfirm
    title: "Please Confirm"
    icon: StandardIcon.Question
    text: "Loading will clear the choreography. Are you sure?"
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
      loadDialog.open()
    }
  }

  MessageDialog {
    id: clearDialog
    title: "Please Confirm"
    icon: StandardIcon.Question
    text: "Are you sure you want to clear the choreography?"
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
      backend.motorPrimitives.clear()
      backend.ledPrimitives.clear()
    }
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
		folder: shortcuts.desktop
		nameFilters: [ "MP3 Files (*.mp3)"]
		title: "Select MP3 File to Load"
		selectExisting: true
		selectMultiple: false
    sidebarVisible: true
		onAccepted: {
      fileProcess.open()
			var res = backend.loadMP3(loadDialog.fileUrl.toString())
		}
	}

    Row{
      id: buttonRow
      width: root.width
      padding: Style.fileControl.buttonPadding * root.height
      spacing: Style.fileControl.buttonSpacing * root.height
			Button
			{
				id: loadButton
        width: root.height * Style.fileControl.buttonWidth
        height: root.height - buttonRow.padding * 2
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
				font.bold: true
        text: "LOAD"
        focusPolicy: Qt.NoFocus
        property color buttonColor: enabled ? Style.palette.fc_buttonEnabled
                                            : Style.palette.fc_buttonDisabled

        contentItem: Text{
          text: parent.text
          font: parent.font
					opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
          color: parent.enabled ? Style.palette.fc_buttonTextEnabled
                                : Style.palette.fc_buttonTextDisabled
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
					opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.fc_buttonPressed
                 : parent.buttonColor
					border.color: Style.palette.fc_buttonTextEnabled
			    border.width: Style.fileControl.buttonBorderWidth * parent.height
			    radius: Style.fileControl.buttonRadius

        }

				onClicked:
				{
          appWindow.grabFocus()
          appWindow.cleanDraggers()
          // confirm with user if the choreography is not empty
          if(motorBar.isNotEmpty || ledBar.isNotEmpty){
            loadConfirm.open()
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
        height: root.height - buttonRow.padding * 2
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
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
					color: parent.enabled ? Style.palette.fc_buttonTextEnabled
                                : Style.palette.fc_buttonTextDisabled
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
					opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
					color: parent.pressed ? Style.palette.fc_buttonPressed
                 : parent.buttonColor
					border.color: Style.palette.fc_buttonTextEnabled
					border.width: Style.fileControl.buttonBorderWidth * parent.height
					radius: Style.fileControl.buttonRadius
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
        height: root.height - buttonRow.padding * 2
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
				font.bold: true
        text: "CLEAR"
        enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
        focusPolicy: Qt.NoFocus
        property color buttonColor: enabled ? Style.palette.fc_buttonEnabled
                                            : Style.palette.fc_buttonDisabled

        contentItem: Text{
          text: parent.text
          font: parent.font
					opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
          color: parent.enabled ? Style.palette.fc_buttonTextEnabled
                                : Style.palette.fc_buttonTextDisabled
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
        }

        background: Rectangle{
          anchors.fill: parent
					opacity: enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled
          color: parent.pressed ? Style.palette.fc_buttonPressed
                 : parent.buttonColor
					border.color: Style.palette.fc_buttonTextEnabled
					border.width: Style.fileControl.buttonBorderWidth * parent.height
					radius: Style.fileControl.buttonRadius
        }

				onClicked:
				{
          backend.audioPlayer.pause()
          appWindow.grabFocus()
          clearDialog.open()
				}
			}
		} // buttons row

    Row{ // text fields column
			id: textFields
      padding: root.height * Style.fileControl.textBoxPadding
      //spacing: root.height * Style.fileControl.textBoxSpacing
      anchors.right: root.right
      anchors.verticalCenter: root.verticalCenter
			// opacity: parent.enabled ? Style.fileControl.buttonOpacityEnabled : Style.fileControl.buttonOpacityDisabled

			Rectangle {
				id: artistLabelBox
				height: root.height - 2 * textFields.padding
				width: root.width * Style.fileControl.labelBoxWidth
				color: Style.palette.fc_labelBoxBackground

	      Text{ // label
	        id: artistLabel
					anchors.centerIn: parent
	        text: "ARTIST "
	        color: Style.palette.fc_altTextColor
	        font.pixelSize: Style.fileControl.textSize * songArtistText.height
	      }
			}

      TextField{ // text edit field
        id: songArtistText
        height: artistLabelBox.height
        width: root.width * Style.fileControl.textBoxWidth

				color: Style.palette.fc_altTextColor
        maximumLength: 30 // fixed from mp3 tag limitation
        placeholderText: "Type Artist name..."
        font.pixelSize: Style.fileControl.textSize * height
        anchors.verticalCenter: textFields.verticalCenter

				background: Rectangle {
					width: parent.width
					height: parent.height
					color: Style.palette.fc_textfieldBoxBackground
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

			Rectangle {
				id: titleLabelBox
				height: root.height - 2 * textFields.padding
				width: root.width * Style.fileControl.labelBoxWidth
				color: Style.palette.fc_labelBoxBackground

				Text{ // label
					id: titleLabel
					anchors.centerIn: parent
					text: "TITLE"
					color: Style.palette.fc_altTextColor
					font.pixelSize: Style.fileControl.textSize * songTitleText.height
				}
			}


      TextField{
        id: songTitleText
				height: root.height - 2 * textFields.padding
				width: root.width * Style.fileControl.labelBoxWidth
        maximumLength: 30 // fixed from mp3 tag limitation
        placeholderText: qsTr("Type Song title...")
        font.pixelSize: Style.fileControl.textSize * height
        anchors.verticalCenter: textFields.verticalCenter

				background: Rectangle {
					width: parent.width
					height: parent.height
					color: Style.palette.fc_textfieldBoxBackground
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
    } // text row
} // box
