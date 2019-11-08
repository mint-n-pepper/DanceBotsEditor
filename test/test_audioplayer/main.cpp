#include "AudioFile.h"
#include "AudioPlayer.h"
#include "DummyUI.h"

#include <string>
#include <QGuiApplication>
#include <QDebug>

const QString fileMusic44k{ "./../test_mp3_files/in44100.mp3" };

int main(int argc, char* argv[]) {
  AudioFile mp3File44k{ };
  AudioFile::Result res = mp3File44k.load(fileMusic44k);

  if(res != AudioFile::Result::eSuccess) {
    qDebug() << " error loading file ";
    return 0;
  }

  // make sure event loop will be active
  QCoreApplication::setOrganizationName("MINT&Pepper");

  QGuiApplication app(argc, argv);

  AudioPlayer player(&app);
  player.setNotifyInterval(500);

  DummyUI dummyUI{ player };

  player.setAudioData(mp3File44k.mFloatMusic, mp3File44k.sampleRate);

  player.play();

  return app.exec();
}