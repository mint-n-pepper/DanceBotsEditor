import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  color: Style.palette.pc_ledBoxBackground
  property var keys: ['led']
  property var beats: []
  property var primitiveColors: Style.ledPrimitive.colors
  property var primitiveTextIDs: Style.ledPrimitive.textID
  property var delegate: null
  property var averageBeatFrames: 60 * 441 // 100 bpm @ 44.1kHz
  enabled: false
  property var margin: width * Style.primitiveControl.margin
  property int type
  onTypeChanged: {
    delegate.primitive.type = type
    delegate.updatePrimitive()
  }
  property var leds: [true, true, true, true, true, true, true, true]

  Connections{
	  target: backend
	  onDoneLoading:{
      if(result){
        // calculate average beat distance:
        averageBeatFrames = backend.getAverageBeatFrames();
        delegate.updatePrimitive();
        enabled = true;
      }
    }
  }

//	Column{
//    id: controlColumn
//		width: parent.width
//    topPadding: root.margin
//    spacing: Style.primitiveControl.controlSpacing * root.width
//    Row{
//      Text{
//        id: blinkieText
//        height: controlColumn.spacing * 4
//               + knightRiderRadio.height * 5
//        width: Style.primitiveControl.titleWidth * root.width
//        text: qsTr("L I G H T S")
//        horizontalAlignment: Text.AlignHCenter
//        verticalAlignment: Text.AlignVCenter
//        font.pixelSize: Style.primitiveControl.titleFontSize * width
//        rotation : 270
//      }
//      Column{
//        spacing: Style.primitiveControl.controlSpacing * root.height
//        TypeRadio {
//          id: knightRiderRadio
//          checked: true
//          text: qsTr("KnightRider")
//          onPressed: appWindow.grabFocus()
//          onToggled: type=LEDPrimitive.Type.KnightRider
//          height: root.height * Style.primitiveControl.typeRadioHeight
//          width: root.width - blinkieText.width
//        }
//        TypeRadio {
//          id: alternateRadio
//          text: qsTr("Alternate")
//          onPressed: appWindow.grabFocus()
//          onToggled: type=LEDPrimitive.Type.Alternate
//          height: root.height * Style.primitiveControl.typeRadioHeight
//          width: root.width - blinkieText.width
//        }
//        TypeRadio {
//          id: blinkRadio
//          text: qsTr("Blink")
//          onPressed: appWindow.grabFocus()
//          onToggled: type=LEDPrimitive.Type.Blink
//          height: root.height * Style.primitiveControl.typeRadioHeight
//          width: root.width - blinkieText.width
//        }
//        TypeRadio {
//          id: constantRadio
//          text: qsTr("Constant")
//          onPressed: appWindow.grabFocus()
//          onToggled: type=LEDPrimitive.Type.Constant
//          height: root.height * Style.primitiveControl.typeRadioHeight
//          width: root.width - blinkieText.width
//        }
//        TypeRadio {
//          id: randomRadio
//          text: qsTr("Random")
//          onPressed: appWindow.grabFocus()
//          onToggled: type=LEDPrimitive.Type.Random
//          height: root.height * Style.primitiveControl.typeRadioHeight
//          width: root.width - blinkieText.width
//        }
//      }
//    }

//    Row{
//      id: frequencySet
//      visible: !constantRadio.checked
//      Column{
//        id: frequencyLabelColumn
//        width: Style.primitiveControl.titleWidth * root.width
//        Text{
//          leftPadding: root.margin
//          text: "Frequency"
//          font.pixelSize: Style.primitiveControl.sliderLabelTextSize
//                          * frequencySlider.height
//        }
//        Text{
//          leftPadding: root.margin
//          text: "[1/beats]"
//          font.pixelSize: Style.primitiveControl.sliderLabelTextSize
//                          * frequencySlider.height
//        }
//      }
//      property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0, 1.5, 2.0, 3.0, 4.0]
//      ScalableSlider{
//        id: frequencySlider
//        anchors.verticalCenter: frequencyLabelColumn.verticalCenter
//        height: root.height * Style.primitiveControl.sliderHeight
//        width: root.width * (1.0
//                             - Style.primitiveControl.titleWidth
//                             - Style.primitiveControl.sliderValueWidth)
//        from: 0.0
//        value: 4.0
//        to: frequencySet.frequencies.length - 1.0
//        stepSize: 1.0
//        live: true
//        snapMode: Slider.SnapAlways
//        onValueChanged: delegate.primitive.frequency = frequencySet.frequencies[value]
//        Keys.onPressed: appWindow.handleKey(event)
//        sliderBarSize: Style.primitiveControl.sliderBarSize
//        backgroundColor: Style.palette.pc_sliderBarEnabled
//        backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
//        backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
//        backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
//        handleColor: Style.palette.pc_sliderHandleEnabled
//        handleDisabledColor: Style.palette.pc_sliderHandleDisabled
//      }
//      Text {
//        id: frequencyShow
//        width: root.width * Style.primitiveControl.sliderValueWidth
//        height: frequencySlider.height
//        rightPadding: root.margin
//        leftPadding: width * Style.primitiveControl.sliderValueLeftPadding
//        font.pixelSize: height * Style.primitiveControl.sliderLabelTextSize
//        text: frequencySet.frequencies[frequencySlider.value].toFixed(2)
//        anchors.verticalCenter: frequencySlider.verticalCenter
//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignRight
//      }
//    }

//    Row{
//      id: ledSet
//      visible: !knightRiderRadio.checked && !randomRadio.checked
//      width: Style.primitiveControl.labelsWidth
//      Text{
//        id: ledLabel
//        height: root.height * Style.primitiveControl.typeRadioHeight
//        width: Style.primitiveControl.titleWidth * root.width
//        font.pixelSize: Style.primitiveControl.sliderLabelTextSize
//                        * height
//        leftPadding: root.margin
//        verticalAlignment: Text.AlignVCenter
//        text: "LEDs"
//      }

//      Row{
//        id: ledCheckboxes
//        property var ledDiameter: Style.primitiveControl.ledRadioDiameter
//                                  * ledLabel.height
//        spacing: Style.primitiveControl.ledRadioSpacing * ledDiameter
//        Repeater{
//          model: leds.length
//          delegate: CheckBox{
//            id: control
//            checked: leds[index]
//            focusPolicy: Qt.NoFocus
//            width: ledCheckboxes.ledDiameter
//            onPressed: appWindow.grabFocus()
//            onCheckedChanged: {
//              leds[index] = checked
//              if(delegate){
//                delegate.primitive.leds[index] = checked;
//              }
//            }
//            contentItem: Text{
//              width: background.width
//              anchors.top: background.bottom
//              anchors.verticalCenter: parent.verticalCenter
//              text: index
//              horizontalAlignment: Text.AlignHCenter
//              font.pixelSize: background.width * Style.primitiveControl.ledTextSize
//            }

//            indicator: Rectangle{
//              id: ledIndicator
//              width: ledCheckboxes.ledDiameter
//              height: ledCheckboxes.ledDiameter
//              radius: height/2
//              anchors.verticalCenter: background.verticalCenter
//              anchors.horizontalCenter: parent.horizontalCenter
//              color: control.checked ?
//                       Style.palette.prim_toolTipLEDon : background.color
//            }

//            background: Rectangle{
//              width: ledCheckboxes.ledDiameter
//              height: ledCheckboxes.ledDiameter
//              anchors.verticalCenter: parent.verticalCenter
//              radius: height/2
//              color: Style.palette.prim_toolTipLEDoff
//            }
//          }
//        }
//      }
//    }
//	}


  Rectangle{
    id: dummyTimerBar
    height: appWindow.width * Style.primitives.height * Style.timerBar.height
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.leftMargin: root.margin
    anchors.bottomMargin: root.margin
  }

  function createDelegate(){
    delegate = delegateFactory.createObject(dummyTimerBar)
    delegate.dragTarget = ledBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = type
    //delegate.primitive.frequency = frequencySet.frequencies[frequencySlider.value]
    delegate.primitive.leds = leds

    delegate.anchors.verticalCenter = dummyTimerBar.verticalCenter
    delegate.updatePrimitive()
  }

  Component.onCompleted:{
    // set the first beat at a fixed pixel distance from the left border of the
    // control box:
    setDummyBeats();
    createDelegate();
  }

  onDelegateChanged:{
    if(delegate === null){
      createDelegate()
    }
  }

  function setDummyBeats(){
    for(var i = 0; i < 5; ++i){
      // add beats at 100 bpm
      beats[i] = (i * averageBeatFrames)
    }
  }

  onAverageBeatFramesChanged:{
    setDummyBeats();
  }

  Component{
    id: delegateFactory
    PrimitiveDelegate{}
  }

  Component{
    id: primitiveFactory
    LEDPrimitive{}
  }

  function duplicatePrimitive(primOrig){
    var prim = primitiveFactory.createObject(root)
    prim.type = primOrig.type
    prim.positionBeat = primOrig.positionBeat
    prim.lengthBeat = primOrig.lengthBeat
    prim.frequency = primOrig.frequency
    prim.leds = primOrig.leds
    return prim
  }
}
