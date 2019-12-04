#include "AudioPlayer.h"

AudioPlayer::AudioPlayer(QObject* parent):
  QObject{ parent },
  mRawAudioBuffer(&mRawAudio, this)
{
}

void AudioPlayer::setAudioData(const std::vector<float>& monoData,
                               const int sampleRate) {

  // clear any existing audio data:
  mRawAudio.clear();
  mAudioOutput.reset(nullptr); // delete audio output

  // set sample rate:
  mSampleRate = sampleRate;

  // create datastream with little endianness
  QDataStream stream(&mRawAudio, QIODevice::WriteOnly);
  stream.setByteOrder(mEndianness);

  // use 2^15 - 1 so that 1.0 is mapped to max value of int16
  const float MAX_INT16 = 32767.0f;

  for(const auto& e : monoData) {
    // clamp data to -1.0, 1.0 range:
    float rangeFloat = e > 1.0f ? 1.0f : e;
    if(rangeFloat < -1.0f) rangeFloat = -1.0f;

    // convert to int16
    qint16 frame = static_cast<qint16>(e * MAX_INT16);

    // push into stream:
    stream << frame;
  }

  // use default device for output:
  const QAudioDeviceInfo deviceInfo{ QAudioDeviceInfo::defaultOutputDevice() };

  // setup output:
  QAudioFormat format;
  format.setSampleRate(mSampleRate);
  format.setChannelCount(1); // mono data
  format.setSampleSize(16); // 16 bit
  format.setCodec("audio/pcm"); // raw samples
  format.setByteOrder(static_cast<QAudioFormat::Endian>(mEndianness));
  format.setSampleType(QAudioFormat::SignedInt);

  if(!deviceInfo.isFormatSupported(format)) {
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
  if(mAudioOutput->volume() != mVolumeLinear) {
    mAudioOutput->setVolume(mVolumeLinear);
  }

  // emit volume ready signal:
  emit volumeAvailable();

  // connect to handler:
  connectAudioOutputSignals();

  // and open and reset buffer
  mRawAudioBuffer.open(QIODevice::ReadOnly);
  mRawAudioBuffer.reset(); // in case of reload, rewind

  // and start to shorten startup time
  mStartupStart = true;
  mAudioOutput->start(&mRawAudioBuffer);
}

qreal AudioPlayer::getCurrentLogVolume(void) {
  if(mAudioOutput) {
    mVolumeLinear = mAudioOutput->volume();
  }

  qreal logVolume = 1.0;
  if(1.0 != mVolumeLinear) {
    logVolume = QAudio::convertVolume(mVolumeLinear,
                                 QAudio::LinearVolumeScale,
                                 QAudio::LogarithmicVolumeScale);
  }

  return logVolume;
}

void AudioPlayer::togglePlay(void) {
  // ensure that output is not null:
  if(!mAudioOutput) {
    return;
  }

  // open if necessary
  if(!mRawAudioBuffer.isOpen()) {
    mRawAudioBuffer.open(QIODevice::ReadOnly);
  }

  // rewind audio if we are at the end:
  if(mRawAudioBuffer.atEnd()) {
    mRawAudioBuffer.reset();
  }

  // emit a notify of the new position:
  handleAudioOutputNotify();

  // And start / suspend according to state:
  switch(mAudioOutput->state()) {
  case QAudio::ActiveState:
    mAudioOutput->suspend();
    break;
  case QAudio::SuspendedState:
    mAudioOutput->resume();
    break;
  case QAudio::StoppedState:
  case QAudio::IdleState:
    mAudioOutput->start(&mRawAudioBuffer);
    break;
  }
}

void AudioPlayer::stop(void) {
  if(mAudioOutput) {
    mAudioOutput->stop();
    mRawAudioBuffer.reset();
    // emit change of position
    handleAudioOutputNotify();
  }
}

void AudioPlayer::pause(void) {
  if(mAudioOutput) {
    mAudioOutput->suspend();
  }
}

void AudioPlayer::handleAudioOutputNotify(void) {
  // get current position in buffer and compensate
  // for buffer delay
  qint64 pos = mRawAudioBuffer.pos() - mAudioOutput->bufferSize();
  if(pos < 0) { pos = 0; }
  // convert to MS:
  // 1000 * pos / 2 / SampleRate - /2 for two bytes per frame
  const int timeMS = 500 * pos / mSampleRate;

 // and inform subscribers
 emit notify(timeMS);
}

void AudioPlayer::connectAudioOutputSignals() {
  // state change
  connect(mAudioOutput.get(), SIGNAL(stateChanged(QAudio::State)),
          this, SLOT(handleStateChanged(QAudio::State)));
  // notify
  connect(mAudioOutput.get(), SIGNAL(notify()),
          this, SLOT(handleAudioOutputNotify()));
}

void AudioPlayer::seek(const int timeMS) {
  if(!mAudioOutput) {
    return;
  }
  const size_t bufferPos = ((timeMS * 441) / 10) * 2;
  if(bufferPos >= 0 && bufferPos < mRawAudio.size() - 1) {
    // suspend quick:
    mRawAudioBuffer.seek(bufferPos);
  }
}

void AudioPlayer::setVolume(const qreal valueLogarithmic) {
  mVolumeLinear = QAudio::convertVolume(valueLogarithmic,
                                        QAudio::LogarithmicVolumeScale,
                                        QAudio::LinearVolumeScale);
  if(mAudioOutput) {
    mAudioOutput->setVolume(mVolumeLinear);
  }
}

void AudioPlayer::setNotifyInterval(const int intervalMS) {
  mNotifyInterval = intervalMS;
  if(mAudioOutput) {
    mAudioOutput->setNotifyInterval(intervalMS);
  }
}

void AudioPlayer::handleStateChanged(QAudio::State newState) {
  // TODO: might have to implement error handling here
  if(mStartupStart && mAudioOutput->state() == QAudio::ActiveState) {
    mAudioOutput->suspend();
    mStartupStart = false;
  }
}
