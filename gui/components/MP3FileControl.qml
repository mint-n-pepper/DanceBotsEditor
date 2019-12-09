import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import "../GuiStyle"

Rectangle{
	id: root
  width: Style.fileControl.width * parent.width
  height: Style.fileControl.heightRatio * width

	color: Style.fileControl.color

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

	Column{
    width: root.width
    spacing: root.width * Style.fileControl.textSpacing
    Row{
      id: buttonRow
      width: root.width
      padding: Style.fileControl.buttonPadding * root.width
      spacing: Style.fileControl.buttonSpacing * root.width
			Button
			{
				id: loadButton
        width: (root.width - 2 * (parent.padding + parent.spacing)) / 3
        height: width * Style.fileControl.buttonHeightRatio
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
        text: "Load"
        focusPolicy: Qt.NoFocus
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
        width: (parent.width - 2 * (parent.padding + parent.spacing)) / 3
        height: width * Style.fileControl.buttonHeightRatio
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
        enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
        text: "Save"
        focusPolicy: Qt.NoFocus
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
        width: (parent.width - 2 * (parent.padding + parent.spacing)) / 3
        height: width * Style.fileControl.buttonHeightRatio
        font.pixelSize: height * Style.fileControl.buttonTextHeightRatio
        text: "Clear"
        enabled: motorBar.isNotEmpty || ledBar.isNotEmpty
        focusPolicy: Qt.NoFocus
				onClicked:
				{
          backend.audioPlayer.pause()
          appWindow.grabFocus()
          clearDialog.open()
				}
			}
		} // buttons row

		Column{ // text fields column
			id: textFields
      width: root.width
      spacing: root.width * Style.fileControl.textSpacing
      Row{ // artist
        width: parent.width
        padding: width * Style.fileControl.textPadding
			  Text{ // label
				  id: artistLabel
          anchors.verticalCenter: songArtistText.verticalCenter
          width: root.width * Style.fileControl.textBoxLabelWidth
          text: "Artist: "
          font.pixelSize: Style.fileControl.textSize * songArtistText.height
			  }
			  TextField{ // text edit field
          id: songArtistText
          height: Style.fileControl.textBoxHeight * clearButton.height
          width: root.width - artistLabel.width - 2 * parent.padding
				  maximumLength: 30 // fixed from mp3 tag limitation
				  placeholderText: "Artist Name"
          font.pixelSize: Style.fileControl.textSize * height
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
      } // artist

      Row{ // title
        width: parent.width
        padding: width * Style.fileControl.textPadding
			  Text{ // label
				  id: titleLabel
          anchors.verticalCenter: songTitleText.verticalCenter
          text: "Title: "
          width: root.width * Style.fileControl.textBoxLabelWidth
          font.pixelSize: Style.fileControl.textSize * songTitleText.height
        }
			  TextField{
          id: songTitleText
          height: Style.fileControl.textBoxHeight * clearButton.height
          width: root.width - artistLabel.width - 2 * parent.padding
				  maximumLength: 30 // fixed from mp3 tag limitation
				  placeholderText: qsTr("Song Title")
          font.pixelSize: Style.fileControl.textSize * height
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
      } // title
    } // text column
  } // box column
} // box
