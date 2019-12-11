// Style.qml
pragma Singleton
import QtQuick 2.0

QtObject {
  id:root

  // Color palette:
  property QtObject palette: QtObject{
    //* MAIN WINDOW *//
    property color mw_background: "#151515"

    //* FILE LOADING PROCESS OVERLAY *//
    property color ovr_background: "#BB444444"
    property color ovr_font: "white"

    //* TITLE BAR *//
    property color tb_background: "#262626"
    property color tb_font: "white"
    property color tb_logo: "white"

    //* FILE CONTROL BAR *//
    property color fc_background: "#63DD7F"
    property color fc_buttonEnabled: "#63DD7F"
    property color fc_buttonDisabled: "#65A273"
    property color fc_buttonPressed: "#77FF96"
    property color fc_buttonTextEnabled: "#333333"
    property color fc_buttonTextDisabled: "#333333"
    property color fc_textColor: "#333333"
    property color fc_altTextColor: "#D6D6D6"
    property color fc_labelBoxBackground: "#356E41"
    property color fc_textfieldBoxBackground: "#1A3820"


    //* PRIMITIVE CONTROL BOXES *//
    // backgrounds
    property color pc_moveBoxBackground: "#4B4B4B" // Dark grey background
    property color pc_moveBoxColor: "#ECD600" // Mint & Pepper Yellow
    property color pc_ledBoxBackground: "#4B4B4B" // Dark grey background
    property color pc_ledBoxColor: "#FF7F33" // Mint & Pepper Orange

    // type radios
    property color pc_typeRadioEnabled: "darkgrey"
    property color pc_typeRadioDisabled: "lightgrey"
    property color pc_typeRadioIndicatorEnabled: "white"
    property color pc_typeRadioIndicatorDisabled: "darkgrey"
    property color pc_typeRadioLabelEnabledFont: "white"
    property color pc_typeRadioLabelDisabledFont: pc_typeRadioIndicatorDisabled

    // sliders
    property color pc_sliderBarEnabled: "black"
    property color pc_sliderBarDisabled: pc_typeRadioDisabled
    property color pc_sliderBarActivePartEnabled: "#222222"
    property color pc_sliderBarActivePartDisabled: "#888888"
    property color pc_sliderHandleEnabled: "white"
    property color pc_sliderHandleDisabled: pc_typeRadioDisabled

    //* TIMER BARS *//
    property color tim_beatMarks: "#151515"
    property color tim_timeIndicator: "red"
    property color tim_ghostColorValid: "#8840DF40"
    property color tim_ghostColorInvalid: "#88DF4040"
    property color tim_beatNumberIndicatorBackground: "lightgrey"
    property color tim_beatNumberIndicatorFont: "black"

    //* PRIMITIVES *//
    property color prim_text: "white"
    property color prim_disabled: "#99EEEEEE"
    property color prim_border: "white"
    property color prim_highlight: "#AAFFFFFF"
    property color prim_toolTipBackground: "black"
    property color prim_toolTipFont: "lightgrey"
    property color prim_toolTipLEDon: "lime"
    property color prim_toolTipLEDoff: "lightslategrey"
    // for primitive type colors see just below

    //* AUDIO CONTROL *//
    // button
    property color ac_buttonEnabled: "lightgrey"
    property color ac_buttonDisabled: "#888888"
    property color ac_buttonPressed: "#DDDDDD"
    property color ac_buttonIconEnabled: "#333333"
    property color ac_buttonIconDisabled: "#AAAAAA"
    // song position slider
    property color ac_songPositionSliderBarEnabled: "lightgrey"
    property color ac_songPositionSliderBarDisabled: pc_typeRadioDisabled
    property color ac_songPositionSliderBarActivePartEnabled: "#222222"
    property color ac_songPositionSliderBarActivePartDisabled: "#888888"
    property color ac_songPositionSliderHandleEnabled: "white"
    property color ac_songPositionSliderHandleDisabled: pc_typeRadioDisabled
    // volume slider
    property color ac_volumeSliderBarEnabled: "lightgrey"
    property color ac_volumeSliderBarDisabled: pc_typeRadioDisabled
    property color ac_volumeSliderBarActivePartEnabled: "#222222"
    property color ac_volumeSliderBarActivePartDisabled: "#888888"
    property color ac_volumeSliderHandleEnabled: "white"
    property color ac_volumeSliderHandleDisabled: pc_typeRadioDisabled
    property color ac_volumeSliderIconColorEnabled: "black"
    property color ac_volumeSliderIconColorDisabled: "grey"

    // timer display
    property color ac_timerBackground: "white"
    property color ac_timerFont: "slategrey"

  }

  property QtObject motorPrimitive: QtObject{
    // see Primitive.h for mapping of type to color
    // Twist = 0
    // BackAndForth = 1
    // Spin = 2
    // Straight = 3
    // Custom = 4
    property var textID: ["T", "B", "S", "D", "C"]
    property var colors: ["firebrick", "darkolivegreen", "royalblue", "deepskyblue", "deeppink"]
  }

  property QtObject ledPrimitive: QtObject{
    // see Primitive.h for mapping of type to color
    // KnightRider = 0
    // Alternate = 1
    // Blink = 2
    // Constant = 3
    // Random = 4
    property var textID: ["K", "A", "B", "C", "R"]
    property var colors: ["aqua", "darkseagreen", "mediumblue", "indigo", "orange"]
  }

  // Main window
  property QtObject main: QtObject{
    property int initialWidth: 1280 // pixels
    property real heightRatio: 8.5 / 16.0 // height/width
    property int minWidth: 800 // pixels
	}

  // load/save progress overlay:
  property QtObject fileProcessOverlay: QtObject{
    property real height: 0.15 // ratio of window height
    property real fontSize: 0.2 // ratio of height
  }

  // Title bar
  property QtObject titleBar: QtObject{
    property real height: 0.04
    property real fontSize: 0.5 // relative to bar height
    property real logoSize: 0.5 // relative to bar height
    property real horizontalPadding: 0.3 // relative to bar height
  }

  // MP3 File Control Box
  property QtObject fileControl: QtObject{
    // box
    property real height: 0.045 // ratio of window width
    // the width of the box is equal to the

    // buttons
    // height is equal to height of bar minus padding
    property real buttonPadding: 0.13 // ratio of box height
    property real buttonSpacing: 0.2 // ratio of box height
    property real buttonWidth: 1.8 // ratio of box height
    property real buttonRadius: 3 // radius of button border
    property real buttonTextHeightRatio: 0.5 // ratio to button height
    property real buttonOpacityEnabled: 1 // opacity of enabled text
    property real buttonOpacityDisabled: 0.4 // opacity of disabled text
    property real buttonBorderWidth: 0.05 // width of button border relative to button height

    // texts
    // text box height is equal to box height minus padding
    property real textBoxWidth: 0.18 // ratio of window width
    property real textBoxPadding: 0.15 // ratio of box height
    property real textBoxSpacing: 0.1 // ratio of box height
    property real textSize: 0.45 // ratio to text box height

    // labels
    property real labelBoxWidth: 0.09 // ratio of window width

  }

  property QtObject primitiveControl: QtObject{
    // box
    property real width: 0.48 // ratio of window width
    property real heightRatio: 0.7 // ratio of box width
    property real margin: 0.025 // ratio to box width
    property real controlSpacing: margin // ratio of box width
    // title
    property real titleFontSize: 0.27 // ratio to titleWidth
    property real titleWidth: 0.25 // ratio to box width

    // type radios
    property real typeRadioHeight: 0.07 // ratio of box height
    property real radioIndicatorSize: 0.8 // ratio of radio height
    property real typeTextSize: 0.75 // ratio of radio height
    property real radioToTextSpacing: 0.25 // ratio of radio height

    // sliders:
    property real sliderHeight: typeRadioHeight // ratio of box height, same as radio size
    property real sliderBarSize: 0.2 // ratio of slider handle size
    property real sliderLabelTextSize: 0.58 // ratio of slider height
    property real sliderValueWidth: 0.15 // ratio of box width
    property real sliderValueLeftPadding: 0.07 // ratio of width

    // led toggles
    property real ledRadioDiameter: 0.8 // ratio of type radio diameter
    property real ledRadioSpacing: 0.35 // ratio of diameter
    property real ledTextSize: 1.0 // ratio of diameter
  }

  // Timer bar window
  property QtObject timerBar: QtObject{
    property real height: 0.06 // ratio of window width
    // margin to other GUI elements
    property real margin: 0.125 // ratio of timerBar height
    // space between timer bars
    property real spacing: 0.125 // ratio of timerBar height
    property real beatWidth: 2.0/80.0 // line width of beat indicators
    property real timeBarWidth: 3.0/80.0 // ratio of height
    property real timeBarScrollOffset: 25.0/80.0 // ratio of height

    // how many seconds of music to show in window, which
    // determines beat/samples scaling to window size
    property real secondsInWindow: 40.0

    // beat indicator
    property real beatIndicatorFontSize: 16.0 / 80.0 // ratio of timerbar height
    property real beatIndicatorPadding: 4.0 / 80.0 // ratio of timerbar height

    // hover scroll settings:
    // scroll margin is # of pixels at either end of visible timer bar
    // area that trigger a left or right scroll on hover of the primitive
    // edges
    property real scrollMargin: 0.003 // ratio of main window width
    property real scrollSpeed: 8.0 / 1000.0 // ratio of main window with
	}

  // General primitives:
  property QtObject primitives: QtObject{
    property real height: 0.9 // ratio of timerbar height
    property real radius: 3.0/72.0 // ratio of height
    property real textPosX: 3.0/72.0
    property real textPosY: 3.0/72.0
    property real textSize: 0.2 // ratio of height
    property bool textBold: true
    property real borderWidth: 1.0 / 72.0 // ratio of height
    // margin of primitive at which a drag causes a size change
    // is capped at half primtive width
    property real resizeMarginRight: 0.14 // ratio of height

    // TOOLTIP STYLE
    property real toolTipFontSize: 16.0 / 72.0 // ratio of height
    property real toolTipPadding: 4.0 / 72.0 // ratio of height
    property real ledToolTipLEDSize: 10.0 / 72.0 // ratio of height
	}

  property QtObject audioControl: QtObject{
    // width of time slider is same as window size
    // controls height set so that slider knob has same size as
    // primitive box sliders
    property real controlsHeight: primitiveControl.heightRatio
                                  * primitiveControl.width
                                  * primitiveControl.typeRadioHeight

    // total width of buttons and volume slider
    property real playControlWidth: 0.25 // ratio of window size
    property real playControlHeight: 1.2 // ratio of controlsHeight
    property real buttonWidth: 0.15 // ratio of playControlWidth
    property real timerWidth: 0.18 // ratio of playControlWidth
    // volume slider takes remaining space to fill playControlWidth

    // timer visuals
    property real timerFontSize: 0.45 // ratio of playControlHeight
    property real timerTextMarginRight: 0.1 // ratio of timer width

    // spacing between slider and buttons
    property real sliderButtonSpacing: 0.3 // ratio of controlsHeight
    // horizontal spacing between buttons
    property real buttonSpacing: 0.2 // ratio of controlsHeight

    // scale of speaker icon relative to slider size
    property real volumeSliderIconScale: 0.75
  }
}
