import QtQuick 2.6
import QtQuick.Controls 2.0
import dancebots.backend 1.0
import QtGraphicalEffects 1.13
import "../GuiStyle"

Item {
  id: root
  property alias sliderPosition: songPositionSlider.visualPosition

  height: songPositionSlider.height + playControlBox.height
          + controlsHeight * Style.audioControl.sliderButtonSpacing

  property int controlsHeight: width * Style.audioControl.controlsHeight

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
    backgroundColor: Style.palette.ac_songPositionSliderBarEnabled
    backgroundDisabledColor: Style.palette.ac_songPositionSliderBarDisabled
    backgroundActiveColor: Style.palette.ac_songPositionSliderBarActivePartEnabled
    backgroundActiveDisabledColor: Style.palette.ac_songPositionSliderBarActivePartDisabled
    handleColor: Style.palette.ac_songPositionSliderHandleEnabled
    handleDisabledColor: Style.palette.ac_songPositionSliderHandleDisabled
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
        property color buttonColor: enabled ? Style.palette.ac_buttonEnabled
                                            : Style.palette.ac_buttonDisabled

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: playImage
            anchors.centerIn: parent
            source: "../icons/playPause.svg"
            sourceSize.height: parent.height
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: playImage
            source: playImage
            color: parent.enabled ? Style.palette.ac_buttonIconEnabled
                                  : Style.palette.ac_buttonIconDisabled
            antialiasing: true
          }
        }

        background: Rectangle{
          anchors.fill: parent
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

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
        property color buttonColor: enabled ? Style.palette.ac_buttonEnabled
                                            : Style.palette.ac_buttonDisabled

        contentItem: Item{
          height: parent.height
          width: parent.width
          Image{
            id: stopImage
            anchors.centerIn: parent
            source: "../icons/stop.svg"
            sourceSize.height: parent.height
            antialiasing: true
            visible: false
          }

          ColorOverlay{
            anchors.fill: stopImage
            source: stopImage
            color: parent.enabled ? Style.palette.ac_buttonIconEnabled
                                  : Style.palette.ac_buttonIconDisabled
            antialiasing: true
          }
        }

        background: Rectangle{
          anchors.fill: parent
          color: parent.pressed ? Style.palette.ac_buttonPressed
                 : parent.buttonColor
        }

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
        color: Style.palette.ac_timerBackground
        Text{
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          anchors.rightMargin: Style.audioControl.timerTextMarginRight
                               * timerDisplay.width
          text: (songPositionSlider.value / 1000).toFixed(1)
          font.pixelSize: Style.audioControl.timerFontSize
                          * timerDisplay.height
          color: Style.palette.ac_timerFont
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
        backgroundColor: Style.palette.ac_volumeSliderBarEnabled
        backgroundDisabledColor: Style.palette.ac_volumeSliderBarDisabled
        backgroundActiveColor: Style.palette.ac_volumeSliderBarActivePartEnabled
        backgroundActiveDisabledColor: Style.palette.ac_volumeSliderBarActivePartDisabled
        handleColor: Style.palette.ac_volumeSliderHandleEnabled
        handleDisabledColor: Style.palette.ac_volumeSliderHandleDisabled

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
            id: speakerImage
            source: "../icons/volume.svg"
            anchors.centerIn: parent
            width: Style.audioControl.volumeSliderIconScale * parent.width
            height: width
            visible: false
          }
          ColorOverlay{
            anchors.fill: speakerImage
            source: speakerImage
            color: parent.enabled ? Style.palette.ac_volumeSliderIconColorEnabled
                                  : Style.palette.ac_volumeSliderIconColorDisabled
            antialiasing: true
          }
        }
      }
    }
  }
}
