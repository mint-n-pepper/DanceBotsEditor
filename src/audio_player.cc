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

#include "src/audio_player.h"

#include <algorithm>

AudioPlayer::AudioPlayer(QObject* parent)
    : QObject{parent}, mRawAudioBuffer(&mRawAudio, this) {}

void AudioPlayer::resetAudioOutput(const int sampleRate) {
  // use default device for output:
  const QAudioDeviceInfo deviceInfo{QAudioDeviceInfo::defaultOutputDevice()};
  mSampleRate = sampleRate;
  // setup output:
  QAudioFormat format;
  format.setSampleRate(mSampleRate);
  format.setChannelCount(2);     // mono data
  format.setSampleSize(16);      // 16 bit
  format.setCodec("audio/pcm");  // raw samples
  format.setByteOrder(static_cast<QAudioFormat::Endian>(mEndianness));
  format.setSampleType(QAudioFormat::SignedInt);

  if (!deviceInfo.isFormatSupported(format)) {
    qDebug() << "Default format not supported - trying to use nearest";
    format = deviceInfo.nearestFormat(format);
  }
  mAudioOutput = std::make_unique<QAudioOutput>(format, this);
}

void AudioPlayer::setAudioData(const std::vector<float>& leftChannel,
                               const std::vector<float>& rightChannel) {
  // clear any existing audio data:
  mRawAudio.clear();

  // create datastream with little endianness
  QDataStream stream(&mRawAudio, QIODevice::WriteOnly);
  stream.setByteOrder(mEndianness);

  assert(leftChannel.size() == rightChannel.size());
  mRawAudio.reserve(static_cast<int>(leftChannel.size() * numBytesPerFrame));
  for (size_t i = 0u; i < leftChannel.size(); ++i) {
    auto ClampToInt16 = [&](float in) -> qint16 {
      if (in > 1.0f) in = 1.0f;
      if (in < -1.0f) in = -1.0f;
      // convert to int16 and push into stream
      return static_cast<qint16>(in * 32767.0f);
    };
    // LEFT:
    stream << ClampToInt16(leftChannel[i]);
    // RIGHT:
    stream << ClampToInt16(rightChannel[i]);
  }

  mAudioOutput->setBufferSize(8192);

  // set notify interval:
  mAudioOutput->setNotifyInterval(mNotifyInterval);

  // get current output device volume and adjust to current setting
  // if not identical
  if (mAudioOutput->volume() != mVolumeLinear) {
    mAudioOutput->setVolume(mVolumeLinear);
  }

  // emit volume ready signal:
  emit volumeAvailable();

  // connect to handler:
  connectAudioOutputSignals();

  // and open and reset buffer
  mRawAudioBuffer.open(QIODevice::ReadOnly);
  mRawAudioBuffer.reset();  // in case of reload, rewind
}

qreal AudioPlayer::getCurrentLogVolume(void) {
  if (mAudioOutput) {
    mVolumeLinear = mAudioOutput->volume();
  }

  qreal logVolume = 1.0;
  if (1.0 != mVolumeLinear) {
    logVolume = QAudio::convertVolume(mVolumeLinear, QAudio::LinearVolumeScale,
                                      QAudio::LogarithmicVolumeScale);
  }

  return logVolume;
}

void AudioPlayer::togglePlay(void) {
  // ensure that output is not null:
  if (!mAudioOutput) {
    return;
  }

  // open if necessary
  if (!mRawAudioBuffer.isOpen()) {
    mRawAudioBuffer.open(QIODevice::ReadOnly);
  }

  // rewind audio if we are at the end:
  if (mRawAudioBuffer.atEnd()) {
    mRawAudioBuffer.reset();
  }

  // emit a notify of the new position:
  handleAudioOutputNotify();

  // And start / suspend according to state:
  switch (mAudioOutput->state()) {
    case QAudio::ActiveState:
      mAudioOutput->suspend();
      break;
    case QAudio::SuspendedState:
      mAudioOutput->resume();
      break;
    case QAudio::InterruptedState:
    case QAudio::StoppedState:
    case QAudio::IdleState:
      mAudioOutput->start(&mRawAudioBuffer);
      break;
  }
}

void AudioPlayer::stop(const bool emitTimeUpdate) {
  if (mAudioOutput) {
    mAudioOutput->stop();
    mRawAudioBuffer.reset();
    // emit change of position
    if (emitTimeUpdate) {
      handleAudioOutputNotify();
    }
  }
}

void AudioPlayer::pause(void) {
  if (mAudioOutput) {
    mAudioOutput->suspend();
  }
}

void AudioPlayer::handleAudioOutputNotify(void) {
  // get current position in buffer and compensate for buffer delay if not at
  // end (to make sure end is properly displayed by frontend)
  qint64 pos = 0;
  if (mRawAudioBuffer.atEnd()) {
    pos = mRawAudioBuffer.pos();
  } else {
    pos = mRawAudioBuffer.pos() - mAudioOutput->bufferSize();
  }

  if (pos < 0) {
    pos = 0;
  }
  // convert to MS:
  // 1000 * pos / 4 / SampleRate - /2 for two bytes per frame
  mTimeMS = 1000 / numBytesPerFrame * pos / mSampleRate;

  // and inform subscribers
  emit notify(mTimeMS);
}

void AudioPlayer::connectAudioOutputSignals() {
  // state change
  connect(mAudioOutput.get(), SIGNAL(stateChanged(QAudio::State)), this,
          SLOT(handleStateChanged(QAudio::State)));
  // notify
  connect(mAudioOutput.get(), SIGNAL(notify()), this,
          SLOT(handleAudioOutputNotify()));
}

void AudioPlayer::seek(const int timeMS) {
  if (!mAudioOutput || timeMS < 0) {
    return;
  }
  mAudioOutput->stop();
  // calculate buffer position based on time, sampling rate
  const size_t bufferPos =
      ((static_cast<size_t>(timeMS) * mSampleRate) / 1000) * numBytesPerFrame;
  if (bufferPos >= 0 && bufferPos < (mRawAudio.size() - 1)) {
    mRawAudioBuffer.seek(bufferPos);
  }
}

void AudioPlayer::setVolume(const qreal valueLogarithmic) {
  mVolumeLinear =
      QAudio::convertVolume(valueLogarithmic, QAudio::LogarithmicVolumeScale,
                            QAudio::LinearVolumeScale);
  if (mAudioOutput) {
    mAudioOutput->setVolume(mVolumeLinear);
  }
}

void AudioPlayer::setNotifyInterval(const int intervalMS) {
  mNotifyInterval = intervalMS;
  if (mAudioOutput) {
    mAudioOutput->setNotifyInterval(intervalMS);
  }
}

void AudioPlayer::handleStateChanged(QAudio::State newState) {
  // TODO(PhilippReist): might have to implement error handling here
  switch (newState) {
    case QAudio::ActiveState:
      mIsPlaying = true;
      break;
    case QAudio::SuspendedState:
    case QAudio::InterruptedState:
    case QAudio::StoppedState:
    case QAudio::IdleState:
      mIsPlaying = false;
      break;
  }
  emit isPlayingChanged();
}
