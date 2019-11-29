#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <QFuture>
#include <QFutureWatcher>

#include "AudioFile.h"
#include "AudioPlayer.h"
#include "BeatDetector.h"
#include "PrimitiveList.h"

class BackEnd : public QObject{
  Q_OBJECT;
  Q_PROPERTY(QString songArtist READ songArtist WRITE setSongArtist);
  Q_PROPERTY(QString songTitle READ songTitle WRITE setSongTitle);
  Q_PROPERTY(QString fileStatus READ fileStatus NOTIFY fileStatusChanged);
  Q_PROPERTY(PrimitiveList* motorPrimitives
             READ motorPrimitives NOTIFY motorPrimitivesChanged);
  Q_PROPERTY(PrimitiveList* ledPrimitives
             READ ledPrimitives NOTIFY ledPrimitivesChanged);
  Q_PROPERTY(AudioPlayer* audioPlayer READ audioPlayer NOTIFY audioPlayerChanged);

public:
  explicit BackEnd(QObject *parent = nullptr);

  QString songArtist();
  QString songTitle();
  QString fileStatus();
  PrimitiveList* motorPrimitives(void);
  PrimitiveList* ledPrimitives(void);
  AudioPlayer* audioPlayer(void);
  void setSongArtist(const QString &name);
  void setSongTitle(const QString& name);
  Q_INVOKABLE void loadMP3(const QString& filePath);
  Q_INVOKABLE void saveMP3(const QString& filePath);
  Q_INVOKABLE std::vector<int> getBeats(void) const;
  Q_INVOKABLE int getAudioLengthInFrames(void) const;
  Q_INVOKABLE int getSampleRate(void) const;
  Q_INVOKABLE int getAverageBeatFrames(void) const;
signals:
  void fileStatusChanged();
  void motorPrimitivesChanged();
  void ledPrimitivesChanged();
  void audioPlayerChanged();
  void doneLoading(const bool result);
  void doneSaving(const bool result);

public slots:
  void handleDoneLoading(void);
  void handleDoneSaving(void);
  void printMotPrimitives(void) const;
  void printLedPrimitives(void) const;
  int getBeatAtFrame(const int frame) const;

private:
  // init to 100bpm
  int mAverageBeatFrames{ 60 * AudioFile::sampleRate / 100 };

  QString mSongArtist;
  QString mSongTitle;

  QString mFileStatus;
  AudioFile mAudioFile;
  BeatDetector mBeatDetector;
  std::vector<int> mBeatFrames;
  QFuture<bool> mLoadFuture;
  QFutureWatcher<bool> mLoadFutureWatcher;
  QFuture<bool> mSaveFuture;
  QFutureWatcher<bool> mSaveFutureWatcher;

  PrimitiveList* mMotorPrimitives; // raw pointer fine because it is QObject
  PrimitiveList* mLedPrimitives; // raw pointer fine because it is QObject
  AudioPlayer* mAudioPlayer;

  bool loadMP3Worker(const QString& fileName);
};

#endif // BACKEND_H