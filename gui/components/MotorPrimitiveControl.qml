import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13
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
  property int type

  // frequencies that can be set with slider
  property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0]

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

  Rectangle{
    id: titleBar
    height: root.height
    width: Style.primitiveControl.titleWidth * root.width
    color: Style.palette.pc_moveBoxColor
    Text{
      anchors.centerIn: parent
      text: qsTr("Moves")
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: Style.primitiveControl.titleFontSize * titleBar.width
      font.letterSpacing: Style.primitiveControl.titleLetterSpacing
      font.capitalization: Font.AllUppercase
      font.bold: true;
      rotation : 270
    }
  }

  Flow{
    id: radios
    anchors.left: titleBar.right
    padding: appWindow.guiMargin
    anchors.top: titleBar.top
    width: root.width - titleBar.width
    property var radioHeight: root.width
                              * Style.primitiveControl.typeRadioHeight
    spacing: radioHeight * Style.primitiveControl.typeRadioSpacing
    TypeRadio {
      id: twistRadio
      checked: true
      onPressed: appWindow.grabFocus()
      onToggled: type = MotorPrimitive.Type.Twist
      height: radios.radioHeight
      mainColor: Style.palette.pc_moveBoxColor
      text: qsTr("Twist")
    }
    TypeRadio {
      id: spinRadio
      text: qsTr("Spin")
      onPressed: appWindow.grabFocus()
      onToggled: type=MotorPrimitive.Type.Spin
      mainColor: Style.palette.pc_moveBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: backForthRadio
      text: qsTr("Back and Forth")
      onPressed: appWindow.grabFocus()
      onToggled: type=MotorPrimitive.Type.BackAndForth
      mainColor: Style.palette.pc_moveBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: driveStraightRadio
      text: qsTr("Drive Straight")
      onPressed: appWindow.grabFocus()
      onToggled: type=MotorPrimitive.Type.Straight
      mainColor: Style.palette.pc_moveBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: customRadio
      text: qsTr("Custom")
      onPressed: appWindow.grabFocus()
      onToggled: type=MotorPrimitive.Type.Custom
      mainColor: Style.palette.pc_moveBoxColor
      height: radios.radioHeight
    }
  } // radios column

  Rectangle {
    id: settingsRectangle
    anchors.leftMargin: appWindow.guiMargin
    anchors.rightMargin: appWindow.guiMargin
    anchors.bottomMargin: appWindow.guiMargin
    anchors.top: radios.bottom
    anchors.left: titleBar.right
    anchors.right: root.right
    anchors.bottom: root.bottom

    color: Style.palette.pc_settingsBoxBackground

    Column{
      id: settingsColumn
      width: radios.width * (1.0 - Style.primitiveControl.primitiveBoxWidth)
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.leftMargin: appWindow.guiMargin
      anchors.bottomMargin: appWindow.guiMargin
      spacing: sliderHeight * Style.primitiveControl.sliderVSpacing
      property real sliderHeight: root.width * Style.primitiveControl.sliderHeight
      property real labelWidth: width * Style.primitiveControl.sliderLabelWidth
      property real iconWidth: width * Style.primitiveControl.sliderIconWidth
      property real sliderItemSpacing: sliderHeight
                                      * Style.primitiveControl.sliderItemHSpacing
      property real sliderWidth: width
                                - labelWidth
                                - 2 * iconWidth
                                - 3 * sliderItemSpacing
                                - appWindow.guiMargin
      property real dirRadioSize: sliderHeight
                                  * Style.primitiveControl.directionRadioHeight


      Column{
        id: leftSpeedSet
        Component.onCompleted: updateSpeed()
        function updateSpeed(){
          if(leftForwardRadio.checked){
            speed = velocitySlider.value
          }else{
            speed = -velocitySlider.value
          }
          delegate.primitive.velocity = speed
          delegate.updateToolTip();
        }
        property var speed: 0
        spacing: {type !== MotorPrimitive.Type.Custom ?
                       settingsColumn.spacing
                     : settingsColumn.spacing
                       * Style.primitiveControl.dirToSliderSpacingCustom}
        Row{
          id: directionRadios
          width: settingsColumn.width
          spacing: settingsColumn.spacing
          Text{
            height: settingsColumn.sliderHeight
            width: settingsColumn.labelWidth
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * height
            font.capitalization: Font.AllUppercase
            text: {
              switch(type){
              case MotorPrimitive.Type.Custom:
                return "Direction L"
              case MotorPrimitive.Type.Straight:
              case MotorPrimitive.Type.Spin:
                return "Direction"
              case MotorPrimitive.Type.Twist:
              case MotorPrimitive.Type.BackAndForth:
                return "Start"
              }
            }
            color: Style.palette.pc_sliderText
          }

          DirectionRadio{
            id: leftForwardRadio
            checked: true
            text: {
              switch(type){
              case MotorPrimitive.Type.Custom:
              case MotorPrimitive.Type.Straight:
              case MotorPrimitive.Type.BackAndForth:
                return "Forward"
              case MotorPrimitive.Type.Twist:
              case MotorPrimitive.Type.Spin:
                return "Counter-Clockwise"
              }
            }
            onPressed: appWindow.grabFocus()
            onToggled: leftSpeedSet.updateSpeed()
            height: settingsColumn.dirRadioSize
          }
          DirectionRadio{
            id: leftBackwardRadio
            text: {
              switch(type){
              case MotorPrimitive.Type.Custom:
              case MotorPrimitive.Type.Straight:
              case MotorPrimitive.Type.BackAndForth:
                return "Backward"
              case MotorPrimitive.Type.Twist:
              case MotorPrimitive.Type.Spin:
                return "Clockwise"
              }
            }
            onPressed: appWindow.grabFocus()
            onToggled: leftSpeedSet.updateSpeed()
            height: settingsColumn.dirRadioSize
          }
        }

        Row{
          spacing: settingsColumn.sliderItemSpacing
          Item{
            height: settingsColumn.sliderHeight
            width: settingsColumn.labelWidth
            Text{
              font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                              * parent.height
              font.capitalization: Font.AllUppercase
              text: {
                switch(type){
                case MotorPrimitive.Type.Custom:
                  return "Velocity L"
                case MotorPrimitive.Type.Straight:
                case MotorPrimitive.Type.Spin:
                  return "Velocity"
                case MotorPrimitive.Type.Twist:
                case MotorPrimitive.Type.BackAndForth:
                  return "Amplitude"
                }
              }
              verticalAlignment: Text.AlignVCenter
              color: Style.palette.pc_sliderText
            }
          }

          Item{
            width: settingsColumn.iconWidth
            height: settingsColumn.sliderHeight
            Image{
              id: turtle
              anchors.centerIn: parent
              source: "../icons/turtle.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              anchors.fill: turtle
              source: turtle
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: !lowAmpOverlay.visible
            }

            Image{
              id: lowAmpIcon
              anchors.centerIn: parent
              source: "../icons/lowAmplitude.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              id: lowAmpOverlay
              anchors.fill: lowAmpIcon
              source: lowAmpIcon
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: type === MotorPrimitive.Type.Twist
                       || type === MotorPrimitive.Type.BackAndForth
            }
          }
          ScalableSlider{
            id: velocitySlider
            height: settingsColumn.sliderHeight
            width: settingsColumn.sliderWidth
            from: 0.0
            value: 60.0
            to: 100.0
            stepSize: 1.0
            live: true
            snapMode: Slider.SnapAlways
            onValueChanged: leftSpeedSet.updateSpeed()
            Keys.onPressed: appWindow.handleKey(event)
            sliderBarSize: Style.primitiveControl.sliderBarSize
            backgroundColor: Style.palette.pc_sliderBarEnabled
            backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
            backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
            backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
            handleColor: Style.palette.pc_sliderHandleEnabled
            handleDisabledColor: Style.palette.pc_sliderHandleDisabled
          }

          Item{
            width: settingsColumn.iconWidth
            height: settingsColumn.sliderHeight
            Image{
              id: rabbit
              anchors.centerIn: parent
              source: "../icons/rabbit.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              anchors.fill: rabbit
              source: rabbit
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: !highAmpOverlay.visible
            }

            Image{
              id: highAmpIcon
              anchors.centerIn: parent
              source: "../icons/highAmplitude.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              id: highAmpOverlay
              anchors.fill: highAmpIcon
              source: highAmpIcon
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: type === MotorPrimitive.Type.Twist
                       || type === MotorPrimitive.Type.BackAndForth
            }
          }
        }
      } // left speed column

      Row{
        id: frequencySliderRow
        spacing: settingsColumn.sliderItemSpacing
        visible: twistRadio.checked || backForthRadio.checked
        Item{
          height: settingsColumn.sliderHeight
          width: settingsColumn.labelWidth
          Text{
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * parent.height
            font.capitalization: Font.AllUppercase
            text: "Frequency"
            verticalAlignment: Text.AlignVCenter
            color: Style.palette.pc_sliderText
          }
        }

        Item{
          width: settingsColumn.iconWidth
          height: settingsColumn.sliderHeight
          Image{
            id: lowFreq
            anchors.centerIn: parent
            source: "../icons/lowFreq.svg"
            sourceSize.width: parent.width
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: lowFreq
            source: lowFreq
            color: Style.palette.pc_sliderIcon
            antialiasing: true
            visible: true
          }
        }

        ScalableSlider{
          id: frequencySlider
          height: settingsColumn.sliderHeight
          width: settingsColumn.sliderWidth
          from: 0.0
          value: 2.0
          to: frequencies.length - 1.0
          stepSize: 1.0
          live: true
          snapMode: Slider.SnapAlways
          onValueChanged: {
            delegate.primitive.frequency = frequencies[value]
            delegate.updateToolTip()
          }
          Keys.onPressed: appWindow.handleKey(event)
          sliderBarSize: Style.primitiveControl.sliderBarSize
          backgroundColor: Style.palette.pc_sliderBarEnabled
          backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
          backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
          backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
          handleColor: Style.palette.pc_sliderHandleEnabled
          handleDisabledColor: Style.palette.pc_sliderHandleDisabled
        }

        Item{
          width: settingsColumn.iconWidth
          height: settingsColumn.sliderHeight
          Image{
            id: highFreq
            anchors.centerIn: parent
            source: "../icons/highFreq.svg"
            sourceSize.width: parent.width
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: highFreq
            source: highFreq
            color: Style.palette.pc_sliderIcon
            antialiasing: true
            visible: true
          }
        }
      } // frequency row

      Column{
        id: rightSpeedSet
        visible: type === MotorPrimitive.Type.Custom
        Component.onCompleted: updateSpeed()
        function updateSpeed(){
          if(rightForwardRadio.checked){
            speed = rightVelocitySlider.value
          }else{
            speed = -rightVelocitySlider.value
          }
          delegate.primitive.velocityRight = speed
          delegate.updateToolTip();
        }
        property var speed: 0
        spacing: settingsColumn.spacing
                   * Style.primitiveControl.dirToSliderSpacingCustom
        Row{
          id: directionRadiosRight
          width: settingsColumn.width
          spacing: settingsColumn.spacing
          Text{
            height: settingsColumn.sliderHeight
            width: settingsColumn.labelWidth
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * height
            font.capitalization: Font.AllUppercase
            text: "Direction R"
            color: Style.palette.pc_sliderText
          }

          DirectionRadio{
            id: rightForwardRadio
            checked: true
            text: "Forward"
            onPressed: appWindow.grabFocus()
            onToggled: rightSpeedSet.updateSpeed()
            height: settingsColumn.dirRadioSize
          }

          DirectionRadio{
            id: rightBackwardRadio
            text: "Backward"
            onPressed: appWindow.grabFocus()
            onToggled: rightSpeedSet.updateSpeed()
            height: settingsColumn.dirRadioSize
          }
        } // dir radio row

        Row{
          spacing: settingsColumn.sliderItemSpacing
          Item{
            height: settingsColumn.sliderHeight
            width: settingsColumn.labelWidth
            Text{
              id: rightSpeedLabel
              font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                              * parent.height
              font.capitalization: Font.AllUppercase
              text: "Velocity R"
              verticalAlignment: Text.AlignVCenter
              color: Style.palette.pc_sliderText
            }
          }

          Item{
            width: settingsColumn.iconWidth
            height: settingsColumn.sliderHeight
            Image{
              id: turtleR
              anchors.centerIn: parent
              source: "../icons/turtle.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              anchors.fill: turtleR
              source: turtleR
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: true
            }
          }

          ScalableSlider{
            id: rightVelocitySlider
            height: settingsColumn.sliderHeight
            width: settingsColumn.sliderWidth
            from: 0.0
            value: 60.0
            to: 100.0
            stepSize: 1.0
            live: true
            snapMode: Slider.SnapAlways
            onValueChanged: rightSpeedSet.updateSpeed()
            Keys.onPressed: appWindow.handleKey(event)
            sliderBarSize: Style.primitiveControl.sliderBarSize
            backgroundColor: Style.palette.pc_sliderBarEnabled
            backgroundDisabledColor: Style.palette.pc_sliderBarDisabled
            backgroundActiveColor: Style.palette.pc_sliderBarActivePartEnabled
            backgroundActiveDisabledColor: Style.palette.pc_sliderBarActivePartDisabled
            handleColor: Style.palette.pc_sliderHandleEnabled
            handleDisabledColor: Style.palette.pc_sliderHandleDisabled
          }

          Item{
            width: settingsColumn.iconWidth
            height: settingsColumn.sliderHeight
            Image{
              id: rabbitR
              anchors.centerIn: parent
              source: "../icons/rabbit.svg"
              sourceSize.width: parent.width
              antialiasing: true
              visible: false
            }

            ColorOverlay{
              anchors.fill: rabbitR
              source: rabbitR
              color: Style.palette.pc_sliderIcon
              antialiasing: true
              visible: true
            }
          }
        } // right speed slider row
      } // right speed column
    } // settings column

    Rectangle{
      id: dummyTimerBar
      height: appWindow.width * Style.primitives.height * Style.timerBar.height
      anchors.bottom: parent.bottom
      anchors.left: settingsColumn.right
      anchors.leftMargin: appWindow.guiMargin
      anchors.bottomMargin: appWindow.guiMargin
    }
  }

  function createDelegate(){
    delegate = delegateFactory.createObject(dummyTimerBar)
    delegate.dragTarget = motorBar.dragTarget
    delegate.idleParent = root
    delegate.isMotor = true
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = type
    delegate.primitive.frequency = frequencies[frequencySlider.value]
    delegate.primitive.velocity = leftSpeedSet.speed
    delegate.primitive.velocityRight = rightSpeedSet.speed

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
