import QtQuick 2.0
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
  property var primitive: MotorPrimitive{}
  property var dragTarget: null

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
    drag.target: dragTarget
    drag.threshold: 2

    property bool controlPressed: false
    property bool shiftPressed: false
    property bool dragActive: drag.active

    onDragActiveChanged: {
      if(dragActive){
        dragTarget.startDrag(controlPressed)
      }else{
        dragTarget.endDrag()
      }
    }

    onPressed:{
      controlPressed = (mouse.modifiers & Qt.ControlModifier)
      shiftPressed = (mouse.modifiers & Qt.ShiftModifier)
      parent.state="onDrag"
      mouse.accepted = true
    }

    onReleased: {
      console.log("Released")
      if (!drag.active) {
          console.log("release in non drag event")
      }
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

  onStateChanged: console.log("State changed to " + state)

  function deselect(){
    state="idle"
  }

  Rectangle{
    id: selectionHighlight
    visible: false
    color: Style.primitives.highlightOverlayColor
    anchors.fill: parent
  }

}
