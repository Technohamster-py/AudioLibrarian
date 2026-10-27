#include "playercontroller.h"

#include <QBuffer>

#include "metadata/taglibmetadatabackend.h"


#include "utils/datautils.h"

PlayerController::PlayerController(QObject* parent) : QObject(parent)
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

void PlayerController::setMuted(const bool muted)
{
    if (muted == m_audioOutput.isMuted())
        return;

    m_audioOutput.setMuted(muted);
    emit mutedChanged(muted);
}

void PlayerController::setFilePath(const QString& path)
{
    setSource(QUrl::fromLocalFile(path));
}

/**
 * @brief Releases the media source while preserving the selected track and its metadata.
 */
void PlayerController::releaseSource()
{
    m_player.stop();
    m_player.setSource(QUrl{});
}

void PlayerController::setSource(const QUrl& source)
{
    if (source == m_selectedSource)
        return;

    m_player.stop();
    m_player.setSource(source);

    m_selectedSource = source;
    clearMetadata();

    if (source.isLocalFile())
    {
        TagLibMetadataBackend backend;
        QString errorMessage;
        const auto fileInfo = backend.readFile(source.toLocalFile(), &errorMessage);

        if (fileInfo.has_value())
        {
            m_title = fileInfo->metadata.title();
            m_artist = fileInfo->metadata.artist();
            m_album = fileInfo->metadata.album();
            m_coverUrl = DataUrl::makeDataUrl(fileInfo->coverData);
        }
    }

    emit sourceChanged();
    emit metadataChanged();
}

void PlayerController::play()
{
    if (m_selectedSource.isEmpty())
        return;

    if (m_player.source() != m_selectedSource)
        m_player.setSource(m_selectedSource);

    m_player.play();
}

void PlayerController::pause()
{
    m_player.pause();
}

void PlayerController::stop()
{
    m_player.stop();
}

void PlayerController::togglePlayback()
{
    if (isPlaying())
    {
        pause();
    }
    else
    {
        play();
    }
}

void PlayerController::clearMetadata()
{
    m_title.clear();
    m_artist.clear();
    m_album.clear();
    m_coverUrl.clear();
}
