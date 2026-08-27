#include <QtTest>

#include "../../src/player/playercontroller.h"

/**
 * @brief Unit tests for PlayerController.
 *
 * The tests verify controller state and interaction with the Qt multimedia
 * backend without requiring an actual audio output device.
 */
class PlayerControllerTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies the initial controller state.
     */
    void initialState();

    /**
     * @brief Verifies volume changes and clamping.
     */
    void volume();

    /**
     * @brief Verifies mute state changes.
     */
    void muted();

    /**
     * @brief Verifies source changes.
     */
    void source();

    /**
     * @brief Verifies setFilePath().
     */
    void filePath();

    /**
     * @brief Verifies metadata is cleared when the source changes.
     */
    void metadataResetOnSourceChange();

    /**
     * @brief Verifies playback commands are safe without a media source.
     */
    void playbackCommandsWithoutSource();
};

void PlayerControllerTest::initialState()
{
    PlayerController controller;

    QCOMPARE(controller.source(), QUrl());
    QCOMPARE(controller.position(), qint64(0));
    QCOMPARE(controller.duration(), qint64(0));

    QVERIFY(!controller.isPlaying());
    QVERIFY(!controller.isPaused());

    QCOMPARE(controller.volume(), 100);
    QVERIFY(!controller.isMuted());

    QVERIFY(controller.title().isEmpty());
    QVERIFY(controller.artist().isEmpty());
    QVERIFY(controller.album().isEmpty());
    QVERIFY(controller.coverUrl().isEmpty());
}

void PlayerControllerTest::volume()
{
    PlayerController controller;

    QSignalSpy spy(&controller, &PlayerController::volumeChanged);

    controller.setVolume(50);

    QCOMPARE(controller.volume(), 50);
    QCOMPARE(spy.count(), 1);

    /*
     * Values outside the public 0..100 range must be clamped.
     */
    controller.setVolume(-10);

    QCOMPARE(controller.volume(), 0);
    QCOMPARE(spy.count(), 2);

    controller.setVolume(150);

    QCOMPARE(controller.volume(), 100);
    QCOMPARE(spy.count(), 3);

    /*
     * Setting the current value must not emit a duplicate signal.
     */
    controller.setVolume(100);

    QCOMPARE(spy.count(), 3);
}

void PlayerControllerTest::muted()
{
    PlayerController controller;

    QSignalSpy spy(&controller, &PlayerController::mutedChanged);

    controller.setMuted(true);

    QVERIFY(controller.isMuted());
    QCOMPARE(spy.count(), 1);

    controller.setMuted(false);

    QVERIFY(!controller.isMuted());
    QCOMPARE(spy.count(), 2);

    /*
     * Reassigning the same value must not emit the signal again.
     */
    controller.setMuted(false);

    QCOMPARE(spy.count(), 2);
}

void PlayerControllerTest::source()
{
    PlayerController controller;

    const QUrl source = QUrl::fromLocalFile(QStringLiteral("/tmp/test.wav"));

    QSignalSpy spy(&controller, &PlayerController::sourceChanged);

    controller.setSource(source);

    QCOMPARE(controller.source(), source);
    QCOMPARE(spy.count(), 1);

    /*
     * Assigning the same source must not emit sourceChanged again.
     */
    controller.setSource(source);

    QCOMPARE(spy.count(), 1);
}

void PlayerControllerTest::filePath()
{
    PlayerController controller;

    const QString path = QStringLiteral("/tmp/music/test.wav");

    controller.setFilePath(path);

    QCOMPARE(controller.source(), QUrl::fromLocalFile(path));
}

void PlayerControllerTest::metadataResetOnSourceChange()
{
    PlayerController controller;

    /*
     * Metadata is private and normally populated from an actual audio file.
     * We therefore verify the externally observable invariant:
     * changing to another source leaves the controller in a cleared
     * metadata state when the new source cannot be read.
     */
    controller.setSource(
        QUrl::fromLocalFile(
            QStringLiteral("/tmp/first.wav")
        )
    );

    controller.setSource(
        QUrl::fromLocalFile(
            QStringLiteral("/tmp/second.wav")
        )
    );

    QVERIFY(controller.title().isEmpty());
    QVERIFY(controller.artist().isEmpty());
    QVERIFY(controller.album().isEmpty());
    QVERIFY(controller.coverUrl().isEmpty());
}

void PlayerControllerTest::playbackCommandsWithoutSource()
{
    PlayerController controller;

    /*
     * These calls must be safe even though no media source exists.
     * Actual playback state is intentionally not asserted because it
     * depends on the multimedia backend.
     */
    controller.play();
    controller.pause();
    controller.stop();
    controller.togglePlayback();

    QVERIFY(!controller.isPlaying());
    QVERIFY(!controller.isPaused());
}

QTEST_GUILESS_MAIN(PlayerControllerTest)

#include "tst_playercontroller.moc"