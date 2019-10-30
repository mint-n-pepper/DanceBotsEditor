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
      var currentFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(currentFrame)
      if(beatLoc >= 0){
        drag.source.primitive.positionBeat = beatLoc
      }
      drag.source.updatePrimitive();
    }

    onEntered:{
      var enterFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(enterFrame)
      if(beatLoc >= 0){
        ghost.x = beats[beatLoc] * Style.timerBar.frameToPixel
        var endBeat = beatLoc + drag.source.primitive.lengthBeat
        if(endBeat >= beats.length) endBeat = beats.length - 1
        ghost.width = (beats[endBeat] - beats[beatLoc]) * Style.timerBar.frameToPixel
        ghost.visible = true
      }
    }
    onExited:{
      ghost.visible = false
    }
    onPositionChanged:{
      var currentFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(currentFrame)
      if(beatLoc >= 0){
        ghost.x = beats[beatLoc] * Style.timerBar.frameToPixel
      }
    }
  }

  Rectangle{
    id: ghost
    visible: false
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    height: Style.primitives.height
    radius: Style.primitives.radius
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
