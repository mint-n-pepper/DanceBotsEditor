/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2020 - mint & pepper
*
*  This program is free software : you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*
*  See the GNU General Public License for more details, available in the
*  LICENSE file included in the repository.
*/

import QtQuick 2.6
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  color: Style.palette.pc_moveBoxBackground
  property var keys: ['mot']
  property var primitiveColors: Style.motorPrimitive.colors
  property var primitiveTextIDs: Style.motorPrimitive.textID
  enabled: false
  property bool showDragHint: true

  property var delegate: null
  property var beats: []
  property var averageBeatFrames: appWindow.initAvgBeatFrames
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

  Row{
    id: radios
    anchors.left: titleBar.right
    padding: appWindow.guiMargin
    anchors.top: titleBar.top
    width: root.width - titleBar.width
    property var radioHeight: root.width
                              * Style.primitiveControl.typeRadioHeight
    spacing: (width - 2 * padding
              - twistRadio.width
              - spinRadio.width
              - backForthRadio.width
              - driveStraightRadio.width
              - customRadio.width) / 4
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
    property var minHeight: dummyTimerBar.effectiveHeight
                            + 2 * appWindow.guiMargin
    property var settingsHeight: settingsColumn.height
                                 + 2 * settingsColumn.anchors.bottomMargin
    height:  settingsHeight < minHeight ? minHeight : settingsHeight
    anchors.left: titleBar.right
    anchors.right: root.right
    anchors.bottom: root.bottom

    property real contentLeftRightPadding: appWindow.guiMargin
    property real contentWidth: width - 2 * contentLeftRightPadding

    color: Style.palette.pc_settingsBoxBackground

    Column{
      id: settingsColumn
      // width is set to be width of surrounding rectangle minus
      // left margin and minus primitive area width
      width: settingsRectangle.contentWidth
             * (1.0 - Style.primitiveControl.primitiveBoxWidth)
      anchors.left: parent.left
      anchors.leftMargin: settingsRectangle.contentLeftRightPadding
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 2 * appWindow.guiMargin
      // spacing changes when right speed is visible to get clear separations
      spacing: rightSpeedSet.visible ?
        2 * sliderHeight * Style.primitiveControl.sliderVSpacing
        :  sliderHeight * Style.primitiveControl.sliderVSpacing
      property real sliderHeight: root.width
                                  * Style.primitiveControl.sliderHeight
      property real labelWidth: width * Style.primitiveControl.sliderLabelWidth
      property real iconWidth: width * Style.primitiveControl.sliderIconWidth
      property real valueWidth: width * Style.primitiveControl.sliderValueWidth
      property real sliderHSpacing: sliderHeight
                                    * Style.primitiveControl.sliderItemHSpacing
      // slider takes remaining width, not considering any margin between
      // controls and primitive area
      property real sliderWidth: width
                                - labelWidth
                                - valueWidth
                                - 2 * iconWidth
                                - 4 * sliderHSpacing
      property real dirRadioSize: sliderHeight
                                  * Style.primitiveControl.directionRadioHeight

      Column{
        id: leftSpeedSet
        Component.onCompleted: updateSpeed()
        function updateSpeed(){
          if(leftForwardRadio.checked){
            speed = velocitySlider.value * 10
          }else{
            speed = -velocitySlider.value * 10
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
            GuiToolTip{
              toolTipText: {
                switch(type){
                case MotorPrimitive.Type.Custom:
                  return ToolTipTexts.directionLeftWheel
                case MotorPrimitive.Type.Straight:
                case MotorPrimitive.Type.Spin:
                  return ToolTipTexts.directionSpinStraight
                case MotorPrimitive.Type.Twist:
                case MotorPrimitive.Type.BackAndForth:
                  return ToolTipTexts.startDirectionTwistBackAndForth
                default:
                  return ""
                }
              }
            }
            z: 1000 // put above other elements so that the tooltip is above
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
          spacing: settingsColumn.sliderHSpacing
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
                  return "Speed L"
                case MotorPrimitive.Type.Straight:
                case MotorPrimitive.Type.Spin:
                  return "Speed"
                case MotorPrimitive.Type.Twist:
                case MotorPrimitive.Type.BackAndForth:
                  return "Amplitude"
                }
              }
              verticalAlignment: Text.AlignVCenter
              color: Style.palette.pc_sliderText
            }
            GuiToolTip{
              toolTipText: {
                switch(type){
                case MotorPrimitive.Type.Custom:
                  return ToolTipTexts.speedLeft
                case MotorPrimitive.Type.Straight:
                  return ToolTipTexts.speedStraight
                case MotorPrimitive.Type.Spin:
                  return ToolTipTexts.speedSpin
                case MotorPrimitive.Type.Twist:
                  return ToolTipTexts.amplitudeTwist
                case MotorPrimitive.Type.BackAndForth:
                  return ToolTipTexts.amplitudeBackAndForth
                default:
                  return ""
                }
              }
            }
            z: 1000 // put above other elements so that the tooltip is above            
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
          DiscreteSlider{
            id: velocitySlider
            height: settingsColumn.sliderHeight
            width: settingsColumn.sliderWidth
            numberOfSteps: 11
            value: 5
            onValueChanged: leftSpeedSet.updateSpeed()
            Keys.onPressed: appWindow.handleKey(event)
            sliderBarSize: Style.primitiveControl.sliderBarSize
            tickMarkHeight: Style.primitiveControl.sliderTickHeight
            tickMarkWidth: Style.primitiveControl.sliderTickWidth
            backgroundColor: Style.palette.pc_sliderBar
            ticksColor: Style.palette.pc_sliderBarTicks
            handleColor: Style.palette.pc_sliderHandle
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
          Text{
            id: valueDisplay
            text: (velocitySlider.value * 10).toString()
            color: Style.palette.pc_controlsFonts
            font.pixelSize: settingsColumn.sliderHeight
                            * Style.primitiveControl.sliderValueTextSize
            anchors.verticalCenter: velocitySlider.verticalCenter
          }
        } // speed column
      } // left speed column

      FrequencySlider{
        id: frequencySliderRow
        spacing: settingsColumn.sliderHSpacing
        height: settingsColumn.sliderHeight
        labelWidth: settingsColumn.labelWidth
        iconWidth: settingsColumn.iconWidth
        valueWidth: settingsColumn.valueWidth
        sliderWidth: settingsColumn.sliderWidth
        toolTipText: ToolTipTexts.motionFrequency
        // frequencies that can be set with slider
        numerators: [1, 1, 1, 2, 1]
        denominators: [4, 3, 2, 3, 1]

        visible: twistRadio.checked || backForthRadio.checked
      }

      Column{
        id: rightSpeedSet
        visible: type === MotorPrimitive.Type.Custom
        Component.onCompleted: updateSpeed()
        function updateSpeed(){
          if(rightForwardRadio.checked){
            speed = rightVelocitySlider.value * 10
          }else{
            speed = -rightVelocitySlider.value * 10
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
            
            GuiToolTip{
              toolTipText: ToolTipTexts.directionRightWheel
            }
            z: 1000 // put above other elements so that the tooltip is above  
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
          spacing: settingsColumn.sliderHSpacing
          Item{
            height: settingsColumn.sliderHeight
            width: settingsColumn.labelWidth
            Text{
              id: rightSpeedLabel
              font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                              * parent.height
              font.capitalization: Font.AllUppercase
              text: "Speed R"
              verticalAlignment: Text.AlignVCenter
              color: Style.palette.pc_sliderText
              width: settingsColumn.labelWidth
              GuiToolTip{
                toolTipText: ToolTipTexts.speedRight
              }
              z: 1000 // put above other elements so that the tooltip is above 
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

          DiscreteSlider{
            id: rightVelocitySlider
            height: settingsColumn.sliderHeight
            width: settingsColumn.sliderWidth
            numberOfSteps: 11
            value: 3
            onValueChanged: rightSpeedSet.updateSpeed()
            Keys.onPressed: appWindow.handleKey(event)
            sliderBarSize: Style.primitiveControl.sliderBarSize
            tickMarkHeight: Style.primitiveControl.sliderTickHeight
            tickMarkWidth: Style.primitiveControl.sliderTickWidth
            backgroundColor: Style.palette.pc_sliderBar
            ticksColor: Style.palette.pc_sliderBarTicks
            handleColor: Style.palette.pc_sliderHandle
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
          Text{
            id: rightValueDisplay
            text: (rightVelocitySlider.value * 10).toString()
            color: Style.palette.pc_controlsFonts
            font.pixelSize: settingsColumn.sliderHeight
                            * Style.primitiveControl.sliderValueTextSize
            anchors.verticalCenter: rightVelocitySlider.verticalCenter
          }
        } // right speed slider row
      } // right speed column
    } // settings column

    Rectangle{
      id: dummyTimerBar
      property real effectiveHeight: dragHint.visible ?
                                       dragHint.height + height
                                     : height
      // dummy timer bar has same height as primitives
      height: appWindow.width
              * Style.primitives.height
              * Style.timerBar.height
      width: settingsRectangle.contentWidth
             * Style.primitiveControl.primitiveBoxWidth
      anchors.bottom: settingsRectangle.bottom
      anchors.left: settingsColumn.right
      anchors.bottomMargin: appWindow.guiMargin
      color: "transparent"
      Text{
        id: dragHint
        text: "Drag me!"
        color: Style.palette.pc_controlsFonts
        anchors.bottom: dummyTimerBar.top
        width: dummyTimerBar.width
        font.pixelSize: parent.height * Style.primitiveControl.dragHintTextSize
        visible: root.showDragHint
      }
    }
  }

  function createDelegate(){
    if(root.enabled && root.showDragHint){
      showDragHint = false
    }
    delegate = delegateFactory.createObject(dummyTimerBar)
    delegate.dragTarget = motorBar.dragTarget
    delegate.idleParent = root
    delegate.isMotor = true
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0
    delegate.primitive.lengthBeat= 4
    delegate.primitive.type = type
    delegate.primitive.frequency = frequencySliderRow.value
    delegate.primitive.velocity = leftSpeedSet.speed
    delegate.primitive.velocityRight = rightSpeedSet.speed

    delegate.anchors.verticalCenter = dummyTimerBar.verticalCenter
    delegate.updatePrimitive()
  }

  Component.onCompleted:{
    // set the first beat at a fixed pixel distance from the left border of the
    // control box:
    setDummyBeats()
    delegate.updatePrimitive()
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
