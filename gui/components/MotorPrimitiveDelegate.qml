import QtQuick 2.0
import dancebots.backend 1.0
import "../GuiStyle"

  Rectangle{
		id: root
    height: Style.primitives.height
		radius: Style.primitives.radius

    property bool dragActive: dragArea.drag.active
    property var keys: []

    property MotorPrimitive primitive: MotorPrimitive{
			type: MotorPrimitive.Type.eStraight
      frequency: 1.0
      positionBeat: 0
      lengthBeat: 0
      velocity: 0
      velocityRight: 0
		}

    onPrimitiveChanged: updatePrimitive()

		function updatePrimitive(){
			textID.text=Style.motorPrimitive.textID[primitive.type]
      color=Style.motorPrimitive.colors[primitive.type]
      x= parent.beats[primitive.positionBeat] * Style.timerBar.frameToPixel
      width= (parent.beats[primitive.positionBeat+primitive.lengthBeat]
              - parent.beats[primitive.positionBeat]) * Style.timerBar.frameToPixel
      anchors.verticalCenter = parent.verticalCenter
		}

		Text
		{
			id: textID
			text: Style.motorPrimitive.textID[primitive.type]
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
            if(Drag.target !== null){
              primitive.positionBeat = 10
              Drag.drop()
              backend.printMotPrimitives()
              updatePrimitive()
            }else{
              // remove item from model
              backend.motorPrimitives.remove(index);
            }
        }
    }

  }
