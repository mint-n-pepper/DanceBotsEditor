import QtQuick 2.6
import dancebots.backend 1.0

import "../GuiStyle"

Canvas{
  id: root
  height: Style.timerBar.height
  width: 1000

  property color color
  property var beats: []
  property var occupied: []
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
      // clear occupancy array:
      occupied.length = 0
      for(var i = 0; i < beats.length; ++i){
        occupied.push(false)
      }
    }
  }

  DropArea{
    anchors.fill: parent
    id: dropArea
    keys: parent.keys

    function doDrop(){
      if(drag.source.parent === parent){
        // source is timerbar itself, just update primitive and
        // set location beats to occupied
        drag.source.anchors.verticalCenter=parent.verticalCenter
        drag.source.updatePrimitive();
        setOccupied(drag.source.primitive)
      }else{
        // source is control box, add it to model and destroy delegate
        model.add(drag.source.primitive)
        drag.source.destroy()
        model.printPrimitives()
        // don't have to update occupied as this happens from repeater
        // callback onItemAdded
      }
    }

    function handleInvalidDrop(){
      // cannot drop
      if(drag.source.parent === parent){
        // if source is timer bar, do nothing and let it bounce back
        drag.source.updatePrimitive();
        // and reset occupied
        setOccupied(drag.source.primitive)
      }else{
        // if source is control box, delete the primitive
        drag.source.destroy()
      }
    }

    onDropped:{
      console.log("dropped at " + drag.x + ", " + drag.y)
      var currentFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(currentFrame)
      if(beatLoc >= 0){
        var validLength = getValidLength(beatLoc, drag.source.primitive.lengthBeat)
        if(validLength > 0){
          // can drop, set length and position:
          drag.source.primitive.positionBeat = beatLoc;
          drag.source.primitive.lengthBeat = validLength;
          doDrop();
        }else{
          handleInvalidDrop();
        }
      }else{
        // also invalid drop if beat location is not valid:
        handleInvalidDrop();
      }
      // make ghost disappear in any case
      ghost.visible = false
    }

    onEntered:{
        ghost.lengthBeat = drag.source.primitive.lengthBeat
    }

    onExited:{
      ghost.visible = false
    }

    onPositionChanged:{
      var currentFrame = drag.x / Style.timerBar.frameToPixel;
      var beatLoc = backend.getBeatAtFrame(currentFrame)
      if(beatLoc >= 0){
        ghost.visible = true
        ghost.positionBeat = beatLoc
        var validLength = getValidLength(beatLoc, drag.source.primitive.lengthBeat)
        if(validLength > 0){
          ghost.isValid = true
          ghost.lengthBeat = validLength
        }else{
          ghost.isValid = false
        }

        // check if length of drag shape can be corrected:
        var end = drag.source.primitive.lengthBeat + beatLoc
        if(end < beats.length){
          drag.source.width= (beats[end] - beats[beatLoc])
            * Style.timerBar.frameToPixel;
        }
      }
    }
  }

  function getValidLength(start, length){
    var validLength = 0
    var end = start + length;
    if(end > occupied.length - 1){
      end = occupied.length - 1;
    }
    for(var i = start; i < end; ++i){
      if(!occupied[i]){
        ++validLength;
      }else{
        break;
      }
    }
    return validLength;
  }

  Repeater{
    id: primitiveView
    model: parent.model
    PrimitiveDelegate{
      primitive: model.item
      anchors.verticalCenter: parent.verticalCenter
    }

    onItemRemoved: {
      freeOccupied(item.primitive)
      console.log('occupied = ' + occupied)
    }

    onItemAdded: {
      setOccupied(item.primitive)
      console.log('occupied = ' + occupied)
    }
  }

  function setOccupied(primitive){
    var end = primitive.positionBeat + primitive.lengthBeat;
    for(var i = primitive.positionBeat; i < end; ++i){
      occupied[i] = true;
    }
  }

  function freeOccupied(primitive){
    var end = primitive.positionBeat + primitive.lengthBeat;
    for(var i = primitive.positionBeat; i < end; ++i){
      occupied[i] = false;
    }
  }

  Rectangle{
    id: ghost
    visible: false
    property bool isValid: false
    property int lengthBeat: 0
    property int positionBeat: 0
    color: Style.timerBar.ghostColorInvalid
    anchors.verticalCenter: parent.verticalCenter
    height: Style.timerBar.height
    radius: Style.primitives.radius

    onIsValidChanged: update()
    onLengthBeatChanged: update()
    onPositionBeatChanged: update()

    function update(){
      color = isValid ? Style.timerBar.ghostColorValid : Style.timerBar.ghostColorInvalid
      x = beats[positionBeat] * Style.timerBar.frameToPixel
      var endBeat = positionBeat + lengthBeat
      ghost.width = (beats[endBeat] - beats[positionBeat]) * Style.timerBar.frameToPixel
    }
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
