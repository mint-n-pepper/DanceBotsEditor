import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
	id: root
  color: Style.main.color
  property alias sliderPosition: songPositionSlider.visualPosition

	Component.onCompleted:{
    setDisabled()
  }

  Connections{
    target: backend
    onDoneLoading:{
      setEnabled()
      backend.audioPlayer.setNotifyInterval(20);
      songPositionSlider.to =
        backend.getAudioLengthInFrames() / backend.getSampleRate() * 1000;
    }
  }

  Connections{
	  target: backend.audioPlayer
	  onNotify:{
      // set slider to current position in music,
      // but only if user is not dragging slider at the moment:
      if(!songPositionSlider.pressed){
        songPositionSlider.value = currentPosMS
      }
    }
  }

	function setEnabled(){
    buttonRow.enabled = true
	}

	function setDisabled(){
    buttonRow.enabled = false
	}

  Slider{
    id: songPositionSlider
    from: 0.0
    to: 1.0
    width: parent.width

    onPressedChanged:{
      if(!pressed){
        backend.audioPlayer.seek(value)
      }
    }
  }

	Row{
    id: buttonRow
    width: parent.width
    anchors.top: songPositionSlider.bottom
    Button
    {
      id: playButton
      width:Style.audioControl.buttonWidth
      height:Style.audioControl.buttonHeight
      text: "Play"
      onClicked:
      {
        backend.audioPlayer.togglePlay()
      }
    }
    Button
    {
      id: stopButton
      width:Style.audioControl.buttonWidth
      height:Style.audioControl.buttonHeight
      text: "Stop"
      onClicked:
      {
        backend.audioPlayer.stop()
      }
    }
	}
}
