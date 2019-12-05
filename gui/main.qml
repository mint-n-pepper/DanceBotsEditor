import QtQuick 2.6
import QtQuick.Controls 2.0

import "components"
import "GuiStyle"

ApplicationWindow {
  id: appWindow
  width: fileControl.width
         + motorPrimitiveControl.width
         + ledPrimitiveControl.width
  height: audioControl.y
          + audioControl.height
  visible: true
  title: "Dancebots GUI"

  color: Style.main.color

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
    anchors.left: fileControl.left
    anchors.right: ledPrimitiveControl.right
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
    property bool hoverScrollRight: true

    property bool dragActive: motDragger.dragActive || ledDragger.dragActive

    onDragActiveChanged: {
      if(!dragActive){
        scrollTimer.stop()
      }
    }

    Connections{
      target: motDragger
      onDragXChanged: timerBarFlickable.processMouseMove(minChildX, maxChildX)
    }

    Connections{
      target: ledDragger
      onDragXChanged: timerBarFlickable.processMouseMove(minChildX, maxChildX)
    }

    function hoverScroll(){
      if(hoverScrollRight){
        if(contentX == contentWidth - width){
          return
        }
        var scrollStepUp = Style.timerBar.scrollSpeed
        if(contentX + scrollStepUp > contentWidth - width){
          scrollStepUp = contentWidth - width - contentX
        }
        contentX += scrollStepUp
        if(motDragger.dragActive){
          motDragger.x += scrollStepUp
        }
        if(ledDragger.dragActive){
          ledDragger.x += scrollStepUp
        }
      }else{
        if(contentX == 0){
          return
        }
        var scrollStepDown = Style.timerBar.scrollSpeed
        if(contentX - scrollStepDown < 0){
          scrollStepDown = contentX
        }

        contentX -= scrollStepDown
        if(motDragger.dragActive){
          motDragger.x -= scrollStepDown
        }
        if(ledDragger.dragActive){
          ledDragger.x -= scrollStepDown
        }
      }
    }

    Timer{
      id: scrollTimer
      interval: 25
      repeat: true
      onTriggered: timerBarFlickable.hoverScroll()
    }

    function processMouseMove(minX, maxX){
      if(minX - timerBarFlickable.contentX < Style.timerBar.scrollMargin){
        timerBarFlickable.hoverScrollRight = false
        scrollTimer.start()
      }else if(maxX - timerBarFlickable.contentX
               > timerBarFlickable.width - Style.timerBar.scrollMargin){
        timerBarFlickable.hoverScrollRight = true
        scrollTimer.start()
      }
      else{
        scrollTimer.stop()
      }
    }

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
      // update visible range only if drag is not active
      if(!dragActive){
      // get current visible pixel range:
      if(motorBar.timeIndicatorPosition < contentX
          || motorBar.timeIndicatorPosition > contentX + width){
          var proposedContentX = motorBar.timeIndicatorPosition -
            Style.timerBar.timeBarScrollOffset;
          contentX = proposedContentX < 0 ? 0 : proposedContentX;
          }
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
        isMotorBar: true
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

    Dragger{
      id: ledDragger
      keys: ledBar.keys
      width: motorBar.width
      function cleanOther(){
        motDragger.cleanAll()
      }
    }

    Dragger{
      id: motDragger
      width: motorBar.width
      keys: motorBar.keys
      function cleanOther(){
        ledDragger.cleanAll()
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

  function grabFocus(){
    keyCatcher.focus = true
  }

  function handleSceneClick(mouse){
    grabFocus()
    if (!(mouse.modifiers & (Qt.ShiftModifier|Qt.ControlModifier))) {
        cleanDraggers()
    }
  }

  function cleanDraggers(){
    motDragger.cleanAll()
    ledDragger.cleanAll()
  }

  function handleKey(event){
    switch(event.key){
    case Qt.Key_Escape:
      cleanDraggers()
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
