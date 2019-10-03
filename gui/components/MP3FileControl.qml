import QtQuick 2.6
import QtQuick.Controls 2.0

Rectangle{
	id: root
	width: 150
	height: 250

	color: "lightgreen"

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

	Column
	{
		Row{
			Button
			{
				id: loadButton
				width:50
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
				width:50
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
				width:50
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
			enabled: false
			Text{
				text: "Artist"
			}
			TextField
			{
				id:songArtistText
				width: parent.width
				maximumLength: 30
				placeholderText: qsTr("Artist Name")
				onEditingFinished: backend.songArtist = text
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
