import QtQuick 2.6
import QtGraphicalEffects 1.13
import "../GuiStyle"

Rectangle{
  id: root
  height: width * Style.titleBar.height
  color: Style.palette.tb_background
  Text{
    anchors.verticalCenter: titleBar.verticalCenter
    color: Style.palette.tb_font
    text: "Dancebots GUI"
    font.pixelSize: titleBar.height * Style.titleBar.fontSize
    leftPadding: titleBar.height * Style.titleBar.horizontalPadding
  }

  Image {
    id: mintPepperLogo
    anchors.verticalCenter: titleBar.verticalCenter
    source: "../icons/mp_logo.svg"
    sourceSize.height: titleBar.height * Style.titleBar.logoSize
    anchors.right: titleBar.right
    anchors.rightMargin: titleBar.height * Style.titleBar.horizontalPadding
    antialiasing: true
    visible: false
  }
  ColorOverlay{
    anchors.fill: mintPepperLogo
    source: mintPepperLogo
    color: Style.palette.tb_logo
    antialiasing: true
  }
}
