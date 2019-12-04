import QtQuick 2.6	
import QtQuick.Controls 2.5

import "../GuiStyle"

Popup{
	id: root
  parent: Overlay.overlay
  anchors.centerIn: parent
  modal: true
	closePolicy: Popup.NoAutoClose
		
	background: Rectangle{
		anchors.centerIn: parent
    width: appWindow.width
    color: Style.fileProcessOverlay.backgroundColor
    height: 100
		Text{
			anchors.centerIn: parent
      text: backend.fileStatus
      font.pixelSize: Style.fileProcessOverlay.fontPixelSize
      color: Style.fileProcessOverlay.fontColor
		}
	}

}
