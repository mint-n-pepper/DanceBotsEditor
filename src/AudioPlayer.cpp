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

#include "AudioPlayer.h"

AudioPlayer::AudioPlayer(QObject* parent)
    : QObject{parent}, mRawAudioBuffer(&mRawAudio, this) {}

void AudioPlayer::setAudioData(const std::vector<float>& monoData,
                               const int sampleRate) {
  // clear any existing audio data:
  mRawAudio.clear();
  mAudioOutput.reset(nullptr);  // delete audio output

  // set sample rate:
  mSampleRate = sampleRate;

  // create datastream with little endianness
  QDataStream stream(&mRawAudio, QIODevice::WriteOnly);
  stream.setByteOrder(mEndianness);

  // use 2^15 - 1 so that 1.0 is mapped to max value of int16
  const float MAX_INT16 = 32767.0f;

  for (const auto& e : monoData) {
    // clamp data to -1.0, 1.0 range:
    float rangeFloat = e > 1.0f ? 1.0f : e;
    if (rangeFloat < -1.0f) rangeFloat = -1.0f;

    // convert to int16
    qint16 frame = static_cast<qint16>(e * MAX_INT16);

    // push into stream:
    stream << frame;
  }

  // use default device for output:
  const QAudioDeviceInfo deviceInfo{QAudioDeviceInfo::defaultOutputDevice()};

  // setup output:
  QAudioFormat format;
  format.setSampleRate(mSampleRate);
  format.setChannelCount(1);     // mono data
  format.setSampleSize(16);      // 16 bit
  format.setCodec("audio/pcm");  // raw samples
  format.setByteOrder(static_cast<QAudioFormat::Endian>(mEndianness));
  format.setSampleType(QAudioFormat::SignedInt);

  if (!deviceInfo.isFormatSupported(format)) {
    qDebug() << "Default format not supported - trying to use nearest";
    format = deviceInfo.nearestFormat(format);
  }

  // make new output:
  mAudioOutput = std::make_unique<QAudioOutput>(format, this);

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

void AudioPlayer::stop(void) {
  if (mAudioOutput) {
    mAudioOutput->stop();
    mRawAudioBuffer.reset();
    // emit change of position
    handleAudioOutputNotify();
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
  // 1000 * pos / 2 / SampleRate - /2 for two bytes per frame
  const int timeMS = 500 * pos / mSampleRate;

  // and inform subscribers
  emit notify(timeMS);
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
  // calculate buffer position based on time, sampling rate
  const size_t bufferPos =
      ((static_cast<size_t>(timeMS) * mSampleRate) / 1000) * 2;
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
  // TODO: might have to implement error handling here
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
