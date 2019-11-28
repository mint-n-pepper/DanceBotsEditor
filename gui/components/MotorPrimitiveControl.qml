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
  property var beats: [Math.round(Style.motorControl.margin
  / Style.timerBar.frameToPixel)]
  property var primitiveColors: Style.motorPrimitive.colors
  property var primitiveTextIDs: Style.motorPrimitive.textID
  property var delegate: null
  property var averageBeatFrames: 60 * 441 // 100 bpm @ 44.1kHz

	Component.onCompleted:{
    // set the first beat at a fixed pixel distance from the left border of the
    // control box:
    setDummyBeats();
    createDelegate();
    setDisabled();
  }

  onDelegateChanged:{
    if(delegate === null){
      createDelegate()
    }
  }

  function setDummyBeats(){
    for(var i = 1; i < 5; ++i){
      // add beats at 100 bpm
      beats[i] = (i * averageBeatFrames) + beats[0]
    }
  }

  onAverageBeatFramesChanged:{
    setDummyBeats();
  }

  Connections{
	  target: backend
	  onDoneLoading:{
      // calculate average beat distance:
      averageBeatFrames = backend.getAverageBeatFrames();
      delegate.updatePrimitive();
      setEnabled();
    }
  }

	function setEnabled(){
		typeRadio.enabled = true
    delegate.enabled = true
	}

	function setDisabled(){
		typeRadio.enabled = false
    delegate.enabled = false
	}

	Column{
		id: typeRadio
		width: parent.width
    property int type
    onTypeChanged: {
      delegate.primitive.type = type
      delegate.updatePrimitive()
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


  function createDelegate(){
    delegate = delegateFactory.createObject(root)
    delegate.dragTarget = motorBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = typeRadio.type

    delegate.anchors.verticalCenter = undefined
    delegate.anchors.bottomMargin = Style.motorControl.margin
    delegate.anchors.bottom= root.bottom
    delegate.updatePrimitive()
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
