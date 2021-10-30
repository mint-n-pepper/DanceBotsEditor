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

#ifndef TEST_TEST_AUDIOPLAYER_DUMMY_UI_H_
#define TEST_TEST_AUDIOPLAYER_DUMMY_UI_H_
#include <QDebug>
#include <QGuiApplication>
#include <QObject>

#include "src/audio_player.h"

class DummyUI : public QObject {
  Q_OBJECT;

 public:
  DummyUI(AudioPlayer* player, QGuiApplication* app);
  // NOLINTNEXTLINE
 private slots:
  void receiveNotify(int timeMS);

 private:
  AudioPlayer* mAudioPlayer;
  QGuiApplication* mApp;
};

#endif  // TEST_TEST_AUDIOPLAYER_DUMMY_UI_H_
