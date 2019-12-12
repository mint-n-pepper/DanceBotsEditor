import QtQuick 2.6
import QtQuick.Controls 2.0

import "components"
import "GuiStyle"

ApplicationWindow {
  id: appWindow
  width: Style.main.initialWidth
  height: ( titleBar.height
           + fileControl.height
           + ledPrimitiveControl.height
           + timerBarFlickable.height
           + audioControl.height
           + 4 * guiMargin)
  minimumWidth: Style.main.minWidth
  minimumHeight: ( titleBar.height
                  + fileControl.height
                  + ledPrimitiveControl.height
                  + timerBarFlickable.height
                  + audioControl.height
                  + 4 * guiMargin)

  visible: true
  title: "Dancebots GUI"

  color: Style.palette.mw_background

  property real frameToPixels: width / (Style.timerBar.secondsInWindow
                                         * backend.getSampleRate())

  property real guiMargin: width * Style.main.margin

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

  TitleBar{
    id: titleBar
    width: appWindow.width
  }

  MP3FileControl{
    id: fileControl
    width: appWindow.width
    anchors.top: titleBar.bottom
    controlWindowWidth: ledPrimitiveControl.width
  }

  MotorPrimitiveControl{
    id: motorPrimitiveControl
    anchors.top: fileControl.bottom
    anchors.topMargin: appWindow.guiMargin
    anchors.left: fileControl.left
    anchors.leftMargin: appWindow.guiMargin
    width: appWindow.width * (0.5 - 1.5 * Style.main.margin)
    height: width * Style.primitiveControl.heightRatio
  }

  LEDPrimitiveControl{
    id: ledPrimitiveControl
    anchors.left: motorPrimitiveControl.right
    anchors.leftMargin: appWindow.guiMargin
    anchors.top: motorPrimitiveControl.top
    width: appWindow.width * (0.5 - 1.5 * Style.main.margin)
    height: width * Style.primitiveControl.heightRatio
  }

  AudioControl{
    id: audioControl
    width: appWindow.width
    anchors.top: timerBarFlickable.bottom
    anchors.topMargin: appWindow.guiMargin
  }

  Flickable{
    id: timerBarFlickable
    width: parent.width < motorBar.width ? parent.width : motorBar.width
    height: timerBarColumn.spacing + 2 * motorBar.height
    contentWidth: motorBar.width
    contentHeight: timerBarColumn.height
    anchors.top: motorPrimitiveControl.bottom
    anchors.left: appWindow.left
    anchors.topMargin: appWindow.guiMargin
    boundsBehavior: Flickable.StopAtBounds
    interactive: true

    onContentWidthChanged: {
      contentX = visibleArea.xPosition * contentWidth
      timeIndicator.position = sliderPosition
                               * motorBar.lengthInFrames
                               * appWindow.frameToPixels;
    }

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
        var scrollStepUp = Style.timerBar.scrollSpeed * appWindow.width
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
        var scrollStepDown = Style.timerBar.scrollSpeed * appWindow.width
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
      if(minX - timerBarFlickable.contentX
          < Style.timerBar.scrollMargin * appWindow.width){
        timerBarFlickable.hoverScrollRight = false
        scrollTimer.start()
      }else if(maxX - timerBarFlickable.contentX
               > timerBarFlickable.width
               - Style.timerBar.scrollMargin * appWindow.width){
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
      timeIndicator.position=sliderPosition
      * motorBar.lengthInFrames * appWindow.frameToPixels;
      // update visible range only if drag is not active
      if(!dragActive){
      // get current visible pixel range:
      if(timeIndicator.position < contentX
          || timeIndicator.position > contentX + width){
          var proposedContentX = timeIndicator.position -
            Style.timerBar.timeBarScrollOffset;
          contentX = proposedContentX < 0 ? 0 : proposedContentX;
          }
      }
    }

    Column{
      id: timerBarColumn
      spacing: Style.timerBar.spacing * motorBar.height
      TimerBar{
        id: motorBar
        color: Style.palette.pc_moveBoxColor
        keys: ["mot"]
        model: backend.motorPrimitives
        lengthInFrames: (fileControl.width + motorPrimitiveControl.width
         + ledPrimitiveControl.width) / frameToPixels
        dragTarget: motDragger
        isMotorBar: true
        primitiveColors: Style.motorPrimitive.colors
        primitiveTextIDs: Style.motorPrimitive.textID
        controlBox: motorPrimitiveControl
      }
      TimerBar{
        id: ledBar
        color: Style.palette.pc_ledBoxColor
        keys: ["led"]
        z: -1
        lengthInFrames: motorBar.lengthInFrames
        model: backend.ledPrimitives
        dragTarget: ledDragger
        primitiveColors: Style.ledPrimitive.colors
        primitiveTextIDs: Style.ledPrimitive.textID
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

    Rectangle{
      id: timeIndicator
      color: Style.palette.tim_timeIndicator
      width: Style.timerBar.timeBarWidth * motorBar.height
      height: timerBarColumn.height
      property var position: 0
      x: position - width/2
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
    case Qt.Key_Backspace:
      motDragger.deleteAll()
      ledDragger.deleteAll()
      break;
    case Qt.Key_Space:
      backend.audioPlayer.togglePlay()
      break;
    }
  }
}
