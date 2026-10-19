#include <QtTest>
#include <QTemporaryDir>
#include <QFile>
#include <QFileInfo>

#include "filerenamer.h"

/**
 * @brief Tests that preview does not modify the filesystem.
 */
class TestFileRenamer : public QObject {
    Q_OBJECT

private slots:
    void previewDoesNotRenameFiles();
};

void TestFileRenamer::previewDoesNotRenameFiles()
{
    QTemporaryDir directory;
    QVERIFY(directory.isValid());

    const QString sourcePath = directory.filePath("original.mp3");
    QFile source(sourcePath);
    QVERIFY(source.open(QIODevice::WriteOnly));
    source.write("test");
    source.close();

    AudioFileRecord file;
    file.filePath = sourcePath;

    FileRenamer renamer("{FILENAME}_new", directory.path());
    QString error;

    const QVariantList preview = renamer.preview({file}, &error);

    QVERIFY2(error.isEmpty(), qPrintable(error));
    QCOMPARE(preview.size(), 1);

    const QVariantMap entry = preview.first().toMap();
    QCOMPARE(entry.value("sourcePath").toString(), QFileInfo(sourcePath).absoluteFilePath());
    QCOMPARE(entry.value("targetPath").toString(), directory.filePath("original_new.mp3"));

    QVERIFY(QFileInfo::exists(sourcePath));
    QVERIFY(!QFileInfo::exists(directory.filePath("original_new.mp3")));
}

QTEST_GUILESS_MAIN(TestFileRenamer)
#include "tst_filerenamer.moc"