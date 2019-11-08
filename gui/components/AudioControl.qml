import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
	id: root
	color: Style.motorControl.color

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
      // calculate average beat distance:
      songPositionSlider.value = currentPosMS
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

    onMoved: backend.audioPlayer.seek(value)
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
        backend.audioPlayer.play()
      }
    }
    Button
    {
      id: pauseButton
      width:Style.audioControl.buttonWidth
      height:Style.audioControl.buttonHeight
      text: "Pause"
      onClicked:
      {
        backend.audioPlayer.pause()
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
