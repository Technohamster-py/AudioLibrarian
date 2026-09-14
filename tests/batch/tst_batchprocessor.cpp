#include <QtTest>

#include "../../src/batch/batchprocessor.h"
#include "../../src/batch/duplicates/duplicatefinder.h"

#include <QFile>
#include <QSignalSpy>
#include <QTemporaryDir>

class BatchProcessorTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies successful execution of a batch operation.
     */
    void successfulExecution();

    /**
     * @brief Verifies that a running operation can be cancelled.
     */
    void cancellation();
};

void BatchProcessorTest::successfulExecution()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    const QString firstPath =
        directory.filePath(QStringLiteral("first.bin"));

    const QString secondPath =
        directory.filePath(QStringLiteral("second.bin"));

    const QByteArray data =
        QByteArrayLiteral("AudioLibrarian test data");

    {
        QFile file(firstPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(file.write(data), data.size());
    }

    {
        QFile file(secondPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(file.write(data), data.size());
    }

    AudioFileRecord first;
    first.filePath = firstPath;

    AudioFileRecord second;
    second.filePath = secondPath;

    const QVector<AudioFileRecord> files{
        first,
        second
    };

    BatchProcessor processor;

    const auto finder =
        QSharedPointer<DuplicateFinder>::create();

    QSignalSpy finishedSpy(
        &processor,
        &BatchProcessor::finished
    );

    QVERIFY(
        processor.start(
            finder,
            files
        )
    );

    QTRY_COMPARE_WITH_TIMEOUT(
        finishedSpy.count(),
        1,
        5000
    );

    QCOMPARE(
        processor.state(),
        BatchProcessor::State::Finished
    );

    const DuplicateSearchResult &result =
        finder->result();

    QCOMPARE(result.groups.size(), 1);
    QCOMPARE(result.groups.first().files.size(), 2);
    QCOMPARE(result.duplicateFileCount(), 2);
    QCOMPARE(result.removableFileCount(), 1);
}

void BatchProcessorTest::cancellation()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    QVector<AudioFileRecord> files;

    for (int i = 0; i < 10; ++i) {
        const QString filePath =
            directory.filePath(
                QStringLiteral("file_%1.bin").arg(i)
            );

        QFile file(filePath);

        QVERIFY(file.open(QIODevice::WriteOnly));

        const QByteArray data(
            1024 * 1024,
            static_cast<char>('A' + i)
        );

        QCOMPARE(
            file.write(data),
            data.size()
        );

        AudioFileRecord record;
        record.filePath = filePath;

        files.append(record);
    }

    BatchProcessor processor;

    const auto finder =
        QSharedPointer<DuplicateFinder>::create();

    QSignalSpy cancelledSpy(
        &processor,
        &BatchProcessor::cancelled
    );

    QVERIFY(
        processor.start(
            finder,
            files
        )
    );

    processor.cancel();

    QTRY_COMPARE_WITH_TIMEOUT(
        cancelledSpy.count(),
        1,
        5000
    );

    QCOMPARE(
        processor.state(),
        BatchProcessor::State::Cancelled
    );
}

QTEST_GUILESS_MAIN(BatchProcessorTest)

#include "tst_batchprocessor.moc"