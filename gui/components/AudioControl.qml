import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  color: "transparent"
  property alias sliderPosition: songPositionSlider.visualPosition

  height: songPositionSlider.implicitHeight
          + playControlBox.height

  Component.onCompleted:{
    setDisabled()
  }

  Connections{
    target: backend
    onDoneLoading:{
      if(result){
        setEnabled()
        backend.audioPlayer.setNotifyInterval(30);
        songPositionSlider.value = 0
        songPositionSlider.to =
          backend.getAudioLengthInFrames() / backend.getSampleRate() * 1000;
      }
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
    songPositionSlider.enabled = true
  }

  function setDisabled(){
    songPositionSlider.enabled = false

  }

  Slider{
    id: songPositionSlider
    from: 0.0
    to: 1.0
    width: parent.width
    focusPolicy: Qt.NoFocus

    onPressedChanged:{
      appWindow.grabFocus()
      if(!pressed){
        backend.audioPlayer.seek(value)
      }
    }
  }

  Item{
    id: playControlBox
    width: Style.audioControl.playControlBoxWidth
    anchors.top: songPositionSlider.bottom
    height: Style.audioControl.buttonHeight
            + 2 * Style.audioControl.padding
    Row{
      id: playControlRow
      anchors.topMargin: Style.audioControl.padding
      spacing: Style.audioControl.spacing
      padding: Style.audioControl.padding
      Button
      {
        id: playButton
        focusPolicy: Qt.NoFocus
        width:Style.audioControl.buttonWidth
        height:Style.audioControl.buttonHeight
        icon.source: "../icons/playPause.svg"
        icon.color: Style.audioControl.iconColor
        display: Button.IconOnly
        onPressed: appWindow.grabFocus()
        onClicked:
        {
          backend.audioPlayer.togglePlay()
        }
      }
      Button
      {
        id: stopButton
        focusPolicy: Qt.NoFocus
        width:Style.audioControl.buttonWidth
        height:Style.audioControl.buttonHeight
        icon.source: "../icons/stop.svg"
        icon.color: Style.audioControl.iconColor
        display: Button.IconOnly
        onPressed: appWindow.grabFocus()
        onClicked:
        {
          backend.audioPlayer.stop()
        }
      }
      Rectangle{
        id:timerDisplay
        height: Style.audioControl.buttonHeight
        width: Style.audioControl.timerWidth
        color: Style.audioControl.timerBGColor
        Text{
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.rightMargin: Style.audioControl.timerTextMarginRight
          text: (songPositionSlider.value / 1000).toFixed(1)
          font.pixelSize: Style.audioControl.timerFontPixelSize
          color: Style.audioControl.timerFontColor
        }
      }
    }

    Connections{
      target: backend.audioPlayer
      onVolumeAvailable:{
        volumeSlider.value = backend.audioPlayer.getCurrentLogVolume()
      }
    }

    Slider{
      id: volumeSlider
      from: 0.0
      to: 1.0
      value: 1.0
      width: parent.width - playControlRow.width
      anchors.verticalCenter: playControlRow.verticalCenter
      anchors.left: playControlRow.right
      focusPolicy: Qt.NoFocus
      live: true
      onPressedChanged: appWindow.grabFocus()
      onValueChanged: backend.audioPlayer.setVolume(value)

      handle: Rectangle{
        width: Style.audioControl.volumeSliderSize
        height: width
        radius: width/2
        color: Style.audioControl.volumeSliderHandleBGColor
        x: volumeSlider.leftPadding
           + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
        anchors.verticalCenter: volumeSlider.verticalCenter
        Image{
          source: "../icons/volume.svg"
          anchors.centerIn: parent
          width: Style.audioControl.volumeSliderIconScale * parent.width
          height: width
        }
      }
    }
  }
}
