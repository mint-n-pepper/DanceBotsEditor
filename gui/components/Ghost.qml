import QtQuick 2.6
import "../GuiStyle"

Rectangle{
  id: ghost
  width:40
  visible: false
  property bool isValid: false
  color: isValid ? Style.palette.tim_ghostColorValid
                 : Style.palette.tim_ghostColorInvalid
  height: parent.height
  radius: Style.primitives.radius
}
