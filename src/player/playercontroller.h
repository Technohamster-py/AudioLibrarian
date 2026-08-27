#pragma once

#include <QObject>
#include <QUrl>

#include <QMediaPlayer>
#include <QAudioOutput>
#include <QtQmlIntegration/qqmlintegration.h>

class PlayerController : public QObject
{
    Q_OBJECT

    /**
     * @brief Currently loaded audio file.
     */
    Q_PROPERTY(
        QUrl source
        READ source
        NOTIFY sourceChanged
    )

    /**
     * @brief Current playback position in milliseconds.
     */
    Q_PROPERTY(
        qint64 position
        READ position
        WRITE setPosition
        NOTIFY positionChanged
    )

    /**
     * @brief Duration of the current track in milliseconds.
     */
    Q_PROPERTY(
        qint64 duration
        READ duration
        NOTIFY durationChanged
    )

    /**
     * @brief Whether the player is currently playing.
     */
    Q_PROPERTY(
        bool playing
        READ isPlaying
        NOTIFY playingChanged
    )

    /**
     * @brief Whether the player is currently paused.
     *
     * A stopped player is not considered paused.
     */
    Q_PROPERTY(
        bool paused
        READ isPaused
        NOTIFY pausedChanged
    )

    /**
     * @brief Playback volume in the range 0..100.
     *
     * QAudioOutput internally uses the range 0.0..1.0. The controller
     * deliberately exposes 0..100 because this is more convenient for
     * the application's UI.
     */
    Q_PROPERTY(
        int volume
        READ volume
        WRITE setVolume
        NOTIFY volumeChanged
    )

    /**
     * @brief Whether audio output is muted.
     */
    Q_PROPERTY(
        bool muted
        READ isMuted
        WRITE setMuted
        NOTIFY mutedChanged
    )

    /**
     * @brief Current track title.
     */
    Q_PROPERTY(
        QString title
        READ title
        NOTIFY metadataChanged
    )

    /**
     * @brief Current track artist.
     */
    Q_PROPERTY(
        QString artist
        READ artist
        NOTIFY metadataChanged
    )

    /**
     * @brief Current track album.
     */
    Q_PROPERTY(
        QString album
        READ album
        NOTIFY metadataChanged
    )

    /**
     * @brief Embedded cover image as a QML-compatible data URL.
     */
    Q_PROPERTY(
        QUrl coverUrl
        READ coverUrl
        NOTIFY metadataChanged
    )

    QML_ELEMENT

public:
    explicit PlayerController(QObject *parent = nullptr);
    ~PlayerController() override = default;

    QUrl source() const {return m_player.source();};
    qint64 position() const {return m_player.position();};
    void setPosition(qint64 position);
    qint64 duration() const {return m_player.duration();};
    bool isPlaying() const {return m_player.playbackState() == QMediaPlayer::PlayingState;};
    bool isPaused() const {return m_player.playbackState() == QMediaPlayer::PausedState;};
    int volume() const;
    void setVolume(const int volume);
    bool isMuted() const {return m_audioOutput.isMuted();};
    void setMuted(const bool muted);
    QString title() const {return m_title;};
    QString artist() const {return m_artist;};
    QString album() const {return m_album;};
    QUrl coverUrl() const {return m_coverUrl;};

public slots:
    void setSource(const QUrl& source);
    void play();
    void pause();
    void stop();
    void togglePlayback();

signals:
    void sourceChanged();
    void positionChanged(qint64 position);
    void durationChanged(qint64 duration);
    void playingChanged(bool playing);
    void pausedChanged(bool paused);
    void volumeChanged(int volume);
    void mutedChanged(bool muted);
    void metadataChanged();

    void errorOccurred(QMediaPlayer::Error error, const QString& errorString);

private:
    void clearMetadata();

    QMediaPlayer m_player;
    QAudioOutput m_audioOutput;

    QUrl m_coverUrl;
    QString m_title;
    QString m_artist;
    QString m_album;
};
