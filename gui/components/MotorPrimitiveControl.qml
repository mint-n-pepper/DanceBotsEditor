import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
	id: root
	width: Style.motorControl.width
	height: Style.motorControl.height

	color: Style.motorControl.color

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
	        onToggled: motorPrimitive.type=MotorPrimitive.Type.eTwist
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
			type: MotorPrimitive.Type.eStraight
			onTypeChanged: motorPrimitive.updatePrimitive();
		}

		function updatePrimitive(){
			switch(dragPrimitive.type)
			{
				case MotorPrimitive.Type.eSpin:
					typeID.text="Spin";
					break;
				case MotorPrimitive.Type.eStraight:
					typeID.text="Drive Straight";
					break;
				default:
					typeID.text="default";
					break;
			}
		}

		Text
		{
			id: typeID
			Component.onCompleted: motorPrimitive.updatePrimitive();
			text: "Test"
		}
	}


}
