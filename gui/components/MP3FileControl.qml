import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3

Rectangle{
	id: root
	width: 320
	height: 400

	color: "#5D7CE7"

	property alias songTitle: songTitleText.text
	property alias songArtist: songArtistText.text

	Component.onCompleted: setDisabled()
	
	function setEnabled(){
		textFields.enabled = true
		saveButton.enabled = true
		clearButton.enabled = true
	}

	function setDisabled(){
		textFields.enabled = false
		saveButton.enabled = false
		clearButton.enabled = false
	}

	Connections{
		target: backend
		onDoneLoading:{
			loadProcess.close()
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

	FileDialog {
		id: loadDialog
		folder: shortcuts.desktop
		nameFilters: [ "MP3 files (*.mp3)"]
		title: "Select MP3 File to Load"
		selectExisting: true
		selectMultiple: false
		onAccepted: {
			loadProcess.open()
			var res = backend.loadMP3(loadDialog.fileUrl.toString())
		}
	}

	Column
	{
		width: parent.width
		Row{
			padding: 5
			spacing: 5
			Button
			{
				id: loadButton
				width:100
				height:50
				text: "Load File"
				onClicked:
				{
					loadDialog.open()
				}
			}
			Button
			{
				id: saveButton
				width:100
				height:50
				text: "Save File"
				onClicked:
				{
					console.log("Click Save")
				}
			}
			Button
			{
				id: clearButton
				width:100
				height:50
				text: "Clear Choreo"
				onClicked:
				{
					console.log("Click Clear")
				}
			}
		}
	
		Column{
			id: textFields
			width: parent.width
			Item{
			width: parent.width
			height: songArtistText.height
			Text{
				id: artistLabel
				anchors.verticalCenter: parent.verticalCenter
				x: 5
				text: "Artist"
				font.pixelSize: 15
			}
			TextField
			{
				id:songArtistText
				anchors.left: artistLabel.right
				anchors.leftMargin: 5
				width: parent.width - 10 - artistLabel.width
				maximumLength: 30
				placeholderText: qsTr("Artist Name")
					onEditingFinished: backend.songArtist = text
			}
			}

			Text{
				text: "Title"
			}
			TextField
			{
				id:songTitleText
				maximumLength: 30
				width: parent.width
				placeholderText: qsTr("Song Title")
				onEditingFinished: backend.songTitle = text
			}
		}
	}

}
