import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import "../GuiStyle"

Rectangle{
	id: root
	width: Style.fileControl.width
	height: Style.fileControl.height

	color: Style.fileControl.color

	property alias songTitle: songTitleText.text
	property alias songArtist: songArtistText.text

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
			fileControl.songTitle = backend.songTitle
			fileControl.songArtist = backend.songArtist
			fileControl.setEnabled()
			if(result){
				console.log('load success in event')
			}else{
				console.log('load fail in event')
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
    id: clearDialog
    title: "Please Confirm Clear"
    icon: StandardIcon.Question
    text: "Are you sure you want to clear choreography?"
    standardButtons: StandardButton.Yes | StandardButton.No
    onYes: {
      backend.motorPrimitives.clear()
      backend.ledPrimitives.clear()
    }
    onNo: console.log("ok not clearing")
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

	Column{
		width: parent.width

		Row{
			padding: Style.fileControl.buttonPadding
			spacing: Style.fileControl.buttonSpacing

			Button
			{
				id: loadButton
				width:Style.fileControl.buttonWidth
				height:Style.fileControl.buttonHeight
        text: "Load"
        focusPolicy: Qt.NoFocus
				onClicked:
				{
					loadDialog.open()
				}
			}
			Button
			{
				id: saveButton
				width:Style.fileControl.buttonWidth
				height:Style.fileControl.buttonHeight
        enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
        text: "Save"
        focusPolicy: Qt.NoFocus
				onClicked:
				{
          saveDialog.open()
				}
			}
			Button
			{
				id: clearButton
				width:Style.fileControl.buttonWidth
				height:Style.fileControl.buttonHeight
        text: "Clear"
        enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
        focusPolicy: Qt.NoFocus
				onClicked:
				{
          clearDialog.open()
				}
			}
		} // buttons row

		Column{ // text fields column
			id: textFields
			width: parent.width
      spacing: 2*Style.fileControl.textLabelSpacing

      Item{ // artist
			  width: parent.width
			  height: songArtistText.height
			  Text{ // label
				  id: artistLabel
				  anchors.verticalCenter: parent.verticalCenter
				  x: Style.fileControl.textLabelMargin
				  text: "Artist"
				  font.pixelSize: Style.fileControl.textLabelPixelSize
			  }
			  TextField{ // text edit field
				  id:songArtistText
				  anchors.left: artistLabel.right
				  anchors.leftMargin: Style.fileControl.textLabelMargin
          anchors.right: parent.right
          anchors.rightMargin: Style.fileControl.textLabelMargin
				  maximumLength: 30 // fixed from mp3 tag limitation
				  placeholderText: "Artist Name"
          onEditingFinished:{
            backend.songArtist = text
            focus=false
          }
			  }
			} // artist

      Item{ // title
			  width: parent.width
			  height: songArtistText.height
			  Text{ // label
				  id: titleLabel
				  anchors.verticalCenter: parent.verticalCenter
				  text: "Title"
          x: Style.fileControl.textLabelMargin
          font.pixelSize: Style.fileControl.textLabelPixelSize
			  }
			  TextField{
				  id:songTitleText
          x: songArtistText.x
          width: songArtistText.width
				  maximumLength: 30 // fixed from mp3 tag limitation
				  placeholderText: qsTr("Song Title")
          onEditingFinished:{
            backend.songTitle = text
            focus=false
          }
			  }
      } // title
    } // text column
  } // box column
} // box
