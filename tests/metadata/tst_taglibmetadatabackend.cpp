#include <QtTest>

#include "../../src/metadata/audiometadata.h"
#include "../../src/metadata/taglibmetadatabackend.h"

#include <QFile>
#include <QTemporaryDir>

/**
 * @brief Creates a minimal PCM WAV file suitable for TagLib tests.
 *
 * The generated file contains a valid RIFF/WAVE header and one second of
 * silence. The audio data itself is irrelevant to the metadata tests.
 *
 * @param filePath Destination path.
 * @return true if the WAV file was created successfully.
 */
static bool createTestWav(const QString &filePath) {
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly))
        return false;

    constexpr quint32 sampleRate = 44100;
    constexpr quint16 channels = 1;
    constexpr quint16 bitsPerSample = 16;
    constexpr quint32 sampleCount = sampleRate;

    constexpr quint16 blockAlign =
        channels * (bitsPerSample / 8);

    constexpr quint32 byteRate =
        sampleRate * blockAlign;

    constexpr quint32 dataSize =
        sampleCount * blockAlign;

    constexpr quint32 riffSize =
        36 + dataSize;

    QDataStream stream(&file);
    stream.setByteOrder(QDataStream::LittleEndian);

    /*
     * RIFF/WAVE header.
     */
    stream.writeRawData("RIFF", 4);
    stream << riffSize;
    stream.writeRawData("WAVE", 4);

    /*
     * PCM format chunk.
     */
    stream.writeRawData("fmt ", 4);
    stream << quint32(16);
    stream << quint16(1);
    stream << channels;
    stream << sampleRate;
    stream << byteRate;
    stream << blockAlign;
    stream << bitsPerSample;

    /*
     * One second of silence.
     */
    stream.writeRawData("data", 4);
    stream << dataSize;

    QByteArray silence(
        static_cast<qsizetype>(dataSize),
        '\0'
    );

    stream.writeRawData(silence.constData(), silence.size());

    return stream.status() == QDataStream::Ok;
}

/**
 * @brief Unit tests for the TagLib metadata backend.
 */
class TagLibMetadataBackendTest final : public QObject {
    Q_OBJECT

private slots:
    /**
     * @brief Verifies that invalid paths are reported as errors.
     */
    void readInvalidFile();

    /**
     * @brief Verifies metadata read/write round-trip.
     */
    void readWriteRoundTrip();

    /**
     * @brief Verifies that arbitrary metadata properties survive the
     *        backend conversion.
     */
    void multipleValues();
};

void TagLibMetadataBackendTest::readInvalidFile() {
    const TagLibMetadataBackend backend;

    QString error;

    const auto metadata = backend.read(
        QStringLiteral("/this/file/does/not/exist.mp3"),
        &error
    );

    QVERIFY(!metadata.has_value());
    QVERIFY(!error.isEmpty());
}

void TagLibMetadataBackendTest::readWriteRoundTrip() {
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(QStringLiteral("test.wav"));

    QVERIFY(createTestWav(filePath));

    const TagLibMetadataBackend backend;

    AudioMetadata metadata;

    metadata.setTitle(QStringLiteral("Test title"));
    metadata.setArtist(QStringLiteral("Test artist"));
    metadata.setAlbum(QStringLiteral("Test album"));
    metadata.setGenre(QStringLiteral("Test genre"));
    metadata.setTrackNumber(QStringLiteral("3/12"));

    QString error;

    QVERIFY(backend.write(filePath, metadata, &error));
    QVERIFY2(error.isEmpty(), qPrintable(error));

    const auto loadedMetadata = backend.read(filePath, &error);

    QVERIFY2(loadedMetadata.has_value(), qPrintable(error));

    QCOMPARE(
        loadedMetadata->title(),
        QStringLiteral("Test title")
    );

    QCOMPARE(
        loadedMetadata->artist(),
        QStringLiteral("Test artist")
    );

    QCOMPARE(
        loadedMetadata->album(),
        QStringLiteral("Test album")
    );

    QCOMPARE(
        loadedMetadata->genre(),
        QStringLiteral("Test genre")
    );

    QCOMPARE(
        loadedMetadata->trackNumber(),
        QStringLiteral("3/12")
    );
}

void TagLibMetadataBackendTest::multipleValues() {
    QTemporaryDir temporaryDirectory;
    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(QStringLiteral("test.wav"));

    QVERIFY(createTestWav(filePath));

    const TagLibMetadataBackend backend;

    AudioMetadata metadata;

    metadata.setValues(
        QStringLiteral("ARTIST"),
        {
            QStringLiteral("Artist One"),
            QStringLiteral("Artist Two")
        }
    );

    QString error;

    QVERIFY(backend.write(filePath, metadata, &error));
    QVERIFY2(error.isEmpty(), qPrintable(error));

    const auto loadedMetadata = backend.read(filePath, &error);

    QVERIFY2(loadedMetadata.has_value(), qPrintable(error));

    const QStringList expectedArtists{
        QStringLiteral("Artist One"),
        QStringLiteral("Artist Two")
    };

    QCOMPARE(
        loadedMetadata->values(QStringLiteral("ARTIST")),
        expectedArtists
    );
}

QTEST_GUILESS_MAIN(TagLibMetadataBackendTest)

#include "tst_taglibmetadatabackend.moc"
