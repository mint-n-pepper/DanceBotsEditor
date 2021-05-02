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
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  height: appWindow.width * Style.primitives.height * Style.timerBar.height
  radius: Style.primitives.radius * height
  border.color: Style.palette.prim_border
  border.width: Style.primitives.borderWidth * height

  property var idleParent: null
  property bool isFromBar: false
  property var primitive: null
  property var dragTarget: null
  property bool showData: false
  property bool dragActive: dragArea.dragActive

  property real frameToPixels: appWindow.frameToPixels
  property bool isMotor: false

  property real beatBarWidth: 0.0

  onFrameToPixelsChanged: updatePrimitive()

  onPrimitiveChanged: updatePrimitive()

	function updatePrimitive(){
    // only update if there is a primitive
    if(primitive){
      textID.fullText = primitiveTextIDs[primitive.type]
      color= primitiveColors[primitive.type]
      x = beats[primitive.positionBeat] * appWindow.frameToPixels
          - beatBarWidth / 2.0
      var endBeat = primitive.positionBeat + primitive.lengthBeat
      endBeat = endBeat < beats.length ? endBeat : beats.length - 1
      width = (beats[endBeat]
              - beats[primitive.positionBeat]) * appWindow.frameToPixels
              + beatBarWidth
      updateToolTip()
    }
	} // update primitive

  Rectangle{
    id: resizeHandle
    color: Style.palette.prim_resizeHandleOverlay
    anchors.right: root.right
    opacity: Style.primitives.resizeHandleOpacity
    height: root.height
    width: dragArea.resizeMargin
    visible: root.isFromBar
  }

  Rectangle{
    height: Style.primitives.resizeHandleSmallMarkHeight * root.height
    radius: width / 2.0
    width: root.border.width
    anchors.left: resizeHandle.left
    anchors.verticalCenter: root.verticalCenter
    anchors.leftMargin: resizeHandle.width/2.0 - root.border.width
    color: Style.palette.prim_resizeHandleSmallMark
    visible: root.isFromBar
  }

  Rectangle{
    // redraw border to hide uneven resize handle borders
    id: borderRect
    height: root.height
    width: root.width
    radius: root.radius
    border.color: Style.palette.prim_border
    border.width: root.border.width
    color: "transparent"
  }

	Text
	{
		id: textID
    property var fullText: "Default Name"
    text: fullText[0]
    color: Style.palette.prim_text
    x: Style.primitives.textPosX * root.height
    y: Style.primitives.textPosY * root.height
    font.pixelSize: Style.primitives.textSize * root.height
    font.bold: Style.primitives.textBold
    Text
    {
      text: textID.fullText.substr(1)
      elide: Text.ElideRight
      clip: true
      width: root.width - textID.width - textID.x
      color: textID.color
      anchors.left: textID.right
      anchors.top: textID.top
      font.pixelSize: Style.primitives.textSize * root.height
      font.bold: Style.primitives.textBold
    } // text
  } // text

  MouseArea{
    id: dragArea
    anchors.fill: parent
    drag.threshold: 2

    property bool controlPressed: false
    property bool shiftPressed: false
    property bool dragActive: drag.active

    property var resizeMargin: Style.primitives.resizeMarginRight
                              * appWindow.avgBeatWidth
    property bool doResize: false
    hoverEnabled: true

    onWidthChanged: {
      if(resizeMargin > width / 2){
        resizeMargin = width / 2
      }else{
        resizeMargin = Style.primitives.resizeMarginRight
                              * appWindow.avgBeatWidth
      }
    }

    onDragActiveChanged: {
      if(dragActive){
        // check if primitive was already selected
        // and clean if neither control or shift were pressed
        if(parent.state !== "onDrag"){
          if(!shiftPressed){
            dragTarget.clean(root)
          }
          parent.state = "onDrag"
        }
        dragTarget.startDrag(controlPressed)
      }else{
        dragTarget.endDrag()
      }
    }

    onPositionChanged:{
      if(doResize && pressed){
        // keep cursor shape as horizontal resize cursor
        cursorShape = Qt.SizeHorCursor
        // do resize
        var currentFrame = (parent.x + mouseX) / appWindow.frameToPixels;
        if(currentFrame > backend.getAudioLengthInFrames()){
          currentFrame = backend.getAudioLengthInFrames() - 1
        }
        var beatLoc = backend.getBeatAtFrame(currentFrame) + 1
        var newLength = beatLoc - parent.primitive.positionBeat
        if(newLength < 1){
          newLength = 1
        }
        if(newLength < parent.primitive.lengthBeat){
          // decrease size:
          idleParent.parent.freeOccupied(parent.primitive)
          parent.primitive.lengthBeat = newLength
          idleParent.parent.setOccupied(parent.primitive)
          parent.updatePrimitive()
        }else if(newLength > parent.primitive.lengthBeat){
          // check if there is space:
          var start = parent.primitive.positionBeat + parent.primitive.lengthBeat
          var end = parent.primitive.positionBeat + newLength
          if(end > idleParent.parent.occupied.length - 1){
            end = idleParent.parent.occupied.length - 1
          }
          var notFree = false
          for(var i = start; i < end; ++i){
            notFree |= idleParent.parent.occupied[i]
          }

          if(!notFree){
            // space available, resize
            parent.primitive.lengthBeat = end - parent.primitive.positionBeat
            idleParent.parent.setOccupied(parent.primitive)
            parent.updatePrimitive()
          }
        }
      }else{
        if(!dragActive && isFromBar
               && mouseX > width - resizeMargin){
          // if not resizing , figure out in what part of the primitive the
          // cursor is and then change the mouse pointer accordingly
          cursorShape = Qt.SizeHorCursor
        }else{
          cursorShape = Qt.SizeAllCursor
        }
      }
    }

    onPressed:{
      appWindow.grabFocus()
      controlPressed = (mouse.modifiers & Qt.ControlModifier)
      shiftPressed = (mouse.modifiers & Qt.ShiftModifier)
      doResize = isFromBar && mouseX > width - resizeMargin
      if(doResize){
        timerBarFlickable.interactive = false
        drag.target= null
      }else{
        drag.target= dragTarget
      }
      mouse.accepted = true
    }

    onReleased: {
      // unless a drag is active, handle de- selection
      if (!drag.active && !doResize && isFromBar) {
        // if shift was pressed, we keep selecting and do not
        // deselect
        if(shiftPressed){
          // select:
          parent.state = "onDrag"
        }else if(controlPressed){
          // with control pressed, we toggle:
          if(parent.state === "onDrag"){
            // deselect
            parent.state = "idle"
          }else{
            parent.state = "onDrag"
          }
        }else{
          // with no modifiers:
          // deselect all others if there is more than one primitive selected
          if(dragTarget.children.length > 1){
            dragTarget.clean(root)
          // toggle if only one selected
          }else if(parent.state == "onDrag"){
            dragTarget.clean()
          }else{
            parent.state = "onDrag"
            dragTarget.clean(root)
          }
        }
      }
      doResize = false
      timerBarFlickable.interactive = true
    }

    onEntered: showTimer.start()
    onExited: {showTimer.stop(); showData=false}

    Timer {
      id: showTimer
      interval: 250
      onTriggered: showData = true
    }

  } // mouse area


  states: [
    State {
        name: "idle"
        ParentChange { target: root; parent: idleParent }
        PropertyChanges{target: selectionHighlight; visible: false}
    },
    State {
        name: "onDrag"
        ParentChange { target: root; parent: dragTarget }
        PropertyChanges{target: selectionHighlight; visible: true && isFromBar}
    }
  ]

  function deselect(){
    state="idle"
  }

  Rectangle{
    id: selectionHighlight
    visible: false
    color: Style.palette.prim_highlight
    anchors.fill: root
    opacity: Style.primitiveControl.selectionHighlightOpacity
    border.color: Style.palette.prim_border
    border.width: Style.primitives.borderWidth * height
  }

  function updateToolTip(){
    toolTip.update()
  }

  PrimitiveToolTip{
    id: toolTip
  }
}
