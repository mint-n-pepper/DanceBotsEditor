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
  property var keys: ['mot']
  property var beats: []
  property var primitiveColors: Style.motorPrimitive.colors
  property var primitiveTextIDs: Style.motorPrimitive.textID

	Component.onCompleted:{
    setDisabled();
    for(var i = 1; i < 6; ++i){
      // add beats at 80 bpm
      beats.push(i * 60/80*44100)
    }
  }

	function setEnabled(){
		typeRadio.enabled = true
    dummyBar.enabled = true
	}

	function setDisabled(){
		typeRadio.enabled = false
    dummyBar.enabled = false
	}

	Column{
		id: typeRadio
		width: parent.width
    property int type
    onTypeChanged: {
      dummyBar.delegate.primitive.type = type
      dummyBar.delegate.delegate.updatePrimitive()
    }
		RadioButton {
        	checked: true
        	text: qsTr("Drive Straight")
          onToggled: typeRadio.type=MotorPrimitive.Type.Straight
	    }
	    RadioButton {
	        text: qsTr("Spin")
	        onToggled: typeRadio.type=MotorPrimitive.Type.Spin
	    }
	    RadioButton {
	        text: qsTr("Twist")
	        onToggled: typeRadio.type=MotorPrimitive.Type.Twist
	    }
	}

	Rectangle{
		id: dummyBar
		width: parent.width
		height: Style.timerBar.height
    color: "transparent"
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.bottomMargin: 10

    property var delegate

    onDelegateChanged:{
      if(delegate === null){
        createDelegate()
      }
    }

    Component.onCompleted:{
      createDelegate();
      console.log("delegate active " + delegate.enabled)
    }

    function createDelegate(){
        delegate = delegateFactory.createObject(dummyBar,
      {primitive: primitiveFactory.createObject(delegate,
        { positionBeat: 0,
          lengthBeat: 4,
          type: typeRadio.type})
      })
    }

    Component{
        id: delegateFactory
        PrimitiveDelegate{}
    }

    Component{
        id: primitiveFactory
        MotorPrimitive{}
    }
	}


}
