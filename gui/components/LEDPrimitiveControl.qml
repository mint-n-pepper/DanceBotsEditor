import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  width: Style.primitiveControl.width
  height: Style.primitiveControl.height
  color: Style.primitiveControl.ledColor
  property var keys: ['led']
  property var beats: [Math.round(Style.primitiveControl.margin
  / Style.timerBar.frameToPixel)]
  property var primitiveColors: Style.ledPrimitive.colors
  property var primitiveTextIDs: Style.ledPrimitive.textID
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
    Row{
      Text{
        id: blinkieText
        width: Style.primitiveControl.labelsWidth
        text: qsTr("B L I N K I E S")
        font.pixelSize: Style.primitiveControl.titlePixelSize
        rotation : 270
        anchors.verticalCenter: parent.verticalCenter
      }
      Column{
        RadioButton {
          id: knightRiderRadio
          checked: true
          text: qsTr("KnightRider")
          onToggled: typeRadio.type=LEDPrimitive.Type.KnightRider
        }
        RadioButton {
          id: alternateRadio
          text: qsTr("Alternate")
          onToggled: typeRadio.type=LEDPrimitive.Type.Alternate
        }
        RadioButton {
          id: blinkRadio
          text: qsTr("Blink")
          onToggled: typeRadio.type=LEDPrimitive.Type.Blink
        }
        RadioButton {
          id: constantRadio
          text: qsTr("Constant")
          onToggled: typeRadio.type=LEDPrimitive.Type.Constant
        }
        RadioButton {
          id: randomRadio
          text: qsTr("Random")
          onToggled: typeRadio.type=LEDPrimitive.Type.Random
        }
      }
    }

    Row{
      id: frequencySet
      visible: !constantRadio.checked
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
      property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0, 1.5, 2.0, 3.0, 4.0]
      Slider{
        id: frequencySlider
        from: 0.0
        value: 4.0
        to: frequencySet.frequencies.length - 1.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.frequency = frequencySet.frequencies[value]
      }
      Text {
        id: frequencyShow
        font.pixelSize: Style.primitiveControl.textPixelSize
        text: frequencySet.frequencies[frequencySlider.value]
        anchors.verticalCenter: frequencySlider.verticalCenter
      }
    }

    Row{
      id: ledSet
      visible: !knightRiderRadio.checked
      property var leds: [true, true, true, true, true, true, true, true]
      Column{
        width: Style.primitiveControl.labelsWidth
        Text{
          x: Style.primitiveControl.margin
          text: "LEDs"
        }
      }



    }

	}


  function createDelegate(){
    delegate = delegateFactory.createObject(root)
    delegate.dragTarget = ledBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = typeRadio.type
    delegate.primitive.frequency = frequencySet.frequencies[frequencySlider.value]
    delegate.primitive.leds = ledSet.leds

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
    LEDPrimitive{}
  }
}
