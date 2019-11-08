#include "AudioPlayer.h"

AudioPlayer::AudioPlayer(QObject* parent):
  QObject{ parent },
  mRawAudioBuffer(&mRawAudio, this)
{
}

void AudioPlayer::setAudioData(const std::vector<float>& monoData,
                               const int sampleRate) {
  // Kill the audio output:
  mAudioOutput.reset();

  // clear any existing audio data:
  mRawAudio.clear();

  // set sample rate:
  mSampleRate = sampleRate;

  // create datastream with little endianness
  QDataStream stream(&mRawAudio, QIODevice::WriteOnly);
  stream.setByteOrder(mEndianness);

  // use 2^15 - 1 so that 1.0 is mapped to max value of int16
  const float MAX_INT16 = 32767.0f;

  for(const auto& e : monoData) {
    // ensure that data is in -1.0, 1.0 range:
    float rangeFloat = e > 1.0f ? 1.0f : e;
    if(rangeFloat < -1.0f) rangeFloat = -1.0f;

    // convert to int16
    qint16 frame = static_cast<qint16>(e * MAX_INT16);

    // push into stream:
    stream << frame;
  }

  // use default device for now:
  const QAudioDeviceInfo deviceInfo{ QAudioDeviceInfo::defaultOutputDevice() };

  // now setup output:
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

  // set notify interval:
  mAudioOutput->setNotifyInterval(mNotifyInterval);

  // connect to handler:
  connectAudioOutputSignals();

  // get current volume:
  qreal initialVolume = mAudioOutput->volume();
}

int AudioPlayer::getCurrentLogVolume(void) const{
  return qRound(100*QAudio::convertVolume(mVolumeLinear,
                        QAudio::LinearVolumeScale,
                        QAudio::LogarithmicVolumeScale));
}

void AudioPlayer::play(void) {
  // ensure that output is not null:
  if(!mAudioOutput) {
    return;
  }
  qDebug() << "starting to play";
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

  // And start
  mAudioOutput->start(&mRawAudioBuffer);
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
  // get current position in buffer:
  const qint64 pos = mRawAudioBuffer.pos();
  // convert to MS:
  const int timeMS = 10 * pos / 882; // 1000 * pos / 2 / 44100

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
  if(bufferPos > 0 && bufferPos < mRawAudio.size() - 1) {
    // suspend quick:
    mAudioOutput->suspend();
    mRawAudioBuffer.seek(bufferPos);
    mAudioOutput->resume();
  }
}

void AudioPlayer::setVolume(const int valueLogarithmic) {}

void AudioPlayer::setNotifyInterval(const int intervalMS) {
  mNotifyInterval = intervalMS;
  if(mAudioOutput) {
    mAudioOutput->setNotifyInterval(intervalMS);
  }
}

void AudioPlayer::handleStateChanged(QAudio::State newState) {
  // TODO: might have to implement error handling here
}
