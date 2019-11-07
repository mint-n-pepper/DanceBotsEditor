#include "AudioPlayer.h"
#include <QDataStream>
#include <QDebug>

AudioPlayer::AudioPlayer(QObject* parent):
  QObject{ parent },
  mRawAudioBuffer(&mRawAudio, this)
{
};

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

  // connect to handler:
  connect(mAudioOutput.get(), SIGNAL(stateChanged(QAudio::State)),
          this, SLOT(handleStateChanged(QAudio::State)));

  // get current volume:
  qreal initialVolume = mAudioOutput->volume();

  qDebug() << "Converted data, nSamples = " << mRawAudio.size() / 2;
  qDebug() << "Samples in raw audio was " << monoData.size();

};

int AudioPlayer::getCurrentLogVolume(void) {
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
  mRawAudioBuffer.open(QIODevice::ReadOnly);
  mRawAudioBuffer.seek(0);
  mAudioOutput->start(&mRawAudioBuffer);
}

void AudioPlayer::stop(void) {};

void AudioPlayer::pause(void) {};

void AudioPlayer::seek(float time) {};

void AudioPlayer::volumeChanged(int value) {};

void AudioPlayer::handleStateChanged(QAudio::State newState) {
  qDebug() << "Audio Player New State is " << newState;
}