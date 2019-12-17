import QtQuick 2.6
import QtQuick.Controls 2.5

import "../GuiStyle"

Popup{
	id: root
  parent: Overlay.overlay
  anchors.centerIn: parent
  width: parent.width
  height: parent.height
  modal: true
	closePolicy: Popup.NoAutoClose

	background: Rectangle{
		anchors.centerIn: parent
    width: parent.width
    color: Style.palette.ovr_background
		opacity: Style.fileProcessOverlay.opacity
    height: Style.fileProcessOverlay.height * parent.height
		Text{
			anchors.centerIn: parent
      text: backend.fileStatus
      font.pixelSize: Style.fileProcessOverlay.fontSize * parent.height
      color: Style.palette.ovr_font
		}
	}

}
