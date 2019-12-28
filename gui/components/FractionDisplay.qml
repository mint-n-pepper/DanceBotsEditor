import QtQuick 2.0

Item{
  id: root
  width: fractionBar.width
  height: numText.implicitHeight + denText.implicitHeight + fractionBar.height
  property int numerator: 1
  property int denominator: 1
  property real barWidth: 1.1
  property real barHeight: 0.1
  property real fontPixelSize: 10
  property color color: "black"

  Rectangle{
    id: fractionBar
    height: numText.implicitHeight * barHeight
    width: numText.implicitWidth * barWidth
    anchors.centerIn: root
    color: root.color
  } // fract bar

  Text {
    id: numText
    text: numerator
    color: root.color
    font.pixelSize: root.fontPixelSize
    anchors.bottom: fractionBar.top
    anchors.horizontalCenter: root.horizontalCenter
  } // num text

  Text{
    id: denText
    text: denominator
    color: root.color
    font.pixelSize: root.fontPixelSize
    anchors.top: fractionBar.bottom
    anchors.horizontalCenter: root.horizontalCenter
  } // den text

} // root
