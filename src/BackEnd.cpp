#include "BackEnd.h"

#include "QtDebug"
#include <stdio.h>
#include <QThread>
#include <QEventLoop>
#include <QtConcurrent>

BackEnd::BackEnd(QObject* parent) :
  QObject{ parent }, mAudioFile{},
  mBeatDetector{ mAudioFile.sampleRate },
  mLoadStatus{ "Idle" }, mLoadFutureWatcher{},
  mLoadFuture{}, mMotorPrimitives{ new PrimitiveList{this} }
{
  // connect load thread finish signal to backend load handling slot
  connect(&mLoadFutureWatcher, &QFutureWatcher<bool>::finished,
          this, &BackEnd::handleDoneLoading);
}

//** PROPERTY SETTERS GETTERS AND NOTIFIERS **//
QString BackEnd::songTitle()
{
  return mSongTitle;
}

QString BackEnd::songArtist()
{
    return mSongArtist;
}

QString BackEnd::loadStatus()
{
  return mLoadStatus;
}

PrimitiveList* BackEnd::motorPrimitives(void) {
  return mMotorPrimitives;
}

void BackEnd::setSongArtist(const QString &name)
{
    if (name == mSongArtist)
        return;

    mSongArtist = name;
}

void BackEnd::setSongTitle(const QString& name)
{
  if (name == mSongTitle)
    return;

  mSongTitle = name;
}

Q_INVOKABLE void BackEnd::loadMP3(const QString& filePath) {
  // convert to qurl and localized file path:
  QUrl localFilePath{ filePath };
  mLoadFuture = QtConcurrent::run(this, &BackEnd::loadMP3Worker,
                                  localFilePath.toLocalFile());
  mLoadFutureWatcher.setFuture(mLoadFuture);
}

void BackEnd::handleDoneLoading(void) {
  emit doneLoading(mLoadFuture.result());
}

bool BackEnd::loadMP3Worker(const QString& filePath) {
  mLoadStatus = "Reading and decoding MP3...";
  emit loadStatusChanged();

  mAudioFile.clear();
  const AudioFile::Result res = mAudioFile.load(filePath);

  if (!(AudioFile::Result::eSuccess == res)) {
    // loading failed

    return false;
  }

  // otherwise, loading succeeded, set song and artist name:
  mSongArtist = QString{ mAudioFile.getArtist().c_str() };
  mSongTitle = QString{ mAudioFile.getTitle().c_str() };

  mLoadStatus = "Detecting Beats...";
  emit loadStatusChanged();
  mBeatFrames = mBeatDetector.detectBeats(mAudioFile.mFloatMusic);
  
  /*
  qDebug() << "detected " << mBeatFrames.size() << " beats";
  size_t i = 0;
  for (const auto& e : mBeatFrames) {
    std::cout << "beat " << i << " is at " << e << std::endl;
  }

  mAudioFile.SavePCMBeats("beatBeep.wav", mBeatFrames);
  */

  mLoadStatus = "Done.";
  emit loadStatusChanged();
  QThread::msleep(1000);
  return true;
}

QVector<int> BackEnd::getBeats(void) const{
  QVector<int> returnVec;
  returnVec.reserve(mBeatFrames.size());
  for(auto const &a : mBeatFrames) {
    returnVec.push_back(static_cast<int>(a));
  }
  return returnVec;
}

Q_INVOKABLE int BackEnd::getAudioLengthInFrames(void) const{
  return static_cast<int>(mAudioFile.getLengthInFrames());
}
