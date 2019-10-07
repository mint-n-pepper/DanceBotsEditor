import QtQuick 2.6
import QtQuick.Controls 2.0

import "components"

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    visible: true
	background: Rectangle{
		anchors.fill: parent
		color:"#ffe0e0"
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
