#ifndef DUMMYUI_H_
#define DUMMYUI_H_
#include <QDebug>
#include <QObject>

#include "AudioPlayer.h"

class DummyUI : public QObject {
  Q_OBJECT;

 public:
  DummyUI(AudioPlayer& player);

 private slots:
  void receiveNotify(int timeMS);

 private:
  AudioPlayer& mAudioPlayer;
};

#endif
