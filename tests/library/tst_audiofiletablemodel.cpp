#include <QtTest>

#include "../../src/library/library/audiofiletablemodel.h"

#include <QAbstractItemModelTester>
#include <QBuffer>
#include <QDataStream>
#include <QDir>
#include <QImage>
#include <QTemporaryDir>

/**
 * @brief Unit tests for AudioFileTableModel.
 *
 * The tests cover the public model contract:
 * - model configuration;
 * - columns and roles;
 * - cover data conversion;
 * - recursive filesystem scanning;
 * - model data;
 * - sorting;
 * - model notifications.
 */
class AudioFileTableModelTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies the default model configuration.
     */
    void defaultConfiguration();

    /**
     * @brief Verifies the number of model columns.
     */
    void columnCount();

    /**
     * @brief Verifies all exported QML roles.
     */
    void roleNames();

    /**
     * @brief Verifies that the model satisfies QAbstractItemModel invariants.
     */
    void modelInvariants();

    /**
     * @brief Verifies conversion of JPEG image data into a data URL.
     */
    void makeCoverUrlJpeg();

    /**
     * @brief Verifies conversion of PNG image data into a data URL.
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
     * @brief Verifies recursive scanning of an audio directory.
     */
    void recursiveScan();

    /**
     * @brief Verifies model loading notifications.
     */
    void loadingSignals();

    /**
     * @brief Verifies reload of the current root directory.
     */
    void reload();

    /**
     * @brief Verifies ascending file-name sorting.
     */
    void sortFileNameAscending();

    /**
     * @brief Verifies descending file-name sorting.
     */
    void sortFileNameDescending();

    /**
     * @brief Verifies data exposed by a scanned file.
     */
    void scannedFileData();

private:
    /**
     * @brief Creates a minimal one-second PCM WAV file.
     *
     * @param filePath Destination file path.
     * @return true if the file was successfully created.
     */
    static bool createTestWav(const QString &filePath);
};

bool AudioFileTableModelTest::createTestWav(
    const QString &filePath
)
{
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

void AudioFileTableModelTest::defaultConfiguration()
{
    const AudioFileTableModel model;

    QVERIFY(model.rootPath().isLocalFile());
    QVERIFY(!model.rootPath().toLocalFile().isEmpty());

    QVERIFY(!model.isLoading());
}

void AudioFileTableModelTest::columnCount()
{
    const AudioFileTableModel model;

    QCOMPARE(
        model.columnCount(),
        AudioFileTableModel::ColumnCount
    );
}

void AudioFileTableModelTest::roleNames()
{
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

void AudioFileTableModelTest::modelInvariants()
{
    AudioFileTableModel model;

    /*
     * QAbstractItemModelTester performs a broad set of structural checks:
     * indexes, parent/child relationships, row counts and model signals.
     */
    QAbstractItemModelTester tester(
        &model,
        QAbstractItemModelTester::FailureReportingMode::QtTest
    );

    Q_UNUSED(tester);

    QCOMPARE(
        model.columnCount(),
        AudioFileTableModel::ColumnCount
    );
}

void AudioFileTableModelTest::makeCoverUrlJpeg()
{
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

    QVERIFY(
        url.startsWith(
            QStringLiteral("data:image/jpeg;base64,")
        )
    );

    QVERIFY(
        url.endsWith(
            QString::fromLatin1(imageData.toBase64())
        )
    );
}

void AudioFileTableModelTest::makeCoverUrlPng()
{
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

    QVERIFY(
        url.startsWith(
            QStringLiteral("data:image/png;base64,")
        )
    );

    QVERIFY(
        url.endsWith(
            QString::fromLatin1(imageData.toBase64())
        )
    );
}

void AudioFileTableModelTest::makeCoverUrlInvalidData()
{
    const AudioFileTableModel model;

    QVERIFY(
        model.makeCoverUrl(
            QByteArrayLiteral("not an image")
        ).isEmpty()
    );
}

void AudioFileTableModelTest::makeCoverUrlEmptyData()
{
    const AudioFileTableModel model;

    QVERIFY(
        model.makeCoverUrl(QByteArray()).isEmpty()
    );
}

void AudioFileTableModelTest::recursiveScan()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString rootPath =
        temporaryDirectory.path();

    const QString nestedPath =
        temporaryDirectory.filePath(
            QStringLiteral("nested")
        );

    QVERIFY(QDir().mkpath(nestedPath));

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

    QCOMPARE(model.rowCount(), 2);
}

void AudioFileTableModelTest::loadingSignals()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("test.wav")
            )
        )
    );

    AudioFileTableModel model;

    QSignalSpy loadingSpy(
        &model,
        &AudioFileTableModel::loadingChanged
    );

    model.setRootPath(
        QUrl::fromLocalFile(
            temporaryDirectory.path()
        )
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QVERIFY(!loadingSpy.isEmpty());
}

void AudioFileTableModelTest::reload()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(
            QStringLiteral("test.wav")
        );

    QVERIFY(createTestWav(filePath));

    AudioFileTableModel model;

    model.setRootPath(
        QUrl::fromLocalFile(
            temporaryDirectory.path()
        )
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QCOMPARE(model.rowCount(), 1);

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("second.wav")
            )
        )
    );

    model.reload();

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QCOMPARE(model.rowCount(), 2);
}

void AudioFileTableModelTest::sortFileNameAscending()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("zulu.wav")
            )
        )
    );

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("alpha.wav")
            )
        )
    );

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("beta.wav")
            )
        )
    );

    AudioFileTableModel model;

    model.setRootPath(
        QUrl::fromLocalFile(
            temporaryDirectory.path()
        )
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QCOMPARE(model.rowCount(), 3);

    model.sort(
        AudioFileTableModel::FileName,
        Qt::AscendingOrder
    );

    QCOMPARE(
        model.data(
            model.index(
                0,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("alpha.wav")
    );

    QCOMPARE(
        model.data(
            model.index(
                1,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("beta.wav")
    );

    QCOMPARE(
        model.data(
            model.index(
                2,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("zulu.wav")
    );
}

void AudioFileTableModelTest::sortFileNameDescending()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("alpha.wav")
            )
        )
    );

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("beta.wav")
            )
        )
    );

    QVERIFY(
        createTestWav(
            temporaryDirectory.filePath(
                QStringLiteral("zulu.wav")
            )
        )
    );

    AudioFileTableModel model;

    model.setRootPath(
        QUrl::fromLocalFile(
            temporaryDirectory.path()
        )
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    model.sort(
        AudioFileTableModel::FileName,
        Qt::DescendingOrder
    );

    QCOMPARE(
        model.data(
            model.index(
                0,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("zulu.wav")
    );

    QCOMPARE(
        model.data(
            model.index(
                1,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("beta.wav")
    );

    QCOMPARE(
        model.data(
            model.index(
                2,
                AudioFileTableModel::FileName
            )
        ).toString(),
        QStringLiteral("alpha.wav")
    );
}

void AudioFileTableModelTest::scannedFileData()
{
    QTemporaryDir temporaryDirectory;

    QVERIFY(temporaryDirectory.isValid());

    const QString filePath =
        temporaryDirectory.filePath(
            QStringLiteral("test.wav")
        );

    QVERIFY(createTestWav(filePath));

    AudioFileTableModel model;

    model.setRootPath(
        QUrl::fromLocalFile(
            temporaryDirectory.path()
        )
    );

    QTRY_VERIFY_WITH_TIMEOUT(
        !model.isLoading(),
        5000
    );

    QCOMPARE(model.rowCount(), 1);

    const QModelIndex index =
        model.index(0, 0);

    QVERIFY(index.isValid());

    QCOMPARE(
        model.data(
            index,
            AudioFileTableModel::FileNameRole
        ).toString(),
        QStringLiteral("test.wav")
    );

    QCOMPARE(
        model.data(
            index,
            AudioFileTableModel::FilePathRole
        ).toString(),
        filePath
    );
}

QTEST_GUILESS_MAIN(AudioFileTableModelTest)

#include "tst_audiofiletablemodel.moc"