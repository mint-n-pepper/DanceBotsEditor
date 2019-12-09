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
    color: root.enabled ? Style.primitiveControl.typeRadioBGColor
                        : Style.primitiveControl.typeRadioDisabledColor
    Rectangle{
      height: parent.height * Style.primitiveControl.radioIndicatorSize
      width: height
      radius: height / 2
      x: (parent.height - height) / 2
      y: x
      color: root.enabled ? Style.primitiveControl.typeRadioIndicatorColor
                          : Style.primitiveControl.typeRadioIndicatorDisabledColor
      visible: root.checked
    }
  }

  contentItem: Text{
    text: root.text
    font.pixelSize: root.height * Style.primitiveControl.typeTextSize
    leftPadding: parent.height * (1.0 + Style.primitiveControl.radioToTextSpacing)
    verticalAlignment: Text.AlignVCenter
    color: root.enabled ? Style.primitiveControl.typeRadioFontColor
                              : Style.primitiveControl.typeRadioDisabledColor
  }
}
