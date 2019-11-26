import QtQuick 2.0
import "../GuiStyle"

Rectangle{
  id: ghost
  width:40
  visible: false
  property bool isValid: false
  color: isValid ? Style.timerBar.ghostColorValid : Style.timerBar.ghostColorInvalid
  height: Style.timerBar.height
  radius: Style.primitives.radius
}
