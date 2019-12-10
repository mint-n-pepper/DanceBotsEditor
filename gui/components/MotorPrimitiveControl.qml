import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  color: Style.palette.pc_moveBoxBackground
  property var keys: ['mot']
  property var primitiveColors: Style.motorPrimitive.colors
  property var primitiveTextIDs: Style.motorPrimitive.textID
  enabled: false

  property var delegate: null
  property var beats: []
  property var averageBeatFrames: 60 * 441 // 100 bpm @ 44.1kHz
  property var margin: width * Style.primitiveControl.margin
  property int type

  onTypeChanged: {
    delegate.primitive.type = type
    delegate.updatePrimitive()
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
    id: controlColumn
    width: parent.width
    topPadding: root.margin
    spacing: Style.primitiveControl.controlSpacing * root.width
    Row{
      Text{
        id: moveText
        height: controlColumn.spacing * 4
               + twistRadio.height * 5
        width: Style.primitiveControl.titleWidth * root.width
        text: qsTr("M O V E S")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Style.primitiveControl.titleFontSize * width
        rotation : 270
      }
      Column{
        id: radioColumn
        spacing: controlColumn.spacing
        TypeRadio {
          id: twistRadio
          checked: true
          onPressed: appWindow.grabFocus()
          onToggled: type=MotorPrimitive.Type.Twist
          height: root.height * Style.primitiveControl.typeRadioHeight
          width: root.width * (1.0 - Style.primitiveControl.titleWidth)
          text: qsTr("Twist")
        }
        TypeRadio {
          id: spinRadio
          text: qsTr("Spin")
          onPressed: appWindow.grabFocus()
          onToggled: type=MotorPrimitive.Type.Spin
          height: root.height * Style.primitiveControl.typeRadioHeight
          width: root.width * (1.0 - Style.primitiveControl.titleWidth)
        }
        TypeRadio {
          id: backForthRadio
          text: qsTr("Back and Forth")
          onPressed: appWindow.grabFocus()
          onToggled: type=MotorPrimitive.Type.BackAndForth
          height: root.height * Style.primitiveControl.typeRadioHeight
          width: root.width * (1.0 - Style.primitiveControl.titleWidth)
        }
        TypeRadio {
          id: driveStraightRadio
          text: qsTr("Drive Straight")
          onPressed: appWindow.grabFocus()
          onToggled: type=MotorPrimitive.Type.Straight
          height: root.height * Style.primitiveControl.typeRadioHeight
          width: root.width * (1.0 - Style.primitiveControl.titleWidth)
        }
        TypeRadio {
          id: customRadio
          text: qsTr("Custom")
          onPressed: appWindow.grabFocus()
          onToggled: type=MotorPrimitive.Type.Custom
          height: root.height * Style.primitiveControl.typeRadioHeight
          width: root.width * (1.0 - Style.primitiveControl.titleWidth)
        }
      }
    }

    Row{
      id: leftSpeedSet
      Text{
        id: leftSpeedLabel
        height: velocitySlider.height
        width: Style.primitiveControl.titleWidth * root.width
        font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                        * velocitySlider.height
        text: customRadio.checked ? "Velocity L" : "Velocity"
        leftPadding: root.margin
        verticalAlignment: Text.AlignVCenter
      }
      ScalableSlider{
        id: velocitySlider
        height: root.height * Style.primitiveControl.sliderHeight
        width: root.width * (1.0
                             - Style.primitiveControl.titleWidth
                             - Style.primitiveControl.sliderValueWidth)
        from: -100.0
        value: 50.0
        to: 100.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.velocity = value
        Keys.onPressed: appWindow.handleKey(event)
        sliderBarSize: Style.primitiveControl.sliderBarSize
        backgroundColor: Style.palette.pc_sliderBarEnabled
        backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
        backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
        backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
        handleColor: Style.palette.pc_sliderHandleEnabled
        handleDisabledColor: Style.palette.pc_sliderHandleDisabled
      }
      Text {
        id: velocityShow
        width: root.width * Style.primitiveControl.sliderValueWidth
        height: frequencySlider.height
        rightPadding: root.margin
        leftPadding: width * Style.primitiveControl.sliderValueLeftPadding
        font.pixelSize: height * Style.primitiveControl.sliderLabelTextSize
        text: velocitySlider.value
        anchors.verticalCenter: velocitySlider.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
      }
    }

    Row{
      id: frequencySet
      visible: twistRadio.checked || backForthRadio.checked
      Column{
        id: frequencyLabelColumn
        width: Style.primitiveControl.titleWidth * root.width
        Text{
          leftPadding: root.margin
          text: "Frequency"
          font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                          * frequencySlider.height
        }
        Text{
          leftPadding: root.margin
          text: "[1/beats]"
          font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                          * frequencySlider.height
        }
      }
      property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0]
      ScalableSlider{
        id: frequencySlider
        anchors.verticalCenter: frequencyLabelColumn.verticalCenter
        height: root.height * Style.primitiveControl.sliderHeight
        width: root.width * (1.0
                             - Style.primitiveControl.titleWidth
                             - Style.primitiveControl.sliderValueWidth)
        from: 0.0
        value: 2.0
        to: frequencySet.frequencies.length - 1.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.frequency = frequencySet.frequencies[value]
        Keys.onPressed: appWindow.handleKey(event)
        sliderBarSize: Style.primitiveControl.sliderBarSize
        backgroundColor: Style.palette.pc_sliderBarEnabled
        backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
        backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
        backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
        handleColor: Style.palette.pc_sliderHandleEnabled
        handleDisabledColor: Style.palette.pc_sliderHandleDisabled
      }
      Text {
        id: frequencyShow
        width: root.width * Style.primitiveControl.sliderValueWidth
        height: frequencySlider.height
        rightPadding: root.margin
        leftPadding: width * Style.primitiveControl.sliderValueLeftPadding
        font.pixelSize: height * Style.primitiveControl.sliderLabelTextSize
        text: frequencySet.frequencies[frequencySlider.value].toFixed(2)
        anchors.verticalCenter: frequencySlider.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
      }
    }

    Row{
      id: rightSpeedSet
      visible: customRadio.checked

      Text{
        id: rightSpeedLabel
        height: velocityRightSlider.height
        width: Style.primitiveControl.titleWidth * root.width
        font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                        * velocityRightSlider.height
        text: "Velocity R"
        leftPadding: root.margin
        verticalAlignment: Text.AlignVCenter
      }
      ScalableSlider{
        id: velocityRightSlider
        height: root.height * Style.primitiveControl.sliderHeight
        width: root.width * (1.0
                             - Style.primitiveControl.titleWidth
                             - Style.primitiveControl.sliderValueWidth)
        from: -100.0
        value: 50.0
        to: 100.0
        stepSize: 1.0
        live: true
        snapMode: Slider.SnapAlways
        onValueChanged: delegate.primitive.velocityRight = value
        Keys.onPressed: appWindow.handleKey(event)
        sliderBarSize: Style.primitiveControl.sliderBarSize
        backgroundColor: Style.palette.pc_sliderBarEnabled
        backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
        backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
        backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
        handleColor: Style.palette.pc_sliderHandleEnabled
        handleDisabledColor: Style.palette.pc_sliderHandleDisabled
      }
      Text {
        id: velocityRightShow
        width: root.width * Style.primitiveControl.sliderValueWidth
        height: frequencySlider.height
        rightPadding: root.margin
        leftPadding: width * Style.primitiveControl.sliderValueLeftPadding
        font.pixelSize: height * Style.primitiveControl.sliderLabelTextSize
        text: velocityRightSlider.value
        anchors.verticalCenter: velocityRightSlider.verticalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
      }
    }
  }

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
    delegate.dragTarget = motorBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = type
    delegate.primitive.frequency = frequencySet.frequencies[frequencySlider.value]
    delegate.primitive.velocity = velocitySlider.value
    delegate.primitive.velocityRight = velocityRightSlider.value

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
