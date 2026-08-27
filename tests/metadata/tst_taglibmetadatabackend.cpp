#include <QtTest>

#include "../../src/metadata/audiometadata.h"
#include "../../src/metadata/taglibmetadatabackend.h"

#include <QDataStream>
#include <QFile>
#include <QTemporaryDir>

/**
 * @brief Unit tests for TagLibMetadataBackend.
 */
class TagLibMetadataBackendTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies handling of a nonexistent file.
     */
    void readInvalidFile();

    /**
     * @brief Verifies a basic metadata read/write round-trip.
     */
    void readWriteRoundTrip();

    /**
     * @brief Verifies preservation of multiple values.
     */
    void multipleValues();

    /**
     * @brief Verifies Unicode metadata.
     */
    void unicodeValues();

    /**
     * @brief Verifies arbitrary metadata fields.
     */
    void arbitraryTags();
};

/**
 * @brief Creates a minimal PCM WAV file for metadata tests.
 *
 * @param filePath Destination file path.
 * @return true if the file was successfully created.
 */
static bool createTestWav(const QString &filePath)
{
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly))
        return false;

    constexpr quint32 sampleRate = 44100;
    constexpr quint16 channels = 1;
    constexpr quint16 bitsPerSample = 16;
    constexpr quint32 sampleCount = sampleRate;

    constexpr quint16 blockAlign = channels * (bitsPerSample / 8);

    constexpr quint32 byteRate = sampleRate * blockAlign;

    constexpr quint32 dataSize = sampleCount * blockAlign;

    constexpr quint32 riffSize = 36 + dataSize;

    QDataStream stream(&file);
    stream.setByteOrder(QDataStream::LittleEndian);

    stream.writeRawData("RIFF", 4);
    stream << riffSize;
    stream.writeRawData("WAVE", 4);

    stream.writeRawData("fmt ", 4);
    stream << quint32(16);
    stream << quint16(1);
    stream << channels;
    stream << sampleRate;
    stream << byteRate;
    stream << blockAlign;
    stream << bitsPerSample;

    stream.writeRawData("data", 4);
    stream << dataSize;

    const QByteArray silence(
        static_cast<qsizetype>(dataSize),
        '\0'
    );

    stream.writeRawData(
        silence.constData(),
        silence.size()
    );

    return stream.status() == QDataStream::Ok;
}

void TagLibMetadataBackendTest::readInvalidFile()
{
    const TagLibMetadataBackend backend;

    QString error;

    const auto metadata =
        backend.read(QStringLiteral("/this/file/does/not/exist.mp3"), &error);

    QVERIFY(!metadata.has_value());
    QVERIFY(!error.isEmpty());
}

void TagLibMetadataBackendTest::readWriteRoundTrip()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath = temporaryDirectory.filePath(QStringLiteral("test.wav"));

    QVERIFY(createTestWav(filePath));

    const TagLibMetadataBackend backend;

    AudioMetadata metadata;

    metadata.setTitle(QStringLiteral("Test title"));

    metadata.setArtist(QStringLiteral("Test artist"));

    metadata.setAlbum(QStringLiteral("Test album"));

    metadata.setGenre(
        QStringLiteral("Test genre"));

    metadata.setTrackNumber(
        QStringLiteral("3/12")
    );

    QString error;

    QVERIFY(
        backend.write(
            filePath,
            metadata,
            &error
        )
    );

    QVERIFY2(
        error.isEmpty(),
        qPrintable(error)
    );

    const auto loaded =
        backend.read(
            filePath,
            &error
        );

    QVERIFY2(
        loaded.has_value(),
        qPrintable(error)
    );

    QCOMPARE(
        loaded->title(),
        QStringLiteral("Test title")
    );

    QCOMPARE(
        loaded->artist(),
        QStringLiteral("Test artist")
    );

    QCOMPARE(
        loaded->album(),
        QStringLiteral("Test album")
    );

    QCOMPARE(
        loaded->genre(),
        QStringLiteral("Test genre")
    );

    QCOMPARE(
        loaded->trackNumber(),
        QStringLiteral("3/12")
    );
}

void TagLibMetadataBackendTest::multipleValues()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(
            QStringLiteral("test.wav")
        );

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

    QVERIFY(
        backend.write(
            filePath,
            metadata,
            &error
        )
    );

    const auto loaded =
        backend.read(
            filePath,
            &error
        );

    QVERIFY2(
        loaded.has_value(),
        qPrintable(error)
    );

    QCOMPARE(
        loaded->values(
            QStringLiteral("ARTIST")
        ),
        QStringList{
            QStringLiteral("Artist One"),
            QStringLiteral("Artist Two")
        }
    );
}

void TagLibMetadataBackendTest::unicodeValues()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(
            QStringLiteral("test.wav")
        );

    QVERIFY(createTestWav(filePath));

    const TagLibMetadataBackend backend;

    AudioMetadata metadata;

    metadata.setTitle(
        QStringLiteral("Тестовая композиция")
    );

    metadata.setArtist(
        QStringLiteral("Исполнитель 日本語")
    );

    metadata.setAlbum(
        QStringLiteral("Альбом — 테스트")
    );

    QString error;

    QVERIFY(
        backend.write(
            filePath,
            metadata,
            &error
        )
    );

    const auto loaded =
        backend.read(
            filePath,
            &error
        );

    QVERIFY2(
        loaded.has_value(),
        qPrintable(error)
    );

    QCOMPARE(
        loaded->title(),
        QStringLiteral("Тестовая композиция")
    );

    QCOMPARE(
        loaded->artist(),
        QStringLiteral("Исполнитель 日本語")
    );

    QCOMPARE(
        loaded->album(),
        QStringLiteral("Альбом — 테스트")
    );
}

void TagLibMetadataBackendTest::arbitraryTags()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(
            QStringLiteral("test.wav")
        );

    QVERIFY(createTestWav(filePath));

    const TagLibMetadataBackend backend;

    AudioMetadata metadata;

    metadata.setValues(
        QStringLiteral("CUSTOM_TAG"),
        {
            QStringLiteral("Value")
        }
    );

    QString error;

    QVERIFY(
        backend.write(
            filePath,
            metadata,
            &error
        )
    );

    const auto loaded =
        backend.read(
            filePath,
            &error
        );

    QVERIFY2(
        loaded.has_value(),
        qPrintable(error)
    );

    QCOMPARE(
        loaded->values(
            QStringLiteral("CUSTOM_TAG")
        ),
        QStringList{
            QStringLiteral("Value")
        }
    );
}

QTEST_GUILESS_MAIN(TagLibMetadataBackendTest)

#include "tst_taglibmetadatabackend.moc"