import QtQuick 2.6
import "../GuiStyle"

// fade rectangles:
Item{
  id: root
  property var contentPosition: 0
  property var contentWidth: 0
  property var distanceFromRight: contentWidth
                                  - contentPosition
                                  - width
  Item{
    id: fadeLeft
    height: parent.height
    width: parent.width * Style.timerBar.faderWidth;
    anchors.left: parent.left
    Rectangle{
      height: parent.width
      width: parent.height
      y: parent.height
      opacity: root.contentPosition / parent.width
      transform: Rotation { origin.x: 0; origin.y: 0; angle: -90}
      gradient: Gradient {
          GradientStop { position: 1.0; color: "transparent" }
          GradientStop { position: 0.0; color: Style.palette.tim_endFadeColor }
      }
    }
  }
  Item{
    id: fadeRight
    height: parent.height
    width: parent.width * Style.timerBar.faderWidth;
    anchors.right: parent.right
    Rectangle{
      height: parent.width
      width: parent.height
      y: parent.height
      opacity: root.distanceFromRight / parent.width
      transform: Rotation { origin.x: 0; origin.y: 0; angle: -90}
      gradient: Gradient {
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: Style.palette.tim_endFadeColor }
      }
    }
  }
}
