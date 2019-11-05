import QtQuick 2.0
import dancebots.backend 1.0
import "../GuiStyle"

  Rectangle{
		id: root
    height: Style.primitives.height
		radius: Style.primitives.radius

    property bool dragActive: dragArea.drag.active
    property var primitive: null

    onPrimitiveChanged: updatePrimitive()

		function updatePrimitive(){
    console.log("updating primitive, parent = " + parent)
			textID.text=primitiveTextIDs[primitive.type]
      color=primitiveColors[primitive.type]
      x= beats[primitive.positionBeat] * Style.timerBar.frameToPixel
      var endBeat = primitive.positionBeat+primitive.lengthBeat
      endBeat = endBeat < beats.length ? endBeat : beats.length - 1
      width= (beats[endBeat]
              - beats[primitive.positionBeat]) * Style.timerBar.frameToPixel
      anchors.verticalCenter = parent.verticalCenter
		}

		Text
		{
			id: textID
			text: primitiveTextIDs[primitive.type]
      color: Style.primitives.textColor
      x: Style.primitives.textPosX
      y: Style.primitives.textPosY
      font.pixelSize: Style.primitives.textSize
      font.bold: Style.primitives.textBold
		}

    MouseArea{
      id: dragArea
      anchors.fill: parent
      drag.target: parent
      property bool controlPressed: false
      property bool shiftPressed: false

      onPressed:{
        controlPressed = (mouse.button === Qt.LeftButton)
                    && (mouse.modifiers & Qt.ControlModifier)
        shiftPressed = (mouse.button === Qt.LeftButton)
                    && (mouse.modifiers & Qt.ShiftModifier)
      }

    }

    Drag.keys: keys
    Drag.hotSpot.x: 0
    Drag.hotSpot.y: height/2
    Drag.dragType: Drag.Automatic

    onDragActiveChanged:{
        if(dragActive){
            console.log("Start drag of " + Drag.keys)
            anchors.verticalCenter= undefined
            Drag.start()
           if(dragArea.controlPressed){
                Drag.proposedAction=Qt.CopyAction
                console.log('copy')
            }else{
                Drag.proposedAction=Qt.MoveAction
                console.log('move')
            }

        }else{
            console.log("End drag of " + Drag.keys + " tgt = " + Drag.target)
            console.log("parent is " + parent + " has model " + parent.model)
            if(Drag.target !== null){
              Drag.drop()
            }else if(parent.model){
              // remove item from model, if it was on the timer bar
              parent.model.remove(index);
            }else{
              // item was dragged from primitive control and was
              // dropped onto an invalid area
              parent.destroy()
            }
        }
    }

  }
