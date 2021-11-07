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

import QtQuick 2.6
import QtQuick.Controls 2.12

import "../GuiStyle"

Popup{
	id: root
  parent: Overlay.overlay
  anchors.centerIn: parent
  width: parent.width
  height: parent.height
  modal: true
	closePolicy: Popup.NoAutoClose

	background: Rectangle{
		anchors.centerIn: parent
    width: parent.width
    color: Style.palette.ovr_background
		opacity: Style.fileProcessOverlay.opacity
    height: Style.fileProcessOverlay.height * parent.height
		Text{
			anchors.centerIn: parent
      text: backend.fileStatus
      font.pixelSize: Style.fileProcessOverlay.fontSize * parent.height
      color: Style.palette.ovr_font
		}
	}

}
