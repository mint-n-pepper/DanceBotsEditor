import QtQuick 2.12
import QtQuick.Controls 2.0
import "../GuiStyle"

Slider {
  id: root
  leftPadding: 0
  rightPadding: 0
  topPadding: 0
  bottomPadding: 0

  // size of slider bar relative to available height
  property real sliderBarSize: 0.2
  
  // color definitions
  property color backgroundColor: "white"
  property color backgroundDisabledColor: "lightgrey"
  property color backgroundActiveColor: "#444444"
  property color backgroundActiveDisabledColor: "#888888"
  property color handleColor: "white"
  property color handleDisabledColor: "lightgrey"

  background:Rectangle{
    id: bgRect
    width: root.availableWidth
    height: root.availableHeight * sliderBarSize
    x: root.leftPadding
    y: root.topPadding + (root.availableHeight - height) / 2
    color: root.enabled ? backgroundColor
                        : backgroundDisabledColor
    radius: height/2
    Rectangle{
      width: root.visualPosition * bgRect.width
      height: bgRect.height
      radius: bgRect.radius
      color: root.enabled ? backgroundActiveColor
                          : backgroundActiveDisabledColor
    }
  }

  handle: Rectangle{
    x: root.leftPadding
       + root.visualPosition * (root.availableWidth
                                - height)
    y: root.topPadding
    height: root.availableHeight
    width: root.availableHeight
    radius: width/2
    color: root.enabled ? handleColor
                        : handleDisabledColor
  }
}
