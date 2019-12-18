import QtQuick 2.6
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.13
import dancebots.backend 1.0
import "../GuiStyle"

Rectangle{
  id: root
  color: Style.palette.pc_ledBoxBackground
  property var keys: ['led']
  property var beats: []
  property var primitiveColors: Style.ledPrimitive.colors
  property var primitiveTextIDs: Style.ledPrimitive.textID
  property var delegate: null
  property var averageBeatFrames: 60 * 441 // 100 bpm @ 44.1kHz
  enabled: false
  property var margin: width * Style.primitiveControl.margin
  property int type

  // frequencies that can be set with slider
  property var frequencies: [0.25, 0.33, 0.5, 0.66, 1.0, 1.5, 2.0, 3.0, 4.0]

  onTypeChanged: {
    delegate.primitive.type = type
    delegate.updatePrimitive()
  }
  property var leds: [true, true, true, true, true, true, true, true]

  Connections{
	  target: backend
	  onDoneLoading:{
      if(result){
        // calculate average beat distance:
        averageBeatFrames = backend.getAverageBeatFrames();
        delegate.updatePrimitive();
        enabled = true;
      }
    }
  }

  Rectangle{
    id: titleBar
    height: root.height
    width: Style.primitiveControl.titleWidth * root.width
    color: Style.palette.pc_ledBoxColor
    Text{
      anchors.centerIn: parent
      text: qsTr("Lights")
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      font.pixelSize: Style.primitiveControl.titleFontSize * titleBar.width
      font.letterSpacing: Style.primitiveControl.titleLetterSpacing
      font.capitalization: Font.AllUppercase
      font.bold: true;
      rotation : 270
    }
  }

  Row{
    id: radios
    anchors.left: titleBar.right
    padding: appWindow.guiMargin
    anchors.top: titleBar.top
    width: root.width - titleBar.width
    property var radioHeight: root.width
                              * Style.primitiveControl.typeRadioHeight
    spacing: (width - 2 * padding
              - knightRiderRadio.width
              - alternateRadio.width
              - blinkRadio.width
              - constantRadio.width
              - randomRadio.width) / 4
    TypeRadio {
      id: knightRiderRadio
      checked: true
      text: qsTr("KnightRider")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.KnightRider
      mainColor: Style.palette.pc_ledBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: alternateRadio
      text: qsTr("Alternate")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Alternate
      mainColor: Style.palette.pc_ledBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: blinkRadio
      text: qsTr("Blink")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Blink
      mainColor: Style.palette.pc_ledBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: constantRadio
      text: qsTr("Constant")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Constant
      mainColor: Style.palette.pc_ledBoxColor
      height: radios.radioHeight
    }
    TypeRadio {
      id: randomRadio
      text: qsTr("Random")
      onPressed: appWindow.grabFocus()
      onToggled: type=LEDPrimitive.Type.Random
      mainColor: Style.palette.pc_ledBoxColor
      height: radios.radioHeight
    }
  } // radios column

  Rectangle {
    id: settingsRectangle
    anchors.leftMargin: appWindow.guiMargin
    anchors.rightMargin: appWindow.guiMargin
    anchors.bottomMargin: appWindow.guiMargin
    property var minHeight: dummyTimerBar.height + 2 * appWindow.guiMargin
    height: settingsColumn.height + 2 * appWindow.guiMargin < minHeight ?
     minHeight : settingsColumn.height + 2 * appWindow.guiMargin
    anchors.left: titleBar.right
    anchors.right: root.right
    anchors.bottom: root.bottom

    color: Style.palette.pc_settingsBoxBackground

    Column{
      id: settingsColumn
      width: radios.width * (1.0 - Style.primitiveControl.primitiveBoxWidth)
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.bottomMargin: appWindow.guiMargin
      anchors.leftMargin: appWindow.guiMargin
      padding: appWindow.guiMargin
      spacing: sliderHeight * Style.primitiveControl.sliderVSpacing
      property real sliderHeight: root.width * Style.primitiveControl.sliderHeight
      property real labelWidth: width * Style.primitiveControl.sliderLabelWidth
      property real iconWidth: width * Style.primitiveControl.sliderIconWidth
      property real sliderItemSpacing: sliderHeight
                                      * Style.primitiveControl.sliderItemHSpacing
      property real sliderWidth: width
                                - labelWidth
                                - 2 * iconWidth
                                - 3 * sliderItemSpacing
                                - 2 * appWindow.guiMargin
      property real dirRadioSize: radios.radioHeight
                                  * Style.primitiveControl.directionRadioSize

      Row{
        id: frequencySliderRow
        spacing: settingsColumn.sliderItemSpacing
        visible: !constantRadio.checked
        Item{
          height: settingsColumn.sliderHeight
          width: settingsColumn.labelWidth
          Text{
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * parent.height
            font.capitalization: Font.AllUppercase
            text: "Frequency"
            verticalAlignment: Text.AlignVCenter
            color: Style.palette.pc_sliderText
          }
        }

        Item{
          width: settingsColumn.iconWidth
          height: settingsColumn.sliderHeight
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

        ScalableSlider{
          id: frequencySlider
          height: settingsColumn.sliderHeight
          width: settingsColumn.sliderWidth
          from: 0.0
          value: 2.0
          to: frequencies.length - 1.0
          stepSize: 1.0
          live: true
          snapMode: Slider.SnapAlways
          onValueChanged: {
            delegate.primitive.frequency = frequencies[value]
            delegate.updateToolTip()
          }
          Keys.onPressed: appWindow.handleKey(event)
          sliderBarSize: Style.primitiveControl.sliderBarSize
          backgroundColor: Style.palette.pc_sliderBar
          backgroundActiveColor: Style.palette.pc_sliderBarActivePart
          handleColor: Style.palette.pc_sliderHandle
        }

        Item{
          width: settingsColumn.iconWidth
          height: settingsColumn.sliderHeight
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
      } // frequency row

      Row{
        id: ledSet
        visible: !knightRiderRadio.checked && !randomRadio.checked
        Item{
          id: ledlabel
          height: settingsColumn.sliderHeight
          width: settingsColumn.labelWidth
          Text{
            font.pixelSize: Style.primitiveControl.sliderLabelTextSize
                            * parent.height
            text: "LEDs"
            verticalAlignment: Text.AlignVCenter
            color: Style.palette.pc_sliderText
          }
        }

        Row{
          id: ledCheckboxes
          property var ledDiameter: Style.primitiveControl.ledRadioDiameter
                                    * settingsColumn.sliderHeight
          spacing: Style.primitiveControl.ledRadioSpacing * ledDiameter
          anchors.verticalCenter: ledlabel.verticalCenter
          Repeater{
            model: leds.length
            delegate: CheckBox{
              id: control
              checked: leds[index]
              focusPolicy: Qt.NoFocus
              width: ledCheckboxes.ledDiameter
              onPressed: appWindow.grabFocus()
              onCheckedChanged: {
                leds[index] = checked
                if(delegate){
                  delegate.primitive.leds[index] = checked;
                  delegate.updateToolTip()
                }
              }
              contentItem: Text{
                width: background.width
                anchors.top: background.bottom
                anchors.verticalCenter: parent.verticalCenter
                text: index
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: background.width
                                * Style.primitiveControl.ledTextSize
                color: Style.palette.pc_controlsFonts
              }

              indicator: Rectangle{
                id: ledIndicator
                width: ledCheckboxes.ledDiameter
                height: ledCheckboxes.ledDiameter
                radius: height/2
                anchors.verticalCenter: background.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: control.checked ?
                         Style.palette.prim_toolTipLEDon : background.color
              }

              background: Rectangle{
                width: ledCheckboxes.ledDiameter
                height: ledCheckboxes.ledDiameter
                anchors.verticalCenter: parent.verticalCenter
                radius: height/2
                color: Style.palette.prim_toolTipLEDoff
              }
            }
          } // led repeater
        } // led checkboxes
      } // led set row
    } // settings column


    Rectangle{
      id: dummyTimerBar
      height: appWindow.width * Style.primitives.height * Style.timerBar.height
      anchors.bottom: parent.bottom
      anchors.left: settingsColumn.right
      anchors.leftMargin: appWindow.guiMargin
      anchors.bottomMargin: appWindow.guiMargin
    }
  }

  function createDelegate(){
    delegate = delegateFactory.createObject(dummyTimerBar)
    delegate.dragTarget = ledBar.dragTarget
    delegate.idleParent = root
    delegate.primitive = primitiveFactory.createObject(delegate.id)
    delegate.primitive.positionBeat= 0;
    delegate.primitive.lengthBeat= 4;
    delegate.primitive.type = type
    delegate.primitive.frequency = frequencies[frequencySlider.value]
    delegate.primitive.leds = leds

    delegate.anchors.verticalCenter = dummyTimerBar.verticalCenter
    delegate.updatePrimitive()
  }

  Component.onCompleted:{
    // set the first beat at a fixed pixel distance from the left border of the
    // control box:
    setDummyBeats();
    createDelegate();
  }

  onDelegateChanged:{
    if(delegate === null){
      createDelegate()
    }
  }

  function setDummyBeats(){
    for(var i = 0; i < 5; ++i){
      // add beats at 100 bpm
      beats[i] = (i * averageBeatFrames)
    }
  }

  onAverageBeatFramesChanged:{
    setDummyBeats();
  }

  Component{
    id: delegateFactory
    PrimitiveDelegate{}
  }

  Component{
    id: primitiveFactory
    LEDPrimitive{}
  }

  function duplicatePrimitive(primOrig){
    var prim = primitiveFactory.createObject(root)
    prim.type = primOrig.type
    prim.positionBeat = primOrig.positionBeat
    prim.lengthBeat = primOrig.lengthBeat
    prim.frequency = primOrig.frequency
    prim.leds = primOrig.leds
    return prim
  }
}
