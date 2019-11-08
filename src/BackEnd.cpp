#include "BackEnd.h"

#include "QtDebug"
#include <stdio.h>
#include <QThread>
#include <QEventLoop>
#include <QtConcurrent>
#include "Utils.h"

BackEnd::BackEnd(QObject* parent) :
  QObject{ parent },
  mAudioFile{},
  mBeatDetector{ mAudioFile.sampleRate },
  mLoadStatus{ "Idle" },
  mLoadFutureWatcher{},
  mLoadFuture{},
  mMotorPrimitives{ new PrimitiveList{this} },
  mAudioPlayer{new AudioPlayer{this}}
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

AudioPlayer* BackEnd::audioPlayer(void) {
  return mAudioPlayer;
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
  // setup audio player:
  mAudioPlayer->setAudioData(mAudioFile.mFloatMusic, mAudioFile.sampleRate);
}

bool BackEnd::loadMP3Worker(const QString& filePath) {
  mLoadStatus = "Reading and decoding MP3...";
  emit loadStatusChanged();

  mAudioFile.clear();
  const AudioFile::Result res = mAudioFile.load(filePath);

  if (AudioFile::Result::eSuccess != res) {
    // loading failed
    return false;
  }

  // otherwise, loading succeeded, set song and artist name:
  mSongArtist = QString{ mAudioFile.getArtist().c_str() };
  mSongTitle = QString{ mAudioFile.getTitle().c_str() };

  mLoadStatus = "Detecting Beats...";
  emit loadStatusChanged();
  std::vector<long> tmpBeats = mBeatDetector.detectBeats(mAudioFile.mFloatMusic);

  // check if beats could be detected. We need at least four to operate.
  if(tmpBeats.size() < 4) {
    mLoadStatus = "FAILED: Fewer than four beats detected.";
    emit loadStatusChanged();
    QThread::msleep(1000);
    return false;
  }

  // calculate average beat duration in frames:
  size_t sum = 0;

  for(size_t i = 2; i < tmpBeats.size() - 1; ++i) {
    sum += static_cast<size_t>(tmpBeats[i]) - tmpBeats[i - 1];
  }

  mAverageBeatFrames = static_cast<int>(sum / (tmpBeats.size() - 3u));

  // convert the detected beats to int. This is fine because even a int32 would
  // be able to hold beats detected up to 13 hours in a 44.1kHz sampled song
  // reserve enough memory for all detected beats plus dummy start and end beats
  mBeatFrames.reserve(tmpBeats.size() + 2);

  // add zero beat if first detected beat is not at 0:
  if(0 != tmpBeats.front()) {
    mBeatFrames.push_back(0);
  }

  for(size_t i = 0; i < tmpBeats.size(); ++i) {
    mBeatFrames.push_back(static_cast<int>(tmpBeats[i]));
  }

  // add last beat at final plus one audio frame
  mBeatFrames.push_back(static_cast<int>(mAudioFile.mFloatData.size() + 1));


/*  qDebug() << "detected " << mBeatFrames.size() << " beats";

  for(size_t i = 0; i < 10; i++) {
    std::cout << "beat " << i << " is at " << mBeatFrames[i] << std::endl;
  }

 */
 //  mAudioFile.SavePCMBeats("beatBeep.wav", mBeatFrames);

  mLoadStatus = "Done.";
  emit loadStatusChanged();
  QThread::msleep(100);
  return true;
}

std::vector<int> BackEnd::getBeats(void) const{
  return mBeatFrames;
}

int BackEnd::getAudioLengthInFrames(void) const{
  return static_cast<int>(mAudioFile.getLengthInFrames());
}

int BackEnd::getSampleRate(void) const {
  return AudioFile::sampleRate;
}

int BackEnd::getAverageBeatFrames(void) const {
  return mAverageBeatFrames;
}

void BackEnd::printMotPrimitives(void) const {
  mMotorPrimitives->printPrimitives();
}

int BackEnd::getBeatAtFrame(const int frame) const {
  // run utility function to find beat
  size_t ind = 0;
  // use binary search, as it is much faster for larger arrays
  // and about the same speed as linear search for smaller ones
  int rv = utils::findInterval<int>(frame,
                                    mBeatFrames,
                                    ind,
                                    utils::SearchMethod::eBinary);

  // return -1 if search failed
  if(rv < 0) {
    return -1;
  }

  // otherwise return index
  return static_cast<int>(ind);
}
