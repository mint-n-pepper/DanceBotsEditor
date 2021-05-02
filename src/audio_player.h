/*
 *  Dancebots GUI - Create choreographies for Dancebots
 *  https://github.com/philippReist/dancebots_gui
 *
 *  Copyright 2019-2021 - mint & pepper
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

#ifndef SRC_AUDIO_PLAYER_H_
#define SRC_AUDIO_PLAYER_H_

#include <QBuffer>
#include <QByteArray>
#include <QDataStream>
#include <QObject>
#include <QtMultimedia>
#include <memory>
#include <vector>

/** \class AudioPlayer
 * \brief Plays back audio from raw data to QAudioOutput
 */
class AudioPlayer : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)

 public:
  explicit AudioPlayer(QObject* parent);

  /**
   * \brief Reset and setup the audio output - use before setting audio data.
   */
  void resetAudioOutput(const int sampleRate = 44100);

  /**
   * \brief Set the audio data to be played back
   *
   * \note Use resetAudioOutput before calling this method.
   *
   * \param[in] monoData - a vector of float audio data
   * \param[in] sampleRate - the audio sample rate
   */
  void setAudioData(const std::vector<float>& leftChannel,
                    const std::vector<float>& rightChannel);

  /**
   * \brief Get current playback volume in logarithmic representation
   *
   * \return log volume
   */
  Q_INVOKABLE qreal getCurrentLogVolume(void);

  /**
   * \brief Get current playback time in audio buffer in MS
   *
   * \return time in MS
   */
  Q_INVOKABLE qreal getCurrentPlaybackTime(void) const { return mTimeMS; }

  /**
   * \brief Get current play status
   *
   * \return if player is playing (true)
   */
  bool isPlaying(void) const { return mIsPlaying; }

  // NOLINTNEXTLINE
 signals:
  void isPlayingChanged(void);

  /**
   * \brief Signal to update GUI elements with the current playback time in
   * the audio data.
   * \param[in] currentPosMS - the current position in the audio data in
   * milliseconds. The current position is compensated for audio buffer lag, and
   * the notify interval can be set using setNotifyInterval.
   */
  void notify(int currentPosMS);

  /**
   * \brief Signal emitted when the current playback volume is available
   */
  void volumeAvailable(void);

  // NOLINTNEXTLINE
 public slots:
  /**
   * \brief Toggles playback between play and pause
   */
  void togglePlay(void);

  /**
   * \brief Stops playback and rewinds playback data to start
   *
   * \param[in] emitTimeUpdate: Emit time update signal
   */
  void stop(const bool emitTimeUpdate = true);

  /**
   * \brief Pauses playback
   */
  void pause(void);

  /**
   * \brief Seeks audio data playback buffer to playback time given in MS.
   *
   * \param[in] timeMS - the time to seek to.
   */
  void seek(const int timeMS);

  /**
   * \brief Set volume of audio output
   *
   * \param[in] valueLogarithmic - the desired volume in log representation
   */
  void setVolume(const qreal valueLogarithmic);

  /**
   * \brief Set notification interval at which to emit the notify() signal
   *
   * \param[in] intervalMS - the desired interval in milliseconds
   */
  void setNotifyInterval(const int intervalMS);

  // NOLINTNEXTLINE
 private slots:
  /**
   * \brief Handler for state changed signal
   *
   * \param[in] newState - the new playback state
   */
  void handleStateChanged(QAudio::State newState);

  /**
   * \brief Handler for audio output notify signal, which then emits the notify
   * signal of this class
   */
  void handleAudioOutputNotify(void);

 private:
  /**
   * \brief Connect internal signals and slots
   */
  void connectAudioOutputSignals();

  const int numBytesPerFrame = 4;
  bool mIsPlaying = false;
  qreal mVolumeLinear = 1.0; /**< Audio volume in linear representation */
  int mSampleRate = 0;
  int mTimeMS = 0;
  int mNotifyInterval = 25; /**< Audio time update interval in MS */
  const QDataStream::ByteOrder mEndianness = QDataStream::LittleEndian;
  std::unique_ptr<QAudioOutput> mAudioOutput;
  QByteArray mRawAudio;
  QBuffer mRawAudioBuffer;
};

#endif  // SRC_AUDIO_PLAYER_H_
