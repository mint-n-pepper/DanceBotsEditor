import QtQuick 2.12
import '../GuiStyle'

MouseArea {
  id: root
  width: parent.width
  height: parent.height
  hoverEnabled: true

  property var toolTipText: "Hello there, I am a tooltip for ya."
  property int delayMS: Style.toolTips.showDelayMS
  property bool showTop: true // set to false to show below item
  // the size properties below are all relative to parent item height
  property real toolTipTextSize: Style.toolTips.textSize
  // padding of text inside BG box
  property real textPadding: Style.toolTips.textPadding
  property real offsetX: Style.toolTips.offsetX // offset in x
  property real offsetY: Style.toolTips.offsetY // offset in y

  // max width of tooltip before wrapping text and extending up/down
  property real maxWidth: Style.toolTips.maxWidth // relative to parent width

  Text{
    x: offsetX * root.height
    y: showTop ? -offsetY * root.height : offsetY * root.height
    text: toolTipText
    width: maxWidth * root.width
    font.pixelSize: root.height * toolTipTextSize
    color: Style.palette.gtt_text
    visible: showTimer.showData
    wrapMode: Text.WordWrap
    padding: textPadding * root.height
    anchors.bottom: showTop ? parent.top : undefined
    anchors.top: showTop ? undefined : parent.bottom

    Rectangle{
      color: Style.palette.gtt_background
      height: parent.height
      width: parent.contentWidth + 2.0 * parent.padding
      z: -1
    }
  }

  onPositionChanged:{
    showTimer.restart()
    showTimer.showData = false
  }
  onEntered: {
    showTimer.start()
  }
  
  onExited: {
    showTimer.stop();
    showTimer.showData=false
  }

  Timer {
    id: showTimer
    interval: delayMS
    onTriggered: showData = true
    property bool showData: false

  }
}  // root Mousearea
