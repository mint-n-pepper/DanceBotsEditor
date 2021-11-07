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

#include "test/test_audioplayer/dummy_ui.h"

DummyUI::DummyUI(AudioPlayer* player, QGuiApplication* app)
    : mAudioPlayer{player}, mApp{app} {
  connect(player, &AudioPlayer::notify, this, &DummyUI::receiveNotify);
}

void DummyUI::receiveNotify(int timeMS) {
  static int count = 0;
  qDebug() << "Notify at " << timeMS << " milliseconds";

  // and play with seek by rewinding to 1s after 2s
  if (timeMS > 2000) {
    qDebug() << "Rewinding to 1000ms";
    mAudioPlayer->seek(1000);
    mAudioPlayer->togglePlay();
    // quit application after two rewinds:
    if (count++ > 1) {
      mApp->quit();
    }
  }
}
