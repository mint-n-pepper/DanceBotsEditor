import QtQuick 2.6
import QtQuick.Controls 2.0

import "Components"
import "GuiStyle"

ApplicationWindow {
    id: root
    width: Style.main.width
    height: Style.main.height
    visible: true
	background: Rectangle{
		anchors.fill: parent
		color: Style.main.color
	}

	LoadProcessPopup{
		id: loadProcess
	}

	MP3FileControl{
		id: fileControl
	}

	MotorPrimitiveControl{
		id: motorPrimitiveControl
		anchors.left: fileControl.right
	}

  AudioControl{
    id: audioControl
    anchors.top: timerBarFlickable.bottom
    width: parent.width
  }

  Flickable{
    id: timerBarFlickable
    width: parent.width
    height: timerBarColumn.height
    contentWidth: timerBarColumn.width
    contentHeight: timerBarColumn.height
    anchors.top: fileControl.bottom
    anchors.left: parent.left
    anchors.topMargin: Style.timerBar.margin
    anchors.bottomMargin: Style.timerBar.margin
    boundsBehavior: Flickable.StopAtBounds

    property real sliderPosition: audioControl.sliderPosition

    onSliderPositionChanged:{
      // set time indicator position
      motorBar.timeIndicatorPosition=sliderPosition
      * backend.getAudioLengthInFrames()
      * Style.timerBar.frameToPixel;
      // get current visible pixel range:
      if(motorBar.timeIndicatorPosition < contentX
          || motorBar.timeIndicatorPosition > contentX + width){
          var proposedContentX = motorBar.timeIndicatorPosition -
            Style.timerBar.timeBarScrollOffset;
          contentX = proposedContentX < 0 ? 0 : proposedContentX;
          }
    }

    Column{
      id: timerBarColumn
      width: motorBar.width
      spacing: Style.timerBar.spacing
      TimerBar{
        id: motorBar
        color: Style.motorControl.color
        keys: ["mot"]
        model: backend.motorPrimitives
        primitiveColors: Style.motorPrimitive.colors
        primitiveTextIDs: Style.motorPrimitive.textID
      }
    }
  }
}
