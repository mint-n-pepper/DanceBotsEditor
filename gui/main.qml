import QtQuick 2.6
import QtQuick.Controls 2.0

import "Components"
import "GuiStyle"

ApplicationWindow {
  id: appWindow
  width: Style.main.width
  height: Style.main.height
  visible: true
  title: "Dancebots GUI"

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

  FileProcessPopup{
    id: fileProcess
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
    width: parent.width < timerBarColumn.width ? parent.width : timerBarColumn.width
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
        controlBox: motorPrimitiveControl
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
        controlBox: ledPrimitiveControl
      }
    }
  }

  Item{
    id: keyCatcher
    onActiveFocusChanged:{
      if(activeFocusItem === null){
        grabFocus()
      }
    }
    focus: true
    Keys.onPressed: handleKey(event)
  }

  Dragger{
    id: ledDragger
    keys: ledBar.keys
  }

  Dragger{
    id: motDragger
    keys: motorBar.keys
  }

  function grabFocus(){
    keyCatcher.focus = true
  }

  function handleSceneClick(mouse){
    if (!(mouse.modifiers & (Qt.ShiftModifier|Qt.ControlModifier))) {
        motDragger.clean()
        ledDragger.clean()
    }
  }

  function handleKey(event){
    switch(event.key){
    case Qt.Key_Escape:
      motDragger.clean()
      ledDragger.clean()
      break;
    case Qt.Key_Delete:
      motDragger.deleteAll()
      ledDragger.deleteAll()
      break;
    case Qt.Key_Space:
      backend.audioPlayer.togglePlay()
      break;
    }
  }
}
