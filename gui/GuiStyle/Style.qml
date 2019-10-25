// Style.qml
pragma Singleton
import QtQuick 2.0
QtObject {
  id:root
  // Main window
  property QtObject main: QtObject{
		property int width: 1280
		property int height: 800
		property color color: "#ffe0e0"
	}
  
  // MP3 File Control Box
  property QtObject fileControl: QtObject{
    // box
    property color color: "#5D7CE7"
    property int width: 320
    property int height: 400
    // buttons
    property int buttonPadding: 5
    property int buttonSpacing: 5
    property int buttonWidth: 100
    property int buttonHeight: 50
    // texts
    property int textLabelMargin: 5
    property int textLabelSpacing: 5
    property int textLabelPixelSize: 15
  }

  // Motor Primitive Control Box
  property QtObject motorControl: QtObject{
    // box
    property color color: "#c8a2c8" // lilac
    property int width: 320
    property int height: 400
  }

  // LED Primitive Control Box
  property QtObject ledControl: QtObject{
    // box
    property color color: "#00A693"
    property int width: motorControl.width
    property int height: motorControl.height
  }

  // Timer bar window
  property QtObject timerBar: QtObject{
		property int height: 80
    property int margin: 10 // margin to other GUI elements
    property int spacing: 10 // space between timer bars
    property color beatColor: "lightgray"
    property color timeBarColor: "red"

    property real frameToPixel:  0.00072562358276643991
	}

  property QtObject motorPrimitive: QtObject{
    property int height: timerBar.height - 10
    property int radius: 3
    property color color: "red"
	}
}
