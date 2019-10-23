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
    property color color: "#F5E850"
    property int width: 320
    property int height: 400
  }

}