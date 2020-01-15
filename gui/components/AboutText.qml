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
  '
  <html>
    <head>
      <style>
      li {
        padding-top: 2px;
      }
      th, td {
        padding: 2px 10px;
      }
      </style>
    </head>

    <body>
      <h3>How To</h3>
      <ol>
        <li>Load MP3</li>
        <li>Edit and drag <i>Move</i> and <i>Light</i> items to the timeline</li>
        <li>Save MP3</li>
        <li>Play on an MP3 player connected to a Dancebot</li>
      </ol>

      <br>

      <h3>Shortcuts</h3>
      <table style="width:100%; margin-left:15px;">
        <tr>
          <td>Space</td>
          <td>Play/Pause</td>
        </tr>
        <tr>
          <td>Shift</td>
          <td>Select multiple items</td>
        </tr>
        <tr>
          <td rowspan="2">Ctrl, ⌘-Cmd</td>
          <td>Copy on timeline while dragging</td>
        </tr>
        <tr>
          <td>(De-)select multiple items</td>
        </tr>
        <tr>
          <td>Delete</td>
          <td>Delete selected items</td>
        </tr>
        <tr>
          <td>Esc</td>
          <td>Deselect all</td>
        </tr>
      </table>
    </body>
  </html>
  '
  }

  // <i>Space</i>: Play/Pause<br>
  // <i>Shift</i>: Select multiple items<br>
  // <i>Control</i>: Copy on timeline (while dragging)<br>
  // <i>Control</i>: (De-)select multiple items<br>
  // <i>Delete/Backspace</i>: Delete selected items<br>
  // <i>Escape</i>: Deselect all<br><br></html>

  property var creditsText:{
    '
    <html>
    <body>
      <p>Copyright &copy; 2020 — mint & pepper —
      <a href="https://www.mintpepper.ch">mintpepper.ch</a><br>
      Authors: Philipp Reist, Robin Hanhart, and Raymond Oung<br>
      Source code and more info available at
      <a href="https://www.dancebots.ch">dancebots.ch</a></p>

      <p>This program is free software: you can redistribute it and/or modify
      it under the terms of the GNU General Public License as published by
      the Free Software Foundation, either version 3 of the License, or
      (at your option) any later version.</p>

      <p>This program is distributed in the hope that it will be useful,
      but WITHOUT ANY WARRANTY; without even the implied warranty of
      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      GNU General Public License for more details, available at
      <a href="https://www.gnu.org/licenses">https://www.gnu.org/licenses</a>.</p>

      <p>Dancebots Editor version 1.0.0-alpha</p>
    </body>
    </html>
    '
  }
}
