import QtQuick 2.6	
import QtQuick.Controls 2.5

Popup{
	id: root
	parent: Overlay.overlay
	anchors.centerIn: parent
	modal: true
	closePolicy: Popup.NoAutoClose
		
	background: Rectangle{
		anchors.centerIn: parent
		width: 200
		height: 100
		border.width: 10
		border.color: "white"
		radius: 10
		Text{
			anchors.centerIn: parent
			text: backend.loadStatus
		}
	}

}