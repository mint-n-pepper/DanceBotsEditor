#ifndef AUDIO_PLAYER_H_
#define AUDIO_PLAYER_H_

#include <QObject>
#include <QtMultimedia>
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

  Q_INVOKABLE qreal getCurrentLogVolume(void);

signals:
  void stopped(void);
  void notify(int currentPosMS);
  void volumeAvailable(void);

public slots:
  void togglePlay(void);
  void stop(void);
  void pause(void);
  void seek(const int timeMS);
  void setVolume(const qreal valueLogarithmic);
  void setNotifyInterval(const int intervalMS);

private slots:
  void handleStateChanged(QAudio::State newState);
  void handleAudioOutputNotify(void);

private:
  void connectAudioOutputSignals();
  qreal mVolumeLinear{ 1.0 }; // start with full volume
  int mSampleRate{ 0 };
  int mNotifyInterval{ 25 };
  const QDataStream::ByteOrder mEndianness{ QDataStream::LittleEndian };
  std::unique_ptr<QAudioOutput> mAudioOutput;
  QByteArray mRawAudio;
  QBuffer mRawAudioBuffer;
};

#endif

