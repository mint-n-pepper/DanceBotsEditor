import QtQuick 2.6
import dancebots.backend 1.0

import "../GuiStyle"

Canvas{
  id: root
  height: Style.timerBar.height
  width: 1000

  property color color
  property var beats: []
  property var keys
  property var model
  property var primitiveColors
  property var primitiveTextIDs

  // connect to done loading signal of backend to redraw rectangle
  Connections{
	  target: backend
	  onDoneLoading:{
      // resize rectangle to fit song
      width = backend.getAudioLengthInFrames() * Style.timerBar.frameToPixel;
      beats = backend.getBeats();
      requestPaint();
    }
  }

  DropArea{
    anchors.fill: parent
    id: dropArea
    keys: parent.keys

    onDropped:{
      console.log("dropped at " + drag.x + ", " + drag.y)
      var currentFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(currentFrame)
      if(beatLoc >= 0){
        drag.source.primitive.positionBeat = beatLoc
      }
      if(drag.source.parent === parent){
        drag.source.updatePrimitive();
      }else{
       // came from control box, add it to model and destroy delegate
       model.add(drag.source.primitive)
       drag.source.destroy()
       model.printPrimitives()
      }
      ghost.visible = false
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

  Repeater{
    id: primitiveView
    model: parent.model
    PrimitiveDelegate{
      primitive: model.item
    }
  }

  Rectangle{
    id: ghost
    visible: false
    color: Style.timerBar.ghostColorValid
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    height: Style.timerBar.height
    radius: Style.primitives.radius
  }

  onPaint: {
    var ctx = getContext("2d");
    ctx.fillStyle = color;
    ctx.fillRect(0, 0, width, height);
    for(var i=0; i < beats.length; i++){
      ctx.lineWidth = Style.timerBar.beatWidth;
      ctx.strokeStyle = Style.timerBar.beatColor;
      ctx.beginPath();
      var loc = beats[i] * Style.timerBar.frameToPixel;
      ctx.moveTo(loc, 0);
      ctx.lineTo(loc, height);
      ctx.stroke();
    }
  }
}
