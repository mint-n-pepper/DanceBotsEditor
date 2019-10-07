import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0

Rectangle{
	id: root
	width: 320
	height: 400

	color: "#F5E850"

	Component.onCompleted: setDisabled()
	
	function setEnabled(){
		typeRadio.enabled = true
	}

	function setDisabled(){
		typeRadio.enabled = false
	}

	Column{
		id: typeRadio
		width: parent.width

		RadioButton {
        	checked: true
        	text: qsTr("Drive Straight")
        	onToggled: motorPrimitive.type=MotorPrimitive.Type.eStraight
	    }
	    RadioButton {
	        text: qsTr("Spin")
	        onToggled: motorPrimitive.type=MotorPrimitive.Type.eSpin
	    }
	    RadioButton {
	        text: qsTr("Twist")
	        onToggled: motorPrimitive.type=MotorPrimitive.Type.eSpin
	    }
	}

	Rectangle{
		id: motorPrimitive
		width: 60
		height: 40
		radius: 3
		property alias type: dragPrimitive.type
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.leftMargin: 5
		anchors.bottomMargin: 5

		MotorPrimitive{
			id: dragPrimitive
		}

		Text
		{
			id: typeID
			text:
			{
			switch(dragPrimitive.type){
				case MotorPrimitive.eSpin:
					return "Spin";
					break;
				case MotorPrimitive.eStraight:
					return "Drive Straight";
					break;
				default:
					return "default";
					break;
				}
			}
		}
	}


}
