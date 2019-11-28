import QtQuick 2.6
import QtQuick.Controls 2.0

import "Components"
import "GuiStyle"

ApplicationWindow {
  id: appWindow
  width: Style.main.width
  height: Style.main.height
  visible: true

  onActiveFocusItemChanged:{
    if(activeFocusItem === appWindow || activeFocusItem === null)  {
      keyCatcher.focus=true
    }
    print("activeFocusItem", activeFocusItem)

  }

  background: Rectangle{
    anchors.fill: parent
    color: Style.main.color
  }

  MouseArea{
    id: sceneClickCatcher
    anchors.fill: parent
    onClicked: {
      handleSceneClick(mouse)
    }
  }

  LoadProcessPopup{
    id: loadProcess
  }

  MP3FileControl{
    id: fileControl
  }


  MotorPrimitiveControl{
    id: motorPrimitiveControl
    anchors.left: fileControl.right
  }

  LEDPrimitiveControl{
    id: ledPrimitiveControl
    anchors.left: motorPrimitiveControl.right
  }

  AudioControl{
    id: audioControl
    anchors.top: timerBarFlickable.bottom
    width: parent.width
  }

  Flickable{
    id: timerBarFlickable
    width: parent.width
    height: timerBarColumn.height
    contentWidth: timerBarColumn.width
    contentHeight: timerBarColumn.height
    anchors.top: fileControl.bottom
    anchors.left: parent.left
    anchors.topMargin: Style.timerBar.margin
    anchors.bottomMargin: Style.timerBar.margin
    boundsBehavior: Flickable.StopAtBounds
    interactive: true

    MouseArea
    {
      anchors.fill: parent
      onClicked: { mouse.accepted = false }
      onReleased: {
          if (!propagateComposedEvents) {
              propagateComposedEvents = true
          }
      }
    }

    property real sliderPosition: audioControl.sliderPosition

    onSliderPositionChanged:{
      // set time indicator position
      motorBar.timeIndicatorPosition=sliderPosition
      * backend.getAudioLengthInFrames()
      * Style.timerBar.frameToPixel;
      // get current visible pixel range:
      if(motorBar.timeIndicatorPosition < contentX
          || motorBar.timeIndicatorPosition > contentX + width){
          var proposedContentX = motorBar.timeIndicatorPosition -
            Style.timerBar.timeBarScrollOffset;
          contentX = proposedContentX < 0 ? 0 : proposedContentX;
          }
    }

    Column{
      id: timerBarColumn
      width: motorBar.width
      spacing: Style.timerBar.spacing
      TimerBar{
        id: motorBar
        color: Style.primitiveControl.moveColor
        keys: ["mot"]
        model: backend.motorPrimitives
        dragTarget: motDragger
        primitiveColors: Style.motorPrimitive.colors
        primitiveTextIDs: Style.motorPrimitive.textID
      }
      TimerBar{
        id: ledBar
        color: Style.primitiveControl.ledColor
        keys: ["led"]
        z: -1
        model: backend.ledPrimitives
        dragTarget: ledDragger
        primitiveColors: Style.ledPrimitive.colors
        primitiveTextIDs: Style.ledPrimitive.textID
        timeIndicatorPosition: motorBar.timeIndicatorPosition
      }
    }
  }

  Item{
    id: keyCatcher
    focus: true
    Keys.onPressed: console.log("god key")
  }

  Dragger{
    id: motDragger
    keys: motorBar.keys
  }

  Dragger{
    id: ledDragger
    keys: ledBar.keys
  }

  function handleSceneClick(mouse){
    console.log("scene click")
    if (!(mouse.modifiers & (Qt.ShiftModifier|Qt.ControlModifier))) {
        motorBar.dragTarget.clean()
        ledBar.dragTarget.clean()
    }
  }
}
