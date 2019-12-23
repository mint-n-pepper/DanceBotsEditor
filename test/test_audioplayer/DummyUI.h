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

#ifndef TEST_TEST_AUDIOPLAYER_DUMMYUI_H_
#define TEST_TEST_AUDIOPLAYER_DUMMYUI_H_
#include <QDebug>
#include <QObject>

#include "src/AudioPlayer.h"

class DummyUI : public QObject {
  Q_OBJECT;

 public:
  explicit DummyUI(AudioPlayer* player);

 private slots:
  void receiveNotify(int timeMS);

 private:
  AudioPlayer* mAudioPlayer;
};

#endif  // TEST_TEST_AUDIOPLAYER_DUMMYUI_H_
