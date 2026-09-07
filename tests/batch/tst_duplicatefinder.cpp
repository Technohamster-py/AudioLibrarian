#include <QtTest>

#include "../../src/batch/duplicates/duplicatefinder.h"

#include <QFile>
#include <QTemporaryDir>

class DuplicateFinderTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies that different files with different sizes are ignored.
     */
    void differentSizes();

    /**
     * @brief Verifies that equal-sized but different files are not duplicates.
     */
    void sameSizeDifferentContent();

    /**
     * @brief Verifies detection of two identical files.
     */
    void identicalFiles();

    /**
     * @brief Verifies detection of multiple independent duplicate groups.
     */
    void multipleGroups();
};

void DuplicateFinderTest::differentSizes()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    const QString firstPath =
        directory.filePath(QStringLiteral("first.bin"));

    const QString secondPath =
        directory.filePath(QStringLiteral("second.bin"));

    {
        QFile file(firstPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(
            file.write(QByteArray(10, 'A')),
            10
        );
    }

    {
        QFile file(secondPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(
            file.write(QByteArray(20, 'A')),
            20
        );
    }

    AudioFileRecord first;
    first.filePath = firstPath;

    AudioFileRecord second;
    second.filePath = secondPath;

    DuplicateFinder finder;

    const std::atomic_bool cancellation = false;

    const BatchOperationResult result =
        finder.execute(
            {first, second},
            cancellation
        );

    QVERIFY(result.success);
    QVERIFY(!result.canceled);
    QVERIFY(finder.result().groups.isEmpty());
}

void DuplicateFinderTest::sameSizeDifferentContent()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    const QString firstPath =
        directory.filePath(QStringLiteral("first.bin"));

    const QString secondPath =
        directory.filePath(QStringLiteral("second.bin"));

    {
        QFile file(firstPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(
            file.write(QByteArrayLiteral("AAAA")),
            4
        );
    }

    {
        QFile file(secondPath);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(
            file.write(QByteArrayLiteral("BBBB")),
            4
        );
    }

    AudioFileRecord first;
    first.filePath = firstPath;

    AudioFileRecord second;
    second.filePath = secondPath;

    DuplicateFinder finder;

    const std::atomic_bool cancellation = false;

    const BatchOperationResult result =
        finder.execute(
            {first, second},
            cancellation
        );

    QVERIFY(result.success);
    QVERIFY(finder.result().groups.isEmpty());
}

void DuplicateFinderTest::identicalFiles()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    const QByteArray data =
        QByteArrayLiteral("identical audio data");

    const QString firstPath =
        directory.filePath(QStringLiteral("first.bin"));

    const QString secondPath =
        directory.filePath(QStringLiteral("second.bin"));

    for (const QString &path : {firstPath, secondPath}) {
        QFile file(path);

        QVERIFY(file.open(QIODevice::WriteOnly));
        QCOMPARE(file.write(data), data.size());
    }

    AudioFileRecord first;
    first.filePath = firstPath;

    AudioFileRecord second;
    second.filePath = secondPath;

    DuplicateFinder finder;

    const std::atomic_bool cancellation = false;

    const BatchOperationResult result =
        finder.execute(
            {first, second},
            cancellation
        );

    QVERIFY(result.success);

    QCOMPARE(finder.result().groups.size(), 1);
    QCOMPARE(finder.result().groups.first().files.size(), 2);
    QCOMPARE(finder.result().duplicateFileCount(), 2);
    QCOMPARE(finder.result().removableFileCount(), 1);

    QCOMPARE(
        finder.result().groups.first().files.at(0).hash,
        finder.result().groups.first().files.at(1).hash
    );
}

void DuplicateFinderTest::multipleGroups()
{
    QTemporaryDir directory;

    QVERIFY(directory.isValid());

    const QList<QPair<QString, QString>> pairs{
        {
            QStringLiteral("a1.bin"),
            QStringLiteral("a2.bin")
        },
        {
            QStringLiteral("b1.bin"),
            QStringLiteral("b2.bin")
        }
    };

    const QList<QByteArray> contents{
        QByteArrayLiteral("group A"),
        QByteArrayLiteral("group B")
    };

    QVector<AudioFileRecord> files;

    for (qsizetype i = 0; i < pairs.size(); ++i) {
        for (const QString &name : {
                 pairs.at(i).first,
                 pairs.at(i).second
             }) {
            const QString path =
                directory.filePath(name);

            QFile file(path);

            QVERIFY(file.open(QIODevice::WriteOnly));
            QCOMPARE(
                file.write(contents.at(i)),
                contents.at(i).size()
            );

            AudioFileRecord record;
            record.filePath = path;

            files.append(record);
        }
    }

    DuplicateFinder finder;

    const std::atomic_bool cancellation = false;

    const BatchOperationResult result =
        finder.execute(
            files,
            cancellation
        );

    QVERIFY(result.success);

    QCOMPARE(finder.result().groups.size(), 2);
    QCOMPARE(finder.result().duplicateFileCount(), 4);
    QCOMPARE(finder.result().removableFileCount(), 2);
}

QTEST_GUILESS_MAIN(DuplicateFinderTest)

#include "tst_duplicatefinder.moc"
