#ifndef AUDIO_PLAYER_H_
#define AUDIO_PLAYER_H_

#include <QObject>
#include <QAudioOutput>
#include <memory>
#include <QByteArray>
#include <QDataStream>
#include <vector>
#include <QBuffer>

class AudioPlayer :
  public QObject {
  Q_OBJECT;
public:
  AudioPlayer(QObject* parent);

  void setAudioData(const std::vector<float>& monoData,
                    const int sampleRate = 44100);

  Q_INVOKABLE int getCurrentLogVolume(void);

signals:
  void stopped(void);

public slots:
  void play(void);
  void stop(void);
  void pause(void);
  void seek(float time);
  void volumeChanged(int valueLogarithmic);

private slots:
  void handleStateChanged(QAudio::State newState);

private:
  qreal mVolumeLinear{ 0.0 };
  int mSampleRate{ 0 };
  const QDataStream::ByteOrder mEndianness{ QDataStream::LittleEndian };
  std::unique_ptr<QAudioOutput> mAudioOutput;
  QByteArray mRawAudio;
  QBuffer mRawAudioBuffer;
};

#endif AUDIO_PLAYER_H_