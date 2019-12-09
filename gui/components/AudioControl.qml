import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import "../GuiStyle"

Item {
  id: root
  property alias sliderPosition: songPositionSlider.visualPosition

  height: songPositionSlider.height + playControlBox.height
          + controlsHeight * Style.audioControl.sliderButtonSpacing

  property int controlsHeight: appWindow.width * Style.audioControl.controlsHeight

  enabled: false

  Connections{
    target: backend
    onDoneLoading:{
      if(result){
        enabled = true
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

  ScalableSlider{
    id: songPositionSlider
    from: 0.0
    to: 1.0
    width: root.width
    height: controlsHeight
    focusPolicy: Qt.NoFocus

    onPressedChanged:{
      appWindow.grabFocus()
      if(!pressed){
        backend.audioPlayer.seek(value)
      }
    }
    sliderBarSize: Style.primitiveControl.sliderBarSize
    backgroundColor: Style.primitiveControl.sliderBGColor
    backgroundDisabledColor: Style.primitiveControl.sliderBGDisabledColor
    backgroundActiveColor: Style.primitiveControl.sliderActivePartColor
    backgroundActiveDisabledColor: Style.primitiveControl.sliderActivePartDisabledColor
    handleColor: Style.primitiveControl.sliderHandleColor
    handleDisabledColor: Style.primitiveControl.sliderHandleDisabledColor
  }

  Item{
    id: playControlBox
    width: Style.audioControl.playControlWidth * parent.width
    anchors.top: songPositionSlider.bottom
    height: controlsHeight * Style.audioControl.playControlHeight
    anchors.topMargin: Style.audioControl.sliderButtonSpacing
                       * root.controlsHeight
    Row{
      id: playControlRow
      spacing: Style.audioControl.buttonSpacing * root.controlsHeight
      Button
      {
        id: playButton
        focusPolicy: Qt.NoFocus
        width: Style.audioControl.buttonWidth * playControlBox.width
        height: playControlBox.height
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
        width: Style.audioControl.buttonWidth * playControlBox.width
        height: playControlBox.height
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
        width: Style.audioControl.timerWidth * playControlBox.width
        height: playControlBox.height
        color: Style.audioControl.timerBGColor
        Text{
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.rightMargin: Style.audioControl.timerTextMarginRight
                               * timerDisplay.width
          text: (songPositionSlider.value / 1000).toFixed(1)
          font.pixelSize: Style.audioControl.timerFontSize
                          * timerDisplay.height
          color: Style.audioControl.timerFontColor
        }
      }

      Connections{
        target: backend.audioPlayer
        onVolumeAvailable:{
          volumeSlider.value = backend.audioPlayer.getCurrentLogVolume()
        }
      }

      ScalableSlider{
        id: volumeSlider
        from: 0.0
        to: 1.0
        value: 1.0
        height: root.controlsHeight
        width: playControlBox.width - 3 * playControlRow.spacing
               - playControlBox.width * (
                  2.0 * Style.audioControl.buttonWidth
                  + Style.audioControl.timerWidth
                 )
        anchors.verticalCenter: playControlRow.verticalCenter
        focusPolicy: Qt.NoFocus
        live: true
        onPressedChanged: appWindow.grabFocus()
        onValueChanged: backend.audioPlayer.setVolume(value)

        sliderBarSize: Style.primitiveControl.sliderBarSize
        backgroundColor: Style.primitiveControl.sliderBGColor
        backgroundDisabledColor: Style.primitiveControl.sliderBGDisabledColor
        backgroundActiveColor: Style.primitiveControl.sliderActivePartColor
        backgroundActiveDisabledColor: Style.primitiveControl.sliderActivePartDisabledColor
        handleColor: Style.primitiveControl.sliderHandleColor
        handleDisabledColor: Style.primitiveControl.sliderHandleDisabledColor

        handle: Rectangle{
          width: volumeSlider.availableHeight
          height: width
          radius: width/2
          color: enabled ? volumeSlider.handleColor
                         : volumeSlider.handleDisabledColor
          x: volumeSlider.leftPadding
             + volumeSlider.visualPosition * (volumeSlider.availableWidth
                                              - width)
          y: volumeSlider.topPadding
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
}
