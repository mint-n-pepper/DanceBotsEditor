import QtQuick 2.13
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  height: Style.primitives.height
  radius: Style.primitives.radius
  border.color: Style.primitives.borderColor
  border.width: Style.primitives.borderWidth

  property var idleParent: null
  property bool isFromBar: false
  property var primitive: null
  property var dragTarget: null
  property bool showData: false

  onPrimitiveChanged: updatePrimitive()

  onEnabledChanged: {
    if(enabled){
      color = primitiveColors[primitive.type]
    }else{
      color = Style.primitives.disabledColor
    }
  }

	function updatePrimitive(){
		textID.text=primitiveTextIDs[primitive.type]
    color=primitiveColors[primitive.type]
    x= beats[primitive.positionBeat] * Style.timerBar.frameToPixel
    var endBeat = primitive.positionBeat + primitive.lengthBeat
    endBeat = endBeat < beats.length ? endBeat : beats.length - 1
    width= (beats[endBeat]
            - beats[primitive.positionBeat]) * Style.timerBar.frameToPixel
	} // update primitive

	Text
	{
		id: textID
		text: ""
    color: Style.primitives.textColor
    x: Style.primitives.textPosX
    y: Style.primitives.textPosY
    font.pixelSize: Style.primitives.textSize
    font.bold: Style.primitives.textBold
	} // text

  MouseArea{
    id: dragArea
    anchors.fill: parent
    drag.threshold: 2

    property bool controlPressed: false
    property bool shiftPressed: false
    property bool dragActive: drag.active

    property var resizeMargin: Style.primitives.sizePixelMarginRight
    property bool doResize: false

    hoverEnabled: parent.isFromBar

    onWidthChanged: {
      if(resizeMargin > width / 2){
        resizeMargin = width / 2
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
      // figure out in what part of the primitive the cursor is
      // and then change the mouse pointer accordingly
      if(parent.isFromBar && mouseX > width - resizeMargin){
        cursorShape = Qt.SizeHorCursor
      }else{
        cursorShape = Qt.ArrowCursor
      }

      if(doResize && pressed){
        // do resize
        var currentFrame = (parent.x + mouseX) / Style.timerBar.frameToPixel;
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
      }
    }

    onPressed:{
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
      if (!drag.active && !doResize) {
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
          // with no modifiers, toggle while deselecting others
          if(parent.state == "onDrag"){
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
        PropertyChanges{target: selectionHighlight; visible: true}
    }
  ]

  function deselect(){
    state="idle"
  }

  Rectangle{
    id: selectionHighlight
    visible: false
    color: Style.primitives.highlightOverlayColor
    anchors.fill: parent
  }

  Rectangle{
    id: primitiveData
    anchors.top: parent.bottom
    visible: showData && isFromBar && !dragArea.dragActive
    color: Style.primitives.toolTipBgColor
    width: dataColumn.width
    height:dataColumn.height
    radius: Style.primitives.radius
    Column{
      id:dataColumn
      Text{
        text: "Freq: 1.00"
        font.pixelSize: Style.primitives.toolTipFontPixelSize
        color: Style.primitives.toolTipFontColor
        onVisibleChanged: {
          if(visible){text="Freq: " + primitive.frequency.toFixed(2)}
        }
        padding: Style.primitives.toolTipPadding
      }
      Text{
        visible: primitiveData.visible && primitive.velocity !== undefined
        text: "Vel: 40"
        font.pixelSize: Style.primitives.toolTipFontPixelSize
        color: Style.primitives.toolTipFontColor
        padding: Style.primitives.toolTipPadding
        onVisibleChanged: {
          if(visible){
            if(primitive.type === MotorPrimitive.Type.Custom){
              text="Vel L: " + primitive.velocity
            }else{
              text="Vel: " + primitive.velocity
            }
          }
        }
      }
      Text{
        visible: {primitiveData.visible
                 && primitive.type === MotorPrimitive.Type.Custom
                 && primitive.velocityRight !== undefined}
        text: "Vel R: 40"
        padding: Style.primitives.toolTipPadding
        font.pixelSize: Style.primitives.toolTipFontPixelSize
        color: Style.primitives.toolTipFontColor
        onVisibleChanged: {
          if(visible){text="Vel R: " + primitive.velocityRight}
        }
      }

      Row{
        padding: 4.0
        visible: { primitiveData.visible
          && primitive.type !== LEDPrimitive.Type.KnightRider
          && primitive.type !== LEDPrimitive.Type.Random
          && primitive.leds !== undefined
        }
        onVisibleChanged: {
          if(visible){
            for(var i = 0; i < primitive.leds.length; i++){
              if(primitive.leds[i]){
                ledRepeater.itemAt(i).color =  Style.primitives.ledToolTipOnColor
              }else{
                ledRepeater.itemAt(i).color =  Style.primitives.ledToolTipOffColor
              }
            }
          }
        }
        Repeater{
          id: ledRepeater
          model: 8
          delegate: Rectangle{
            width: Style.primitives.ledToolTipLEDSize
            height: Style.primitives.ledToolTipLEDSize
            radius: Style.primitives.ledToolTipLEDSize / 2
            color: Style.primitives.ledToolTipOffColor
          }
        }
      }
    }
  }
}
