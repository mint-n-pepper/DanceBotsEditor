import QtQuick 2.6
import QtQuick.Controls 2.12
import "../GuiStyle"

RadioButton {
  id: root
  leftPadding: 0
  rightPadding: 0
  bottomPadding: 0
  topPadding: 0
  property color mainColor: "green"

  indicator: Rectangle{
    id: indicatorBg
    height: root.height
    width: root.width
    radius: height * Style.primitiveControl.typeRadioRadius
    anchors.verticalCenter: root.verticalCenter
    color: "transparent"
    border.color: root.mainColor
    border.width: height * Style.primitiveControl.typeRadioBorderWidth
    Rectangle{
      anchors.fill: parent
      radius: parent.radius
      color: root.mainColor
      visible: root.checked
    }
  }

  contentItem: Text{
    id: labelText
    text: root.text
    z: 1000
    padding: root.height * Style.primitiveControl.typeRadioTextPadding
    font.pixelSize: root.height - 2.0 * padding
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    color: root.checked ? Style.palette.pc_typeRadioFontActive
                        : mainColor
  }
}
