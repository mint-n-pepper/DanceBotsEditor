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
    property int height: 420
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

  property QtObject primitiveControl: QtObject{
    // box
    property color moveColor: "#c8a2c8" // lilac
    property color ledColor: "#00A693"
    property int width: 380
    property int height: fileControl.height
    // left and bottom spacing of primitive shape
    property real margin: 10.0
    property real controlsSpacing: 10
    property int textPixelSize: 15
    property int titlePixelSize: 22
    property int labelsWidth: 100
    property int ledRadioDiameter: 20
    property int ledRadioSpacing: 5
  }

  // Timer bar window
  property QtObject timerBar: QtObject{
		property int height: 80
    property int margin: 10 // margin to other GUI elements
    property int spacing: 10 // space between timer bars
    property color beatColor: "lightgray"
    property int beatWidth: 2 // line width of beat indicators
    property color timeBarColor: "red"
    property int timeBarWidth: 3
    property int timeBarScrollOffset: 25
    property color ghostColorValid: "#8840DF40"
    property color ghostColorInvalid: "#88DF4040"
    property real frameToPixel:  0.00072562358276643991
	}

  // General primitives:
  property QtObject primitives: QtObject{
    property int height: timerBar.height - 10
    property int radius: 3
    property color textColor: "white"
    property int textPosX: 3
    property int textPosY: 3
    property int textSize: height/5
    property bool textBold: true
    property color disabledColor: "#99EEEEEE"
    property color borderColor: "white"
    property int borderWidth: 1
    property color highlightOverlayColor: "#AAFFFFFF"
    // margin of primitive at which a drag causes a size change
    // is capped at half primtive width
    property int sizePixelMarginRight: 10

    // TOOLTIP STYLE
    property color toolTipBgColor: "#000000"
    property color toolTipFontColor: "lightgrey"
    property int toolTipFontPixelSize: 16
    property real toolTipPadding: 4.0
    property var ledToolTipLEDSize: 10
    property var ledToolTipOnColor: "lime"
    property var ledToolTipOffColor: "lightslategrey"

	}

  property QtObject motorPrimitive: QtObject{
    // see Primitive.h for mapping of type to color
    // Twist = 0
    // BackAndForth = 1
    // Spin = 2
    // Straight = 3
    // Custom = 4
    property var textID: ["T", "B", "S", "D", "C"]
    property var colors: ["firebrick", "darkolivegreen", "royalblue", "deepskyblue", "deeppink"]
	}

  property QtObject ledPrimitive: QtObject{
    // see Primitive.h for mapping of type to color
    // KnightRider = 0
    // Alternate = 1
    // Blink = 2
    // Constant = 3
    // Random = 4
    property var textID: ["K", "A", "B", "C", "R"]
    property var colors: ["aqua", "darkseagreen", "mediumblue", "indigo", "orange"]
  }

  property QtObject audioControl: QtObject{
    property int buttonWidth: 50
    property int buttonHeight: 20
  }

}
