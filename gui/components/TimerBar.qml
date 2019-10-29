import QtQuick 2.6
import dancebots.backend 1.0

import "../GuiStyle"

Canvas{
  id: root
  height: Style.timerBar.height

  property color color: "lightgray"
  property var beats: [] // empty beats
  property var currentPos: 10
  property var keys: []

  Connections{
	  target: backend
	  onDoneLoading:{
      // resize rectangle to fit song
      width = backend.getAudioLengthInFrames() * Style.timerBar.frameToPixel;
      beats = backend.getBeats();
      requestPaint();
      primitiveView.model = backend.motorPrimitives
      backend.printMotPrimitives()
    }
  }

  DropArea{
  anchors.fill: parent
    id: dropArea
    keys: keys
    onDropped:{
      console.log("dropped at " + drag.x + ", " + drag.y)
    }
  }

  Repeater{
    id: primitiveView
    MotorPrimitiveDelegate{
      primitive: model.item
      keys: dropArea.keys
    }

    onItemRemoved:{ backend.printMotPrimitives()}
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
