/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2019-2021 - mint & pepper
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
  color: Style.palette.pc_ledBoxBackground
  property var keys: ['led']
  property var beats: []
  property var primitiveColors: Style.ledPrimitive.colors
  property var primitiveTextIDs: Style.ledPrimitive.textID
  property var delegate: null
  property var averageBeatFrames: appWindow.initAvgBeatFrames
  enabled: false
  property bool showDragHint: true

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

  Rectangle{
    id: titleBar
    height: root.height
    width: Style.primitiveControl.titleWidth * root.width
    color: Style.palette.pc_titlebar_background
    Text{
      anchors.centerIn: parent
      text: qsTr("Lights")
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: Style.primitiveControl.titleFontSize * titleBar.width
      font.letterSpacing: Style.primitiveControl.titleLetterSpacing
      font.capitalization: Font.AllUppercase
      font.bold: true;
      rotation : 270
      color: Style.palette.pc_ledBoxColor
    }
  }

  Rectangle{
    id: titleBarBorder
    height: root.height
    anchors.left: titleBar.right
    width: Style.primitiveControl.titleBorderWidth * root.width
    color: Style.palette.pc_ledBoxColor
  }

  Row{
    id: radios
    anchors.left: titleBarBorder.right
    topPadding: appWindow.guiMargin
    leftPadding: appWindow.guiMargin
    rightPadding: appWindow.guiMargin
    anchors.top: titleBar.top
    width: root.width - titleBar.width - titleBarBorder.width
    property var radioHeight: root.width
                              * Style.primitiveControl.typeRadioHeight
    spacing: (width - 2 * appWindow.guiMargin
              - knightRiderRadio.width
              - alternateRadio.width
              - blinkRadio.width
              - constantRadio.width
              - randomRadio.width) / 4
    TypeRadio {
      id: knightRiderRadio
      checked: true
      text: qsTr("KnightRider")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.KnightRider
      mainColor: Style.ledPrimitive.colors[0]
      height: radios.radioHeight
    }
    TypeRadio {
      id: alternateRadio
      text: qsTr("Alternate")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Alternate
      mainColor: Style.ledPrimitive.colors[1]
      height: radios.radioHeight
    }
    TypeRadio {
      id: blinkRadio
      text: qsTr("Blink")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Blink
      mainColor: Style.ledPrimitive.colors[2]
      height: radios.radioHeight
    }
    TypeRadio {
      id: constantRadio
      text: qsTr("Constant")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Constant
      mainColor: Style.ledPrimitive.colors[3]
      height: radios.radioHeight
    }
    TypeRadio {
      id: randomRadio
      text: qsTr("Random")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Random
      mainColor: Style.ledPrimitive.colors[4]
      height: radios.radioHeight
    }
  } // radios column

  Rectangle {
    id: settingsRectangle
    anchors.leftMargin: appWindow.guiMargin
    anchors.rightMargin: appWindow.guiMargin
    property var minHeight: dummyTimerBar.effectiveHeight
                            + 2 * appWindow.guiMargin
    property var settingsHeight: settingsColumn.height
                                 + 4 * appWindow.guiMargin
    height:  settingsHeight < minHeight ? minHeight : settingsHeight
    anchors.left: titleBarBorder.right
    anchors.right: root.right
    // move box to hug the radios
    anchors.top: radios.bottom
    anchors.topMargin: Style.primitiveControl.typeRadioToSettingsBox
                       * appWindow.guiMargin

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
      anchors.top: parent.top
      anchors.topMargin: 2 * appWindow.guiMargin
      spacing: appWindow.guiMargin
      property real sliderHeight: root.width * Style.primitiveControl.sliderHeight
      property real labelWidth: width * Style.primitiveControl.sliderLabelWidth
      property real iconWidth: width * Style.primitiveControl.sliderIconWidth
      property real valueWidth: width * Style.primitiveControl.sliderValueWidth
      property real sliderHSpacing: sliderHeight
                                    * Style.primitiveControl.sliderItemHSpacing
      property real sliderWidth: width
                                - labelWidth
                                - valueWidth
                                - 2 * iconWidth
                                - 4 * sliderHSpacing
      property real dirRadioSize: radios.radioHeight
                                  * Style.primitiveControl.directionRadioSize

      FrequencySlider{
        id: frequencySliderRow
        spacing: settingsColumn.sliderHSpacing
        height: settingsColumn.sliderHeight
        labelWidth: settingsColumn.labelWidth
        iconWidth: settingsColumn.iconWidth
        valueWidth: settingsColumn.valueWidth
        sliderWidth: settingsColumn.sliderWidth

        // frequencies that can be set with slider
        numerators:   [1, 1, 1, 2, 1, 3, 2, 3, 4]
        denominators: [4, 3, 2, 3, 1, 2, 1, 1, 1]

        visible: !constantRadio.checked
        toolTipText: {
          switch(type){
          case LEDPrimitive.Type.KnightRider:
            return ToolTipTexts.freqKnightRider
          case LEDPrimitive.Type.Alternate:
            return ToolTipTexts.freqAlternate
          case LEDPrimitive.Type.Blink:
            return ToolTipTexts.freqBlink
          case LEDPrimitive.Type.Random:
            return ToolTipTexts.freqRandom
          default:
            return ""
          }
        }
      }

      Row{
        id: ledSet
        visible: !knightRiderRadio.checked && !randomRadio.checked
        Item{
          id: ledlabel
          height: settingsColumn.sliderHeight
          width: settingsColumn.labelWidth
          Text{
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * parent.height
            text: "LEDs"
            verticalAlignment: Text.AlignVCenter
            color: Style.palette.pc_sliderText
          }
          GuiToolTip{
            toolTipText: {
              switch(type){
              case LEDPrimitive.Type.Alternate:
                return ToolTipTexts.ledAlternate
              case LEDPrimitive.Type.Blink:
                return ToolTipTexts.ledBlink
              case LEDPrimitive.Type.Constant:
                return ToolTipTexts.ledConstant
              default:
                return ""
              }
            }
          }
        }

        Row{
          id: ledCheckboxes
          property var ledDiameter: Style.primitiveControl.ledRadioDiameter
                                    * settingsColumn.sliderHeight
          spacing: Style.primitiveControl.ledRadioSpacing * ledDiameter
          anchors.verticalCenter: ledlabel.verticalCenter
          Repeater{
            model: leds.length
            delegate: CheckBox{
              id: control
              checked: leds[index]
              focusPolicy: Qt.NoFocus
              width: ledCheckboxes.ledDiameter
              onPressed: appWindow.grabFocus()
              onCheckedChanged: {
                leds[index] = checked
                if(delegate){
                  delegate.primitive.leds[index] = checked;
                  delegate.updateToolTip()
                }
              }
              contentItem: Text{
                width: background.width
                anchors.top: background.bottom
                anchors.verticalCenter: parent.verticalCenter
                text: index
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: background.width
                                * Style.primitiveControl.ledTextSize
                color: Style.palette.pc_controlsFonts
              }

              indicator: Rectangle{
                id: ledIndicator
                width: ledCheckboxes.ledDiameter
                height: ledCheckboxes.ledDiameter
                radius: height/2
                anchors.verticalCenter: background.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: control.checked ?
                         Style.palette.prim_toolTipLEDon : background.color
              }

              background: Rectangle{
                width: ledCheckboxes.ledDiameter
                height: ledCheckboxes.ledDiameter
                anchors.verticalCenter: parent.verticalCenter
                radius: height/2
                color: Style.palette.prim_toolTipLEDoff
              }
            }
          } // led repeater
        } // led checkboxes
      } // led set row
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
    delegate.dragTarget = ledBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0
    delegate.primitive.lengthBeat= 4
    delegate.primitive.type = type
    delegate.primitive.frequency = frequencySliderRow.value
    delegate.primitive.leds = leds

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
