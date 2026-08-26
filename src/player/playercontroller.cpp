#include "playercontroller.h"

#include <QBuffer>

#include "metadata/taglibmetadatabackend.h"

#include <QImage>
#include <QMimeDatabase>

PlayerController::PlayerController(QObject *parent) : QObject(parent)
{
    m_player.setAudioOutput(&m_audioOutput);
    m_audioOutput.setVolume(1.0f);

    connect(&m_player, &QMediaPlayer::durationChanged, this, &PlayerController::durationChanged);
    connect(&m_player, &QMediaPlayer::positionChanged, this, &PlayerController::positionChanged);
    connect(&m_player, &QMediaPlayer::playingChanged, this, &PlayerController::playingChanged);
    connect(&m_player, &QMediaPlayer::playbackStateChanged, this, [this](const QMediaPlayer::PlaybackState state)
    {
        const bool paused = (state == QMediaPlayer::PausedState);
        if (paused != isPaused())
            emit pausedChanged(paused);
    });

    connect(&m_player, &QMediaPlayer::errorOccurred, this, &PlayerController::errorOccurred);
}

void PlayerController::setPosition(qint64 position)
{
    m_player.setPosition(position);
}

int PlayerController::volume() const
{
    return qRound(m_audioOutput.volume() * 100.0f);
}

void PlayerController::setVolume(const int volume)
{
    const int clampedVolume = qBound(0, volume, 100);
    const int currentVolume = this->volume();
    if (currentVolume == clampedVolume) return;

    m_audioOutput.setVolume(static_cast<float>(clampedVolume) / 100.0f);

    emit volumeChanged(clampedVolume);
}

void PlayerController::setSource(const QUrl& source)
{
    if (source == m_player.source())
        return;

    m_player.stop();

    clearMetadata();

    if (source.isLocalFile()) {
        TagLibMetadataBackend backend;

        QString errorMessage;

        const auto fileInfo =
            backend.readFile(
                source.toLocalFile(),
                &errorMessage
            );

        if (fileInfo.has_value()) {
            m_title = fileInfo->metadata.title();
            m_artist = fileInfo->metadata.artist();
            m_album = fileInfo->metadata.album();

            m_coverUrl =
                makeCoverUrl(fileInfo->coverData);
        }
    }
    m_player.setSource(source);

    emit sourceChanged();
    emit metadataChanged();
}

void PlayerController::play() {
    m_player.play();
}

void PlayerController::pause() {
    m_player.pause();
}

void PlayerController::stop() {
    m_player.stop();
}

void PlayerController::togglePlayback() {
    if (isPlaying()) {
        pause();
    } else {
        play();
    }
}

QUrl PlayerController::makeCoverUrl(const QByteArray &imageData) {
    if (imageData.isEmpty())
        return {};

    QImage image;

    if (!image.loadFromData(imageData))
        return {};

    QBuffer buffer;

    /*
     * Re-encode the image into a predictable format so that QML receives
     * valid image data regardless of the original embedded format.
     */
    const bool hasAlpha = image.hasAlphaChannel();

    if (!image.save(&buffer, hasAlpha ? "PNG" : "JPEG")) {
        return {};
    }

    const QString mimeType = hasAlpha ? QStringLiteral("image/png") : QStringLiteral("image/jpeg");

    return QUrl(QStringLiteral("data:%1;base64,%2").arg(mimeType, QString::fromLatin1(buffer.data().toBase64())));
}

void PlayerController::clearMetadata() {
    m_title.clear();
    m_artist.clear();
    m_album.clear();
    m_coverUrl.clear();
}


