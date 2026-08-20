#include <QtTest>

#include "../../src/library/audiofiletablemodel.h"

#include <QBuffer>
#include <QImage>
#include <QTemporaryDir>
#include <QTemporaryFile>

/**
 * @brief Unit tests for AudioFileTableModel.
 */
class AudioFileTableModelTest final : public QObject {
    Q_OBJECT

private slots:
    /**
     * @brief Verifies the default model configuration.
     */
    void defaultConfiguration();

    /**
     * @brief Verifies that the model exposes all expected columns.
     */
    void columnCount();

    /**
     * @brief Verifies that all expected QML roles are exposed.
     */
    void roleNames();

    /**
     * @brief Verifies conversion of valid JPEG data into a data URL.
     */
    void makeCoverUrlJpeg();

    /**
     * @brief Verifies conversion of valid PNG data into a data URL.
     */
    void makeCoverUrlPng();

    /**
     * @brief Verifies that invalid image data produces an empty URL.
     */
    void makeCoverUrlInvalidData();

    /**
     * @brief Verifies that empty image data produces an empty URL.
     */
    void makeCoverUrlEmptyData();

    /**
     * @brief Verifies recursive scanning of an audio library.
     */
    void recursiveScan();

private:
    /**
     * @brief Creates a minimal PCM WAV file.
     *
     * @param filePath Destination file.
     * @return true when the file was successfully created.
     */
    static bool createTestWav(const QString &filePath);
};

bool AudioFileTableModelTest::createTestWav(
    const QString &filePath
) {
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
     * Audio data chunk containing one second of silence.
     */
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

void AudioFileTableModelTest::defaultConfiguration() {
    const AudioFileTableModel model;

    QVERIFY(model.rootPath().isLocalFile());
    QVERIFY(!model.rootPath().toLocalFile().isEmpty());

    QVERIFY(!model.isLoading());
}

void AudioFileTableModelTest::columnCount() {
    const AudioFileTableModel model;

    QCOMPARE(
        model.columnCount(),
        AudioFileTableModel::ColumnCount
    );
}

void AudioFileTableModelTest::roleNames() {
    const AudioFileTableModel model;

    const auto roles = model.roleNames();

    QCOMPARE(
        roles.value(AudioFileTableModel::FilePathRole),
        QByteArrayLiteral("filePath")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::CoverRole),
        QByteArrayLiteral("cover")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::FileNameRole),
        QByteArrayLiteral("fileName")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::TitleRole),
        QByteArrayLiteral("title")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::ArtistRole),
        QByteArrayLiteral("artist")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::AlbumRole),
        QByteArrayLiteral("album")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::YearRole),
        QByteArrayLiteral("year")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::DurationRole),
        QByteArrayLiteral("duration")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::GenreRole),
        QByteArrayLiteral("genre")
    );

    QCOMPARE(
        roles.value(AudioFileTableModel::HasLyricsRole),
        QByteArrayLiteral("hasLyrics")
    );
}

void AudioFileTableModelTest::makeCoverUrlJpeg() {
    QImage image(
        2,
        2,
        QImage::Format_RGB32
    );

    image.fill(Qt::white);

    QByteArray imageData;

    {
        QBuffer buffer(&imageData);

        QVERIFY(buffer.open(QIODevice::WriteOnly));
        QVERIFY(image.save(&buffer, "JPEG"));
    }

    QVERIFY(!imageData.isEmpty());

    const AudioFileTableModel model;

    const QString url =
        model.makeCoverUrl(imageData);

    QVERIFY2(
        url.startsWith(QStringLiteral("data:image/jpeg;base64,")),
        qPrintable(url)
    );

    const QByteArray encoded =
        imageData.toBase64();

    QVERIFY(
        url.endsWith(
            QString::fromLatin1(encoded)
        )
    );
}

void AudioFileTableModelTest::makeCoverUrlPng() {
    QImage image(
        2,
        2,
        QImage::Format_ARGB32
    );

    image.fill(Qt::transparent);

    QByteArray imageData;

    {
        QBuffer buffer(&imageData);

        QVERIFY(buffer.open(QIODevice::WriteOnly));
        QVERIFY(image.save(&buffer, "PNG"));
    }

    QVERIFY(!imageData.isEmpty());

    const AudioFileTableModel model;

    const QString url =
        model.makeCoverUrl(imageData);

    QVERIFY2(
        url.startsWith(QStringLiteral("data:image/png;base64,")),
        qPrintable(url)
    );

    QVERIFY(
        url.endsWith(
            QString::fromLatin1(imageData.toBase64())
        )
    );
}

void AudioFileTableModelTest::makeCoverUrlInvalidData() {
    const AudioFileTableModel model;

    const QByteArray invalidData(
        "this is not an image"
    );

    QVERIFY(
        model.makeCoverUrl(invalidData).isEmpty()
    );
}

void AudioFileTableModelTest::makeCoverUrlEmptyData() {
    const AudioFileTableModel model;

    QVERIFY(
        model.makeCoverUrl(QByteArray()).isEmpty()
    );
}

void AudioFileTableModelTest::recursiveScan() {
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString rootPath =
        temporaryDirectory.path();

    const QString nestedPath =
        temporaryDirectory.filePath(
            QStringLiteral("nested")
        );

    QVERIFY(
        QDir().mkpath(nestedPath)
    );

    QVERIFY(
        createTestWav(
            QDir(rootPath).filePath(
                QStringLiteral("root.wav")
            )
        )
    );

    QVERIFY(
        createTestWav(
            QDir(nestedPath).filePath(
                QStringLiteral("nested.wav")
            )
        )
    );

    AudioFileTableModel model;

    model.setRootPath(
        QUrl::fromLocalFile(rootPath)
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QCOMPARE(
        model.rowCount(),
        2
    );
}

QTEST_GUILESS_MAIN(AudioFileTableModelTest)

#include "tst_audiofiletablemodel.moc"