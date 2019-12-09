import QtQuick 2.13
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  property bool isMotor: false
  anchors.top: isMotor ? undefined : parent.bottom
  anchors.bottom: isMotor ? parent.top : undefined
  visible: parent.showData && !parent.dragActive
  color: Style.primitives.toolTipBgColor
  width: isMotor ? motorColumn.width : ledColumn.width
  height: isMotor ? motorColumn.height : ledColumn.height
  radius: Style.primitives.radius

  property real padding: parent.height * Style.primitives.toolTipPadding
  property real fontSize: parent.height * Style.primitives.toolTipFontSize

  Column{
    id:motorColumn
    visible: root.visible && isMotor
    spacing: root.padding
    padding: root.padding
    Text{
      visible: motorColumn.visible
        && primitive.type !== MotorPrimitive.Type.Spin
        && primitive.type !== MotorPrimitive.Type.Straight
        && primitive.type !== MotorPrimitive.Type.Custom
      text: "Freq: 1.00"
      font.pixelSize: root.fontSize
      color: Style.primitives.toolTipFontColor
      onVisibleChanged: {
        if(visible){
          text="Freq: " + primitive.frequency.toFixed(2)
        }
      }
    }
    Text{
      visible: root.visible && primitive.velocity !== undefined
      text: "Vel: 40"
      font.pixelSize: root.fontSize
      color: Style.primitives.toolTipFontColor
      onVisibleChanged: {
        if(visible){
          if(primitive.type === MotorPrimitive.Type.Custom){
            text="Vel L: " + primitive.velocity
          }else{
            text="Vel: " + primitive.velocity
          }
        }
      }
    }
    Text{
      visible: {root.visible
               && primitive.type === MotorPrimitive.Type.Custom
               && primitive.velocityRight !== undefined}
      text: "Vel R: 40"
      font.pixelSize: root.fontSize
      color: Style.primitives.toolTipFontColor
      onVisibleChanged: {
        if(visible){text="Vel R: " + primitive.velocityRight}
      }
    }
  }

  Column{
    id:ledColumn
    visible: root.visible && !isMotor
    spacing: root.padding
    padding: root.padding
    Text{
      visible: ledColumn.visible
        && primitive.type !== LEDPrimitive.Type.Constant
      text: "Freq: 1.00"
      font.pixelSize: root.fontSize
      color: Style.primitives.toolTipFontColor
      onVisibleChanged: {
        if(visible){
          text="Freq: " + primitive.frequency.toFixed(2)
        }
      }
    }

    Row{
      visible: { ledColumn.visible
        && primitive.type !== LEDPrimitive.Type.KnightRider
        && primitive.type !== LEDPrimitive.Type.Random
      }
      onVisibleChanged: {
        if(visible){
          for(var i = 0; i < primitive.leds.length; i++){
            if(primitive.leds[i]){
              ledRepeater.itemAt(i).color =  Style.primitives.ledToolTipOnColor
            }else{
              ledRepeater.itemAt(i).color =  Style.primitives.ledToolTipOffColor
            }
          }
        }
      }
      Repeater{
        id: ledRepeater
        model: 8
        delegate: Rectangle{
          width: Style.primitives.ledToolTipLEDSize * root.parent.height
          height: width
          radius: width / 2
          color: Style.primitives.ledToolTipOffColor
        }
      }
    }
  }
}
