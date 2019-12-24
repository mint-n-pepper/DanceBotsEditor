/*
*  Dancebots GUI - Create choreographies for Dancebots
*  https://github.com/philippReist/dancebots_gui
*
*  Copyright 2019 - mint & pepper
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

QtObject {
  id:root
  property var helpText:{
  '<html>
  <b>Howto</b><br>
  1. Load MP3<br>
  2. Edit and drag move and light items to timelines<br>
  3. Save MP3<br>
  4. Play on MP3 player connected to Dancebot<br>
  <table style="width:100%">
    <tr>
      <th colspan="2" align="left">Keyboard Commands</th>
    </tr>
    <tr>
      <td>Space:</td>
      <td>Play/Pause</td>
    </tr>
    <tr>
      <td>Shift:</td>
      <td>Select multiple items</td>
    </tr>
    <tr>
      <td>Control:</td>
      <td>Copy on timeline (while dragging)</td>
    </tr>
    <tr>
      <td></td>
      <td>(De-)select multiple items</td>
    </tr>
    <tr>
      <td>Delete:</td>
      <td>Delete selected items</td>
    </tr>
    <tr>
      <td>Escape:</td>
      <td>Deselect all</td>
    </tr>
  </table>
  </html>'
  }

  // <i>Space</i>: Play/Pause<br>
  // <i>Shift</i>: Select multiple items<br>
  // <i>Control</i>: Copy on timeline (while dragging)<br>
  // <i>Control</i>: (De-)select multiple items<br>
  // <i>Delete/Backspace</i>: Delete selected items<br>
  // <i>Escape</i>: Deselect all<br><br></html>

  property var creditsText:{
    'Copyright (c) 2019 - mint & pepper -
    <a href="https://www.mintpepper.ch">mintpepper.ch</a> <br>
    Authors: Philipp Reist, Robin Hanhart, and Raymond Oung <br>
    Source code and more info available at
    <a href="https://www.dancebots.ch">dancebots.ch</a> <br><br>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.<br><br>

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details, available at
    <a href="https://www.gnu.org/licenses">https://www.gnu.org/licenses</a>.'
  }
}
