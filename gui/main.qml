import QtQuick 2.6
import QtQuick.Controls 2.0

import "Components"
import "GuiStyle"

ApplicationWindow {
    id: root
    width: Style.main.width
    height: Style.main.height
    visible: true
	background: Rectangle{
		anchors.fill: parent
		color: Style.main.color
	}
	

	LoadProcessPopup{
		id: loadProcess
	}

	MP3FileControl{
		id: fileControl
	}

	MotorPrimitiveControl{
		id: motorPrimitiveControl
		anchors.left: fileControl.right
	}
}
