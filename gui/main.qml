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

  Flickable{
    width: parent.width
    height: timerBarColumn.height
    contentWidth: timerBarColumn.width
    contentHeight: timerBarColumn.height
    anchors.top: fileControl.bottom
    anchors.left: parent.left
    anchors.topMargin: Style.timerBar.margin
    anchors.bottomMargin: Style.timerBar.margin
    ScrollBar.horizontal: ScrollBar{}

    Column{
      id: timerBarColumn
      width: motorBar.width
      spacing: Style.timerBar.spacing
      TimerBar{
        id: motorBar
        width: 1000
        color: Style.motorControl.color
        keys: ["mot"]
      }
      TimerBar{
        id: ledBar
        width: 1000
        color: Style.ledControl.color
        keys: ["led"]
      }
    }
  }
}
