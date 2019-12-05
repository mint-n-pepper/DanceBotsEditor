import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  width: Style.primitiveControl.width
  height: Style.primitiveControl.height
  color: Style.primitiveControl.moveColor
  property var keys: ['mot']
  property var beats: [Math.round(Style.primitiveControl.margin
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
    enabled = false
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
      if(result){
        // calculate average beat distance:
        averageBeatFrames = backend.getAverageBeatFrames();
        delegate.updatePrimitive();
        enabled = true
      }
    }
  }

	Column{
		id: typeRadio
		width: parent.width
    property int type
    onTypeChanged: {
      delegate.primitive.type = type
      delegate.updatePrimitive()
    }
    Row{
      Text{
        id: moveText
        width: Style.primitiveControl.labelsWidth
        text: qsTr("M O V E S")
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Style.primitiveControl.titlePixelSize
        rotation : 270
        anchors.verticalCenter: parent.verticalCenter
      }
      Column{
        RadioButton {
          id: twistRadio
          checked: true
          text: qsTr("Twist")
          onPressed: appWindow.grabFocus()
          onToggled: typeRadio.type=MotorPrimitive.Type.Twist
        }
        RadioButton {
          id: spinRadio
          text: qsTr("Spin")
          onPressed: appWindow.grabFocus()
          onToggled: typeRadio.type=MotorPrimitive.Type.Spin
        }
        RadioButton {
          id: backForthRadio
          text: qsTr("Back and Forth")
          onPressed: appWindow.grabFocus()
          onToggled: typeRadio.type=MotorPrimitive.Type.BackAndForth
        }
        RadioButton {
          id: driveStraightRadio
          text: qsTr("Drive Straight")
          onPressed: appWindow.grabFocus()
          onToggled: typeRadio.type=MotorPrimitive.Type.Straight
        }
        RadioButton {
          id: customRadio
          text: qsTr("Custom")
          onPressed: appWindow.grabFocus()
          onToggled: typeRadio.type=MotorPrimitive.Type.Custom
        }
      }
    }

    Row{
      id: leftSpeedSet
      Column{
        anchors.verticalCenter: velocitySlider.verticalCenter
        width: Style.primitiveControl.labelsWidth
        Text{
          x: Style.primitiveControl.margin
          text: customRadio.checked ? "Velocity L" : "Velocity"
        }
      }
      Slider{
        id: velocitySlider
        from: -100.0
        value: 50.0
        to: 100.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.velocity = value
        Keys.onPressed: appWindow.handleKey(event)
      }
      Text {
        id: velocityShow
        font.pixelSize: Style.primitiveControl.textPixelSize
        text: velocitySlider.value
        anchors.verticalCenter: velocitySlider.verticalCenter
      }
    }

    Row{
      id: frequencySet
      visible: twistRadio.checked || backForthRadio.checked
      Column{
        width: Style.primitiveControl.labelsWidth
        Text{
          x: Style.primitiveControl.margin
          text: "Frequency"
        }
        Text{
          x: Style.primitiveControl.margin
          text: "[1/beats]"
        }
      }
      property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0]
      Slider{
        id: frequencySlider
        from: 0.0
        value: 2.0
        to: frequencySet.frequencies.length - 1.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.frequency = frequencySet.frequencies[value]
        Keys.onPressed: appWindow.handleKey(event)
      }
      Text {
        id: frequencyShow
        font.pixelSize: Style.primitiveControl.textPixelSize
        text: frequencySet.frequencies[frequencySlider.value]
        anchors.verticalCenter: frequencySlider.verticalCenter
      }
    }

    Row{
      id: rightSpeedSet
      visible: customRadio.checked
      Column{
        anchors.verticalCenter: velocityRightSlider.verticalCenter
        width: Style.primitiveControl.labelsWidth
        Text{
          x: Style.primitiveControl.margin
          text: "Velocity R"
        }
      }
      Slider{
        id: velocityRightSlider
        from: -100.0
        value: 50.0
        to: 100.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.velocityRight = value
        Keys.onPressed: appWindow.handleKey(event)
      }
      Text {
        id: velocityRightShow
        font.pixelSize: Style.primitiveControl.textPixelSize
        text: velocityRightSlider.value
        anchors.verticalCenter: velocityRightSlider.verticalCenter
      }
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
    delegate.primitive.frequency = frequencySet.frequencies[frequencySlider.value]
    delegate.primitive.velocity = velocitySlider.value
    delegate.primitive.velocityRight = velocityRightSlider.value

    delegate.anchors.verticalCenter = undefined
    delegate.anchors.bottomMargin = Style.primitiveControl.margin
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

  function duplicatePrimitive(primOrig){
    var prim = primitiveFactory.createObject(root)
    prim.type = primOrig.type
    prim.positionBeat = primOrig.positionBeat
    prim.lengthBeat = primOrig.lengthBeat
    prim.frequency = primOrig.frequency
    prim.velocity = primOrig.velocity
    prim.velocityRight = primOrig.velocityRight
    return prim
  }
}
