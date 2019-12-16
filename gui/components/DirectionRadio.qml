import QtQuick 2.6
import QtQuick.Controls 2.12
import "../GuiStyle"

RadioButton {
  id: root
  leftPadding: 0
  rightPadding: 0
  bottomPadding: 0
  topPadding: 0
  indicator: Rectangle{
    id: indicatorBg
    height: root.height
    width: height
    radius: height / 2
    anchors.verticalCenter: root.verticalCenter
    color: Style.palette.pc_directionRadioBG
    Rectangle{
      height: parent.height * Style.primitiveControl.directionRadioIndicatorSize
      width: height
      radius: height / 2
      x: (parent.height - height) / 2
      y: x
      color: Style.palette.pc_directionRadioIndicator
      visible: root.checked
    }
  }

  contentItem: Text{
    text: root.text
    font.pixelSize: root.height * Style.primitiveControl.directionRadioTextSize
    leftPadding: parent.height * (1.0 + Style.primitiveControl.directionRadioTextSpacing)
    verticalAlignment: Text.AlignVCenter
    color: Style.palette.pc_controlsFonts
  }
}
