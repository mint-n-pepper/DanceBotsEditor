import QtQuick 2.6
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import '../GuiStyle'

Row{
  id: root
  property real labelWidth
  property real iconWidth
  property real sliderWidth
  property real valueWidth

  property real value: numerators[frequencySlider.value]
                       / denominators[frequencySlider.value]
  property var numerators: [1, 1]
  property var denominators: [2, 1]

  onValueChanged: {
    delegate.primitive.frequency = value
  }

  Text{
    width: root.labelWidth
    font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                    * root.height
    font.capitalization: Font.AllUppercase
    text: "Frequency"
    verticalAlignment: Text.AlignVCenter
    color: Style.palette.pc_sliderText
  }

  Item{
    width: root.iconWidth
    height: root.height
    Image{
      id: lowFreq
      anchors.centerIn: parent
      source: "../icons/lowFreq.svg"
      sourceSize.width: parent.width
      antialiasing: true
      visible: false
    }

    ColorOverlay{
      anchors.fill: lowFreq
      source: lowFreq
      color: Style.palette.pc_sliderIcon
      antialiasing: true
      visible: true
    }
  }

  DiscreteSlider{
    id: frequencySlider
    height: root.height
    width: root.sliderWidth
    value: 2

    numberOfSteps: numerators.length

    Keys.onPressed: appWindow.handleKey(event)
    sliderBarSize: Style.primitiveControl.sliderBarSize
    tickMarkHeight: Style.primitiveControl.sliderTickHeight
    tickMarkWidth: Style.primitiveControl.sliderTickWidth
    backgroundColor: Style.palette.pc_sliderBar
    ticksColor: Style.palette.pc_sliderBarTicks
    handleColor: Style.palette.pc_sliderHandle
  }

  Item{
    width: root.iconWidth
    height: root.height
    Image{
      id: highFreq
      anchors.centerIn: parent
      source: "../icons/highFreq.svg"
      sourceSize.width: parent.width
      antialiasing: true
      visible: false
    }

    ColorOverlay{
      anchors.fill: highFreq
      source: highFreq
      color: Style.palette.pc_sliderIcon
      antialiasing: true
      visible: true
    }
  }

  FractionDisplay{
    anchors.verticalCenter: root.verticalCenter
    numerator: root.numerators[frequencySlider.value]
    denominator: root.denominators[frequencySlider.value]
    color: Style.palette.pc_sliderText
    fontPixelSize: Style.primitiveControl.sliderFractionTextSize
                    * root.height
  }

} // frequency row
