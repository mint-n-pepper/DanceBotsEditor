#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QString>
#include <QFuture>
#include <QFutureWatcher>

#include "AudioFile.h"
#include "BeatDetector.h"

class BackEnd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString songArtist READ songArtist WRITE setSongArtist)
    Q_PROPERTY(QString songTitle READ songTitle WRITE setSongTitle)
    Q_PROPERTY(QString loadStatus READ loadStatus NOTIFY loadStatusChanged)

public:
    explicit BackEnd(QObject *parent = nullptr);

    QString songArtist();
    QString songTitle();
    QString loadStatus();
    void setSongArtist(const QString &name);
    void setSongTitle(const QString& name);
    Q_INVOKABLE void loadMP3(const QString& filePath);

signals:
    void loadStatusChanged();
    void doneLoading(const bool result);

public slots:
    void handleDoneLoading(void);

private:
    QString mSongArtist;
    QString mSongTitle;

    QString mLoadStatus;
    AudioFile mAudioFile;
    BeatDetector mBeatDetector;
    std::vector<long> mBeatFrames;
    QFuture<bool> mLoadFuture;
    QFutureWatcher<bool> mLoadFutureWatcher;

    bool loadMP3Worker(const QString& fileName);
};

#endif // BACKEND_H