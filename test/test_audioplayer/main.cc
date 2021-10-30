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

#include <QDebug>
#include <QGuiApplication>
#include <string>

#include "src/audio_file.h"
#include "src/audio_player.h"
#include "test/test_audioplayer/dummy_ui.h"
#include "test/test_folder_path.h"

const QString fileMusic44k{testFolderPath + "in44100.mp3"};

int main(int argc, char* argv[]) {
  AudioFile mp3File44k{};
  AudioFile::Result res = mp3File44k.load(fileMusic44k);

  if (res != AudioFile::Result::Success) {
    qDebug() << " error loading file ";
    return 0;
  }

  // make sure event loop will be active
  QCoreApplication::setOrganizationName("MINT&Pepper");

  QGuiApplication app(argc, argv);

  AudioPlayer player(&app);
  player.setNotifyInterval(500);

  DummyUI dummyUI{&player, &app};

  assert(mp3File44k.mFloatData.size() == mp3File44k.mFloatMusic.size());

  float time = 0.0f;
  float amp = 0.3f;
  float freq = 440.0f;
  float dt = 1.0f / mp3File44k.sampleRate;
  for (float& sample : mp3File44k.mFloatData) {
    sample = amp * sin(time * freq * 2.0f * 3.14159f);
    time += dt;
  }

  player.resetAudioOutput(mp3File44k.sampleRate);
  player.setAudioData(mp3File44k.mFloatMusic, mp3File44k.mFloatData);

  player.togglePlay();

  return app.exec();
}
