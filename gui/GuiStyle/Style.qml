// Style.qml
/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2019-2021 - mint & pepper
*
*  This program is free software : you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*
*  See the GNU General Public License for more details, available in the
*  LICENSE file included in the repository.
*/

pragma Singleton
import QtQuick 2.6

QtObject {
  id:root

  // Color palette:
  property QtObject palette: QtObject{
    //* GLOBAL COLORS *//
    property color mp_yellow: "#ECD600" // Mint & Pepper Yellow
    property color mp_yellow_fade: "#E0C639" // Mint & Pepper Yellow faded
    property color mp_orange: "#BF4812" // Mint & Pepper Orange
    property color mp_orange_fade: "#A54920" // Mint & Pepper Orange faded
    property color mp_blue: "#0884AA" // Mint & Pepper Blue
    property color mp_blue_fade: "#117492" // Mint & Pepper Blue faded
    property color mp_green: "#63DD7F" // Mint & Pepper Green
    property color mp_white: "#F5F5F5" // Almost white
    property color mp_lightgrey: "#262626" // Light grey
    property color mp_mediumgrey: "#4B4B4B" // Light grey
    property color mp_darkgrey: "#262626" // Dark grey
    property color mp_black: "#151515" // Almost black

    //* MAIN WINDOW *//
    property color mw_background: mp_black
    property color mw_disableOverlay: "#88444444"

    //* FILE LOADING PROCESS OVERLAY *//
    property color ovr_background: mp_black
    property color ovr_font: "white"

    //* CONFIRMATION DIALOG *//
    property color cd_windowOverlay: "#99262626"
    property color cd_background: mp_white
    property color cd_textAndButtons: mp_darkgrey
    property color cd_buttonPressedText: mp_white
    property color cd_buttonPressedBG: mp_darkgrey

    //* ABOUT POPUP *//
    property color ap_windowOverlay: "#99262626"
    property color ap_background: mp_white
    property color ap_text: mp_darkgrey

    //* TITLE BAR *//
    property color tb_background: mp_darkgrey
    property color tb_font: mp_white
    property color tb_logo: mp_white

    //* GUI TOOLTIPS *//
    property color gtt_background: mw_background
    property color gtt_text: mp_white

    //* FILE CONTROL BAR *//
    property color fc_background: mp_green
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
    property color pc_titlebar_background: mp_darkgrey // Title bar background
    property color pc_moveBoxBackground: mp_mediumgrey // Moves box background
    property color pc_moveBoxColor: mp_orange // Moves box color
    property color pc_ledBoxBackground: mp_mediumgrey // Dark grey background
    property color pc_ledBoxColor: mp_blue // Lights Box color
    property color pc_settingsBoxBackground: "#393939"

    // Controls Fonts
    property color pc_controlsFonts: "white"

    // type radios
    property color pc_directionRadioBG: mp_black
    property color pc_directionRadioIndicator: "white"
    property color pc_typeRadioFontActive: mp_mediumgrey
    property color pc_typeRadioBorder: mp_blue

    // sliders
    property color pc_sliderBar: mp_black
    property color pc_sliderBarActivePart: mp_mediumgrey
    property color pc_sliderBarTicks: mp_black
    property color pc_sliderHandle: "white"
    property color pc_sliderText: pc_controlsFonts
    property color pc_sliderIcon: pc_controlsFonts

    //* TIMER BARS *//
    property color tim_moveBoxColor: mp_orange_fade
    property color tim_ledBoxColor: mp_blue_fade
    property color tim_beatMarks: mp_black
    property color tim_timeIndicator: "red"
    property color tim_ghostColorValid: "#8840DF40"
    property color tim_ghostColorInvalid: "#88DF4040"
    property color tim_beatNumberIndicatorBackground: "lightgrey"
    property color tim_beatNumberIndicatorFont: "black"
    property color tim_endFadeColor: "black"

    //* PRIMITIVES *//
    property color prim_text: mp_black
    property color prim_border: mp_darkgrey
    property color prim_highlight: "#AAFFFFFF"
    property color prim_toolTipBackground: mp_black
    property color prim_toolTipFont: mp_white
    property color prim_toolTipLEDon: "lime"
    property color prim_toolTipLEDoff: "lightslategrey"
    property color prim_resizeHandleOverlay: mp_lightgrey
    property color prim_resizeHandleSmallMark: mp_black
    // for primitive type colors see just below

    //* AUDIO CONTROL *//
    // button
    property color ac_button: fc_buttonEnabled
    property color ac_buttonPressed: fc_buttonPressed
    property color ac_buttonIcon: mw_background

    // song position slider
    property color ac_songPositionSliderBar: mp_lightgrey
    property color ac_songPositionSliderBarActivePart: mp_green
    property color ac_songPositionSliderHandle: mp_green
    property color ac_songPositionSliderHandleBorder: mp_black

    // timer display
    property color ac_timerFont: "lightgrey"

    // instaplay buttons
    property color ac_instaPlayRobot: "orange"
    property color ac_instaPlayHuman: mp_green
  }

  property QtObject motorPrimitive: QtObject{
    // see primitive.h for mapping of type to color
    // Twist = 0
    // BackAndForth = 1
    // Spin = 2
    // Straight = 3
    // Custom = 4
    property var textID: ["Twist",
                          "Back and Forth",
                          "Spin",
                          "Drive Straight",
                          "Custom"]
    property var colors: ["#FAFA5F", "#FFE627", "#FFA310", "#FD642C", "#FF4040"]
  }

  property QtObject ledPrimitive: QtObject{
    // see primitive.h for mapping of type to color
    // KnightRider = 0
    // Alternate = 1
    // Blink = 2
    // Constant = 3
    // Random = 4
    property var textID: ["Knight Rider",
                          "Alternate",
                          "Blink",
                          "Constant",
                          "Random"]
    property var colors: ["#1DD2FF", "#0AAAFF", "#9188FF", "#BD71FF", "#FF52C8"]
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
    property real opacity: 0.85 // opacity of overlay

  }

  // confirmation dialog
  property QtObject confirmationDialog: QtObject{
    property real width: 0.3 // ratio of window width
    property real heightRatio: 0.5 // ratio of width
    property real textFontSize: 0.15 // ratio of height
    property real detailTextFontSize: 0.08 // ratio of height
    property real buttonHeight: 0.2 // ratio of height
    property real buttonFontSize: 0.4 // ratio of height
    property real buttonRadius: fileControl.buttonRadius
    property real buttonBorderWidth: fileControl.buttonBorderWidth
  }

  // about popup
  property QtObject aboutPopup: QtObject{
    property real textFontSize: 0.013 // ratio of window width
    property real creditsTextSize: 0.01 // ratio of width
  }

  // Title bar
  property QtObject titleBar: QtObject{
    property real height: 0.0475
    property real fontSize: 0.45 // relative to bar height
    property real fontLetterSpacing: 1 // letter spacing between characters
    property real logoSize: 0.4 // relative to bar height
    property real horizontalPadding: 0.2 // relative to bar height
  }

  // GUI Tooltips:
  property QtObject toolTips: QtObject{
    property int showDelayMS: 300 // delay in milliseconds before appearance
    // max width, rel. to tooltip item width before wrapping text
    property real maxWidth: 2.0
    // all size quantities below are relative to parent height
    property real textSize: 0.75
    // offset in y (up if shown on top, down if shown below)
    property real offsetY: 0.4
    property real textPadding: 0.4 // padding around text to surrounding box
    property real offsetX: -textPadding // align tt text with the parent text
  }

  // MP3 File Control Box
  property QtObject fileControl: QtObject{
    // box
    property real height: 0.04 // ratio of window width
    // the width of the box is equal to the window width

    // buttons and text fields all have the same height
    property real itemHeight: 0.8 // ratio of box height

    // buttons
    // height is equal to height of bar minus padding
    property real buttonSpacing: 0.2 // ratio of box height
    property real buttonWidth: 1.8 // ratio of box height
    property real buttonRadius: 0.08 // radius of button border, rel. to button height
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

    // title
    property real titleFontSize: 0.55 // ratio to titleWidth
    property real titleWidth: 0.06 // ratio to box width
    property real titleBorderWidth: 0.01 // ratio to box width
    property real titleLetterSpacing: 2.7 // letter spacing between characters

    // direction Radios
    property real directionRadioHeight: 1.0 // ratio of slider height
    property real directionRadioTextSpacing: 0.2 // radio of radio height
    property real directionRadioTextSize: 0.75 // radio of radio height
    property real directionRadioIndicatorSize: 0.8 // radio of radio height

    // type radios
    property real typeRadioHeight: 0.07 // ratio of box width
    property real typeRadioRadius: 0.1 // ratio of radio height
    property real typeRadioBorderWidth: 0.05 // ratio of radio height
    // when type radio is selected, border grows and flips to tab background
    // color, set ratio here:
    property real typeRadioActiveBorderWidthRatio: 2.6 // ratio of border width
    property real typeRadioTextPadding: 0.24 // ratio of radio height
    // ratio of available height = radio height - 2 * textPadding
    property real typeRadioTextHeight: 0.65
    // distance type radio to settings box
    property real typeRadioToSettingsBox: 0.5 // ratio of guimargin

    // primitive box
    property real primitiveBoxWidth: 0.2 // ratio of available width
    property real dragHintTextSize: 0.2 // ratio of primitive height
    property real selectionHighlightOpacity: 0.65 // ratio of primitive height

    // setting box

    // sliders:
    property real sliderHeight: 0.035 // ratio of box width
    property real sliderBarSize: 0.2 // ratio of slider handle size
    property real sliderTickHeight: 2 // ratio of slider bar height
    property real sliderTickWidth: 2 // ratio of slider bar height
    property real sliderLabelWidth: 0.25 // ratio of width available for settings sliders
    property real sliderLabelTextSize: 0.8 // ratio of slider height
    property real sliderValueWidth: 0.1 // ratio of width available for settings sliders
    property real sliderValueTextSize: 0.6 // ratio of slider height
    property real sliderFractionTextSize: 0.6 // ratio of slider height
    property real sliderIconWidth: 0.08 // ratio of box width
    property real sliderItemHSpacing: 0.4 // ratio of sliderHeight
    // led toggles
    property real ledRadioDiameter: 0.8 // ratio of type radio diameter
    property real ledRadioSpacing: 0.35 // ratio of diameter
    property real ledTextSize: 1.0 // ratio of diameter
  }

  // Timer bar window
  property QtObject timerBar: QtObject{
    property real height: 0.055 // ratio of window width
    // space between timer bars
    property real spacing: 0.125 // ratio of timerBar height
    property real beatWidth: 2.0/80.0 // line width of beat indicators

    // moving time indicator
    property real timeBarWidth: 3.0/80.0 // ratio of single timer bar height
    property real timeBarHeight: 1.07 // ratio of height
    property real timeBarScrollOffset: 25.0/80.0 // ratio of height

    // target average beat spacing, as ratio of window width
    property real beatSpacing: 0.013

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
    property real textPosX: 6.0/72.0
    property real textPosY: 4.0/72.0
    property real textSize: 0.25 // ratio of height
    property bool textBold: true
    property real borderWidth: 2.0 / 72.0 // ratio of height
    // margin of primitive at which a drag causes a size change
    // is capped at half primtive width
    property real resizeMarginRight: 0.6 // ratio of avg beat width
    property real resizeHandleOpacity: 0.40 // ratio of height

    // small extra mark inside resize handle (width = to prim border width)
    property real resizeHandleSmallMarkHeight: 0.20 // ratio of height

    // TOOLTIP STYLE
    property real toolTipFontSize: 16.0 / 72.0 // ratio of height
    property real toolTipPadding: 4.0 / 72.0 // ratio of height
    property real ledToolTipLEDSize: 10.0 / 72.0 // ratio of height
	}

  property QtObject audioControl: QtObject{
    // width of time slider is same as window size
    property real sliderHeight: 0.02 // ratio of window width

    // Play Slider
    property real sliderHandleBorderWidth: 3 // border width

    // Play / Pause Buttons
    property real buttonHeight: 1.8 // ratio of sliderHeight
    property real buttonSpacing: 0.25 // ratio of sliderHeight
    property real buttonIconSize: 0.5 // ratio to buttonHeight

    // timer visuals
    property real timerFontSize: 0.8 // ratio of sliderHeight
  }
}
