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
    property color fc_buttonText: "#333333"
    property color fc_labelBoxBackground: "#356E41"
    property color fc_labelBoxText: "#D6D6D6"
    property color fc_textFieldAltText: "#969696"
    property color fc_textFieldText: "#D6D6D6"
    property color fc_textfieldBoxBackground: "#1A3820"
    property color fc_textfieldActiveBorder: "white"

    //* PRIMITIVE CONTROL BOXES *//
    // backgrounds
    property color pc_moveBoxBackground: "#4B4B4B" // Dark grey background
    property color pc_moveBoxColor: "#ECD600" // Mint & Pepper Yellow
    property color pc_ledBoxBackground: "#4B4B4B" // Dark grey background
    property color pc_ledBoxColor: "#FF7F33" // Mint & Pepper Orange
    property color pc_settingsBoxColor: mw_background // Settings box same as background

    // Controls Fonts
    property color pc_controlsFonts: "white"

    // type radios
    property color pc_directionRadioBG: "#151515"
    property color pc_directionRadioIndicator: pc_moveBoxColor
    property color pc_typeRadioFontActive: pc_moveBoxBackground
    property color pc_typeRadioBorder: pc_moveBoxColor

    // sliders
    property color pc_settingsBoxBackground: mw_background
    property color pc_sliderBarEnabled: "black"
    property color pc_sliderBarDisabled: "grey"
    property color pc_sliderBarActivePartEnabled: "#222222"
    property color pc_sliderBarActivePartDisabled: "#888888"
    property color pc_sliderHandleEnabled: "white"
    property color pc_sliderHandleDisabled: "grey"
    property color pc_sliderText: pc_controlsFonts
    property color pc_sliderIcon: pc_controlsFonts

    //* TIMER BARS *//
    property color tim_beatMarks: "#151515"
    property color tim_timeIndicator: "red"
    property color tim_ghostColorValid: "#8840DF40"
    property color tim_ghostColorInvalid: "#88DF4040"
    property color tim_beatNumberIndicatorBackground: "lightgrey"
    property color tim_beatNumberIndicatorFont: "black"
    property color tim_endFadeColor: "black"

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
    property color ac_buttonEnabled: fc_buttonEnabled
    property color ac_buttonDisabled: "#262626"
    property color ac_buttonPressed: fc_buttonPressed
    property color ac_buttonIconEnabled: mw_background
    property color ac_buttonIconDisabled: "black"
    // song position slider
    property color ac_songPositionSliderBarEnabled: "darkgrey"
    property color ac_songPositionSliderBarDisabled: "#262626"
    property color ac_songPositionSliderBarActivePartEnabled: "#63DD7F"
    property color ac_songPositionSliderBarActivePartDisabled: "#888888"
    property color ac_songPositionSliderHandleEnabled: "#63DD7F"
    property color ac_songPositionSliderHandleDisabled: "#262626"
    // volume slider
    property color ac_volumeSliderBarEnabled: "lightgrey"
    property color ac_volumeSliderBarDisabled: "#4B4B4B"
    property color ac_volumeSliderBarActivePartEnabled: "grey"
    property color ac_volumeSliderBarActivePartDisabled: "#888888"
    property color ac_volumeSliderHandleEnabled: "grey"
    property color ac_volumeSliderHandleDisabled: "#4B4B4B"
    property color ac_volumeSliderIconColorEnabled: "#4B4B4B"
    property color ac_volumeSliderIconColorDisabled: "#262626"

    // timer display
    property color ac_timerFontEnabled: "lightgrey"
    property color ac_timerFontDisabled: "grey"

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
    // margin used for spacing of most major gui elements,
    // such as primitive control boxes and timer bars
    property real margin: 0.01 // ratio of width
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
    // the width of the box is equal to the window width

    // buttons and text fields all have the same height
    property real itemHeight: 0.8 // ratio of box height

    // buttons
    // height is equal to height of bar minus padding
    property real buttonSpacing: 0.2 // ratio of box height
    property real buttonWidth: 1.8 // ratio of box height
    property real buttonRadius: 3 // radius of button border
    property real buttonTextHeight: 0.5 // ratio to button height
    property real buttonOpacityEnabled: 1 // opacity of enabled text
    property real buttonOpacityDisabled: 0.4 // opacity of disabled text
    property real buttonBorderWidth: 0.05 // width of button border relative to button height

    // texts
    // the available width is equal to the LED control box
    // the labels take up the remaining space after deducting
    // the spacing between the text elements
    property real textBoxWidth: 0.35 // ratio of available space
    property real textBoxSpacing: 0.02 // ratio of box height
    property real labelTextSize: 0.4 // ratio to text box height
    property real textFieldTextSize: 0.35 // ratio to text box height
    property real textBoxActiveBorderSize: 0.04 // ratio of text box height

    // the time to display a file save/load error message in the file overlay
    property int errorDisplayTimeMS: 3000 // in milli seconds
  }

  property QtObject primitiveControl: QtObject{
    // box
    property real width: 0.48 // ratio of window width
    property real heightRatio: 0.5 // ratio of box width

    // title
    property real titleFontSize: 0.63 // ratio to titleWidth
    property real titleWidth: 0.07 // ratio to box width
    property real titleLetterSpacing: 3 // letter spacing between characters

    // direction Radios
    property real directionRadioHeight: 1.0 // ratio of slider height
    property real directionRadioTextSpacing: 0.2 // radio of radio height
    property real directionRadioTextSize: 0.75 // radio of radio height
    property real directionRadioIndicatorSize: 0.8 // radio of radio height

    // type radios
    property real typeRadioHeight: 0.07 // ratio of box width
    property real typeRadioSpacing: 0.3 // ratio of radio height
    property real typeRadioRadius: 0.1 // ratio of radio height
    property real typeRadioBorderWidth: 0.05
    property real typeRadioTextPadding: 0.25 // ratio of radio height

    // primitive box
    property real primitiveBoxWidth: 0.25 // ratio of available width

    // setting box

    // sliders:
    property real sliderHeight: 0.035 // ratio of box width
    property real sliderBarSize: 0.2 // ratio of slider handle size
    property real sliderLabelWidth: 0.2 // ratio of width available for settings sliders
    property real sliderLabelTextSize: 0.8 // ratio of slider height
    property real sliderIconWidth: 0.08 // ratio of box width
    property real sliderItemHSpacing: 0.4 // ratio of sliderHeight
    property real sliderVSpacing: 0.75 // ratio of sliderHeight
    // narrower spacing between direction and velocity sliders for custom type
    property real dirToSliderSpacingCustom: 0.5 // ratio of sliderVSpacing

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

    // faders:
    property real faderWidth: 0.05 // ratio of main window width
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
    property real sliderHeight: 0.02 // ratio of window width

    // Play / Pause Buttons
    property real buttonHeight: 1.8 // ratio of sliderHeight
    property real buttonSpacing: 0.2 // ratio of sliderHeight
    property real buttonIconSize: 0.7 // ratio to buttonHeight

    // timer visuals
    property real timerFontSize: 0.8 // ratio of sliderHeight

    // Volume controls
    property real volumeSliderHeight: 0.7 // ratio of sliderHeight
    property real volmeSliderBarSize: 0.2 // ratio of slider handle size
    property real volumeSliderWidth: 0.15 // ratio of window width
    property real volumeIconScale: 0.75 // ratio of sliderHeight

  }
}
