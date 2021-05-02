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
import QtQuick.Window 2.1

import "components"
import "GuiStyle"

ApplicationWindow {
  id: appWindow
  width: Style.main.initialWidth
  minimumWidth: Style.main.minWidth
  minimumHeight: componentsHeight
  property var componentsHeight: ( titleBar.height
                  + fileControl.height
                  + ledPrimitiveControl.height
                  + timerBarFlickable.height
                  + audioControl.height
                  + 4 * guiMargin)

  onHeightChanged: {
    // unless maximized, enforce proper window height
    if(visibility !== Window.Maximized){
      height = componentsHeight
    }
  }

  onWidthChanged:{
    if(backend.mp3Loaded && backend.getAverageBeatFrames() > 0){
      frameToPixels = width * Style.timerBar.beatSpacing
                                    / backend.getAverageBeatFrames()
    }
  }

  onVisibilityChanged: {
    if(Window.Windowed === visibility){
      // after return from maximized, enforce proper window height
      height = componentsHeight
    }
  }

  visible: true
  title: "DanceBots Editor"

  color: Style.palette.mw_background

  property int initAvgBeatFrames: 23000 // daft punk get lucky value
  property real avgBeatWidth: width * Style.timerBar.beatSpacing
  property real frameToPixels: avgBeatWidth / initAvgBeatFrames

  property real guiMargin: width * Style.main.margin

Connections{
  target: backend
  onDoneLoading:{
    if(result && backend.getAverageBeatFrames() > 0){
      // adjust frame to Pixels to get beat spacing independent of bpm
      frameToPixels = avgBeatWidth / backend.getAverageBeatFrames()
    }
  }
}

  MouseArea{
    id: sceneClickCatcher
    anchors.fill: parent
    onClicked: {
      handleSceneClick(mouse)
    }
    enabled: backend.mp3Loaded
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
  }

  LEDPrimitiveControl{
    id: ledPrimitiveControl
    anchors.left: motorPrimitiveControl.right
    anchors.leftMargin: appWindow.guiMargin
    anchors.top: motorPrimitiveControl.top
    width: appWindow.width * (0.5 - 1.5 * Style.main.margin)
    height: motorPrimitiveControl.height
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
      faders.contentWidth = contentWidth
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

    property real scrollMargin: Style.timerBar.scrollMargin * appWindow.width

    function processMouseMove(minX, maxX){
      if(minX - timerBarFlickable.contentX
          < timerBarFlickable.scrollMargin){
        timerBarFlickable.hoverScrollRight = false
        scrollTimer.start()
      }else if(maxX - timerBarFlickable.contentX
               > timerBarFlickable.width
               - timerBarFlickable.scrollMargin){
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
      onClicked: {
        mouse.accepted = false
        // only jump if the mouse click is not deselecting primitives:
        if(!ledDragger.hasChildren && !motDragger.hasChildren){
          // jump song position to click location
          var timeMS = Math.round(mouseX / appWindow.frameToPixels
                                        / backend.getSampleRate() * 1000.0)
         audioControl.songPositionMS = timeMS
         if(backend.mp3Loaded){
           backend.audioPlayer.seek(timeMS)
          }
        }
      }
      onReleased: {
        if (!propagateComposedEvents) {
            propagateComposedEvents = true
        }
      }
      enabled: backend.mp3Loaded
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
        color: Style.palette.tim_moveBoxColor
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
        color: Style.palette.tim_ledBoxColor
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
      height: timerBarColumn.height * Style.timerBar.timeBarHeight
      radius: width / 2.0
      property var position: 0
      x: position - width / 2.0
      y: (timerBarColumn.height - height) / 2.0
    }
  } // timer bar flickable

  Faders{
    id: faders
    visible: backend.mp3Loaded
    anchors.fill: timerBarFlickable
    contentPosition: timerBarFlickable.contentX
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

  Rectangle{
    anchors.top: fileControl.bottom
    width: appWindow.width
    height: appWindow.height - titleBar.height - fileControl.height
    color: Style.palette.mw_disableOverlay
    visible: !backend.mp3Loaded
  }

  function setRobotDataChanged(){
    audioControl.robotSoundNeedsUpdate = true
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
      audioControl.togglePlay()
      break;
    }
  }

  ConfirmPopup{
		id: closeConfirmPopup
		detailText: "Closing the editor"
		text: "Are you sure?"
		function yesClicked(){
      Qt.quit()
		}
	}

  onClosing:{
    closeConfirmPopup.open()
    close.accepted = false
  }

}
