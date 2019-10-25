import QtQuick 2.6

import "../GuiStyle"

Canvas{
  id: root
  height: Style.timerBar.height

  property color backgroundColor: "lightgray"

  onPaint: {
    var ctx = getContext("2d");
    ctx.fillStyle = backgroundColor;
    ctx.fillRect(0, 0, width, height);
    var beats = backend.getBeats();
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

  Connections{
		target: backend
		onDoneLoading:{
      // resize rectangle to fit song
      width = backend.getAudioLengthInFrames() * Style.timerBar.frameToPixel;
      requestPaint();
    }
	}
}