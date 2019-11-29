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

  Q_INVOKABLE int getCurrentLogVolume(void) const;

signals:
  void stopped(void);
  void notify(int currentPosMS);

public slots:
  void togglePlay(void);
  void stop(void);
  void pause(void);
  void seek(const int timeMS);
  void setVolume(const int valueLogarithmic);
  void setNotifyInterval(const int intervalMS);

private slots:
  void handleStateChanged(QAudio::State newState);
  void handleAudioOutputNotify(void);

private:
  void connectAudioOutputSignals();
  qreal mVolumeLinear{ 0.0 };
  int mSampleRate{ 0 };
  int mNotifyInterval{ 100 };
  bool mStartupStart = true;
  const QDataStream::ByteOrder mEndianness{ QDataStream::LittleEndian };
  std::unique_ptr<QAudioOutput> mAudioOutput;
  QByteArray mRawAudio;
  QBuffer mRawAudioBuffer;
};

#endif AUDIO_PLAYER_H_