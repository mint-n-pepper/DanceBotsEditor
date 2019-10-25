import QtQuick 2.6
import dancebots.backend 1.0

import "../GuiStyle"

Canvas{
  id: root
  height: Style.timerBar.height

  property color color: "lightgray"
  property var beats: [] // empty beats
  property var currentPos: 10

  Connections{
	  target: backend
	  onDoneLoading:{
      // resize rectangle to fit song
      width = backend.getAudioLengthInFrames() * Style.timerBar.frameToPixel;
      beats = backend.getBeats();
      requestPaint();
      primitiveView.model = backend.motorPrimitives
    }
  }

  MotorPrimitive{
    id: dragPrimitive
    type: MotorPrimitive.Type.eStraight
    lengthBeat: 4
  }

  MouseArea {
    id: clickArea
    anchors.fill: parent
    onClicked: {
      var addPrimitive = motorPrimitiveFactory.createObject(parent)
      addPrimitive.positionBeat = currentPos
      addPrimitive.lengthBeat = 4
      currentPos += 5
      primitiveView.model.add(addPrimitive);
    }
  }

   Component {
        id: motorPrimitiveFactory
        MotorPrimitive{}
    }

  Repeater{
    id: primitiveView
    Rectangle{
      height: Style.motorPrimitive.height
      radius: Style.motorPrimitive.radius
      anchors.verticalCenter: parent.verticalCenter
      x: beats[model.display.positionBeat] * Style.timerBar.frameToPixel
      width: {(beats[model.display.positionBeat+model.display.lengthBeat]
              - beats[model.display.positionBeat]) * Style.timerBar.frameToPixel}
    }
  }

  onPaint: {
    var ctx = getContext("2d");
    ctx.fillStyle = color;
    ctx.fillRect(0, 0, width, height);
    for(var i=0; i < beats.length; i++){
      ctx.lineWidth = 2;
      ctx.strokeStyle = Style.timerBar.beatColor;
      ctx.beginPath();
      var loc = beats[i] * Style.timerBar.frameToPixel;
      ctx.moveTo(loc, 0);
      ctx.lineTo(loc, height);
      ctx.stroke();
    }
  }
}
