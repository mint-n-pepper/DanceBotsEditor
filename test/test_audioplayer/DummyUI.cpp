#include "DummyUI.h"

DummyUI::DummyUI(AudioPlayer& player) : mAudioPlayer{ player } {
    connect(&player,
            &AudioPlayer::notify,
            this, &DummyUI::receiveNotify);
}

void DummyUI::receiveNotify(int timeMS) {
  qDebug() << "Notify at " << timeMS << " milliseconds";

  // and play with seek by rewinding to 1s after 4s
  if(timeMS > 4000) {
    qDebug() << "Rewinding to 1000ms";
    mAudioPlayer.seek(1000);
  }
}