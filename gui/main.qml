import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3

import "components"

ApplicationWindow {
    id: root
    width: 800
    height: 450
    visible: true

	LoadProcessPopup{
		id: loadProcess
	}

	MP3FileControl{
		id: fileControl
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
}
