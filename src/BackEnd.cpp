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

#include "BackEnd.h"

#include <stdio.h>
#include <QtDebug>
#include <QThread>
#include <QEventLoop>
#include <QtConcurrent>
#include <QDataStream>

#include "Primitive.h"
#include "Utils.h"
#include "PrimitiveToSignal.h"

BackEnd::BackEnd(QObject* parent) :
  QObject{ parent },
  mAudioFile{},
  mBeatDetector{ static_cast<unsigned int>(mAudioFile.sampleRate) },
  mFileStatus{ "Idle" },
  mLoadFuture{},
  mLoadFutureWatcher{},
  mSaveFuture{},
  mSaveFutureWatcher{},
  mMotorPrimitives{ new PrimitiveList{this} },
  mLedPrimitives{ new PrimitiveList{this} },
  mAudioPlayer{ new AudioPlayer{this} }
{
  // connect load and save thread finish signal to backend handler slots
  connect(&mLoadFutureWatcher, &QFutureWatcher<bool>::finished,
          this, &BackEnd::handleDoneLoading);
  connect(&mSaveFutureWatcher, &QFutureWatcher<bool>::finished,
          this, &BackEnd::handleDoneSaving);
}

//** PROPERTY SETTERS GETTERS AND NOTIFIERS **//
QString BackEnd::songTitle() {
  return mSongTitle;
}

QString BackEnd::songComment() {
  return mSongComment;
}

QString BackEnd::songArtist() {
  return mSongArtist;
}

QString BackEnd::fileStatus() {
  return mFileStatus;
}

PrimitiveList* BackEnd::motorPrimitives(void) {
  return mMotorPrimitives;
}

PrimitiveList* BackEnd::ledPrimitives(void) {
  return mLedPrimitives;
}

AudioPlayer* BackEnd::audioPlayer(void) {
  return mAudioPlayer;
}

void BackEnd::setSongArtist(const QString& name) {
  if(name == mSongArtist)
    return;

  mSongArtist = name;
}

void BackEnd::setSongTitle(const QString& name) {
  if(name == mSongTitle)
    return;

  mSongTitle = name;
}

void BackEnd::setSongComment(const QString& comment) {
  if(comment == mSongComment)
    return;
  mSongComment = comment;
}

Q_INVOKABLE void BackEnd::loadMP3(const QString& filePath) {
  // convert to qurl and localized file path:
  QUrl localFilePath{ filePath };
  // clean models before loading:
  mMotorPrimitives->clear();
  mLedPrimitives->clear();

  // stop audio playback:
  mAudioPlayer->stop();

  mLoadFuture = QtConcurrent::run(this, &BackEnd::loadMP3Worker,
                                  localFilePath.toLocalFile());
  mLoadFutureWatcher.setFuture(mLoadFuture);
}

Q_INVOKABLE void BackEnd::saveMP3(const QString& filePath) {
  // convert to qurl and localized file path:
  QUrl localFilePath{ filePath };
  mSaveFuture = QtConcurrent::run(this, &BackEnd::saveMP3Worker,
                                  localFilePath.toLocalFile());
  mSaveFutureWatcher.setFuture(mSaveFuture);
}

void BackEnd::handleDoneLoading(void) {
  emit doneLoading(mLoadFuture.result());
  // read out primitives if it is a dancefile:
  // need to do that in main thread (here) as we are assigning the parent
  if(mAudioFile.isDancefile()) {
    readPrimitivesFromPrependData();
  }

  // setup audio player:
  mAudioPlayer->setAudioData(mAudioFile.mFloatMusic, mAudioFile.sampleRate);
}

void BackEnd::handleDoneSaving(void) {
  emit doneSaving(mSaveFuture.result());
}

bool BackEnd::loadMP3Worker(const QString& filePath) {
  mFileStatus = "Reading and decoding MP3...";
  emit fileStatusChanged();

  // clear all data
  mAudioFile.clear();
  mBeatFrames.clear();

  const AudioFile::Result res = mAudioFile.load(filePath);

  if(AudioFile::Result::eSuccess != res) {
    // loading failed, show an appropriate error message for a few seconds.
    switch(res) {
    case AudioFile::Result::eCorruptHeader:
      mFileStatus = "ERROR: Corrupt Dancefile header. Cannot process file.";
      break;
    case AudioFile::Result::eFileDoesNotExist:
      mFileStatus = "ERROR: File not found.";
      break;
    case AudioFile::Result::eMP3DecodingError:
      mFileStatus = "ERROR: Cannot decode corrupt MP3 File. Try different file.";
      break;
    case AudioFile::Result::eIOError:
      mFileStatus = "ERROR: File reading error. Try again or different file.";
      break;
    case AudioFile::Result::eNotAnMP3File:
      mFileStatus = "ERROR: Not a valid MP3 file. Try different file.";
      break;
    default:
      mFileStatus = "ERROR: Unexpected error loading file.";
      break;
    }
    emit fileStatusChanged();
    QThread::msleep(mErrorDisplayTimeMS);
    return false;
  }

  // otherwise, loading succeeded, set song and artist name:
  mSongArtist = QString{ mAudioFile.getArtist().c_str() };
  mSongTitle = QString{ mAudioFile.getTitle().c_str() };
  mSongComment = QString{ mAudioFile.getComment().c_str() };
  emit songArtistChanged();
  emit songTitleChanged();
  emit songCommentChanged();

  if(mAudioFile.isDancefile()) {
    mFileStatus = "Dancebot file detected, reading data...";
    emit fileStatusChanged();
    QThread::msleep(250);
    readBeatsFromPrependData();
  }
  else {
    mFileStatus = "Detecting Beats...";
    emit fileStatusChanged();
    std::vector<long> tmpBeats = mBeatDetector.detectBeats(
      mAudioFile.mFloatMusic);

    // convert the detected beats to int. This is fine because even a int32
    // would be able to hold beats detected up to 13 hours in a 44.1kHz sampled
    // song reserve enough memory for all detected beats plus dummy start and
    // end beats
    mBeatFrames.reserve(tmpBeats.size() + 2);

    // add zero beat if first detected beat is not at 0:
    if(0 != tmpBeats.front()) {
      mBeatFrames.push_back(0);
    }

    for(size_t i = 0; i < tmpBeats.size(); ++i) {
      mBeatFrames.push_back(static_cast<int>(tmpBeats[i]));
    }

    // add last beat at final plus one audio frame
    mBeatFrames.push_back(static_cast<int>(mAudioFile.mFloatData.size()));
  }

  // check if there are enough beats (four) to operate.
  if(mBeatFrames.size() < 4) {
    mFileStatus = "ERROR: Fewer than four beats detected. Cannot proceed. Try different file.";
    QThread::msleep(mErrorDisplayTimeMS);
    emit fileStatusChanged();
    return false;
  }
  // calculate average beat duration in frames,
  // ignoring first and last beat-intervals
  size_t sum = 0;
  for(size_t i = 2; i < mBeatFrames.size() - 1; ++i) {
    sum += static_cast<size_t>(mBeatFrames[i]) - mBeatFrames[i - 1];
  }
  mAverageBeatFrames = static_cast<int>(sum / (mBeatFrames.size() - 3u));

  mFileStatus = "Done.";
  emit fileStatusChanged();
  return true;
}

bool BackEnd::saveMP3Worker(const QString& fileName) {
  bool success{ true };
  mFileStatus = "Preparing beats, moves, and lights for saving...";
  QThread::msleep(250);
  emit fileStatusChanged();

  // write prepend data:
  if(!writePrependData()) {
    mFileStatus = "ERROR: Save data preparation failed. Sorry :(";
    emit fileStatusChanged();
    QThread::msleep(mErrorDisplayTimeMS);
    return false;
  }

  // instantiate primitive to audio signal converter
  PrimitiveToSignal primitiveConverter(mBeatFrames, mAudioFile);
  primitiveConverter.convert(mMotorPrimitives->getData(),
                             mLedPrimitives->getData());

  mFileStatus = "Saving to MP3 File";
  emit fileStatusChanged();
  // save file
  mAudioFile.setArtist(mSongArtist.toStdString());
  mAudioFile.setTitle(mSongTitle.toStdString());
  mAudioFile.setComment(mSongComment.toStdString());
  AudioFile::Result res = mAudioFile.save(fileName);

  if(AudioFile::Result::eSuccess != res) {
    // loading failed, show an appropriate error message for a few seconds.
    switch(res) {
    case AudioFile::Result::eNoDataToSave:
      mFileStatus = "ERROR: No data to save. Aborting.";
      break;
    case AudioFile::Result::eFileWriteError:
      mFileStatus = "ERROR: Cannot write data to file.";
      break;
    case AudioFile::Result::eMP3EncodingError:
      mFileStatus = "ERROR: MP3 encoding error.";
      break;
    case AudioFile::Result::eTagWriteError:
      mFileStatus = "ERROR: Could not write ID3 tag to MP3 file.";
      break;
    case AudioFile::Result::eFileOpenError:
      mFileStatus = "ERROR: Could not open / create output file.";
      break;
    default:
      mFileStatus = "ERROR: Unexpected error saving file.";
      break;
    }
    emit fileStatusChanged();
    QThread::msleep(mErrorDisplayTimeMS);
    return false;
  }

  return true;
}

std::vector<int> BackEnd::getBeats(void) const {
  return mBeatFrames;
}

int BackEnd::getAudioLengthInFrames(void) const {
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

void BackEnd::printLedPrimitives(void) const {
  mLedPrimitives->printPrimitives();
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

bool BackEnd::writePrependData(void) {
  // clear prepend data:
  mAudioFile.mMP3PrependData.clear();

  // create and open buffer to stream data into:
  QDataStream dataStream(&mAudioFile.mMP3PrependData, QIODevice::WriteOnly);
  AudioFile::applyDataStreamSettings(dataStream);

  // write number of beats first:
  quint32 nBeats = static_cast<quint32>(mBeatFrames.size());
  dataStream << nBeats;

  // write out beats:
  for(const int& beatFrame : mBeatFrames) {
    // all beat frames are nonnegative and smaller than 32 bits
    dataStream << static_cast<quint32>(beatFrame);
  }

  // next, write out motor primitives:
  const QList<QObject*> motPrimitives = mMotorPrimitives->getData();
  quint32 nMotorPrimitives = static_cast<quint32>(motPrimitives.size());
  dataStream << nMotorPrimitives;

  for(const auto& e : motPrimitives) {
    const MotorPrimitive* const mp = reinterpret_cast<const MotorPrimitive*>(e);
    mp->serializeToStream(dataStream);
  }

  // next, write out led primitives:
  const QList<QObject*> ledPrimitives = mLedPrimitives->getData();
  quint32 nLedPrimitives = static_cast<quint32>(ledPrimitives.size());
  dataStream << nLedPrimitives;

  for(const auto& e : ledPrimitives) {
    const LEDPrimitive* const lp = reinterpret_cast<const LEDPrimitive*>(e);
    lp->serializeToStream(dataStream);
  }

  return true;
}

bool BackEnd::readBeatsFromPrependData(void) {
  // create and open buffer to stream data into:
  QDataStream dataStream(&mAudioFile.mMP3PrependData, QIODevice::ReadOnly);
  AudioFile::applyDataStreamSettings(dataStream);

  // read number of beats first:
  quint32 nBeats = 0;
  dataStream >> nBeats;

  // reserve memory for the beats
  mBeatFrames.reserve(nBeats);

  // read out beats:
  for(size_t i = 0; i < nBeats; ++i) {
    quint32 beatFrame = 0;
    dataStream >> beatFrame;
    mBeatFrames.push_back(static_cast<int>(beatFrame));
  }

  return true;
}

bool BackEnd::readPrimitivesFromPrependData(void) {
  // create and open buffer to stream data into:
  QDataStream dataStream(&mAudioFile.mMP3PrependData, QIODevice::ReadOnly);
  AudioFile::applyDataStreamSettings(dataStream);

  // seek to end of beats:
  dataStream.device()->seek(4 * (mBeatFrames.size() + 1));

  // next, read out motor primitives:
  quint32 nMotorPrimitives = 0;
  dataStream >> nMotorPrimitives;

  for(size_t i = 0; i < nMotorPrimitives; ++i) {
    MotorPrimitive* mp = new MotorPrimitive(dataStream, nullptr);
    mMotorPrimitives->add(mp);
  }

  // next, read out led primitives:
  quint32 nLedPrimitives = 0;
  dataStream >> nLedPrimitives;

  for(size_t i = 0; i < nLedPrimitives; ++i) {
    LEDPrimitive* lp = new LEDPrimitive(dataStream, nullptr);
    mLedPrimitives->add(lp);
  }

  return true;
}
