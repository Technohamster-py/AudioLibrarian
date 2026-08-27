#include <QtTest>

#include "../../src/settings/settingsmanager.h"
#include "../../src/settings/settingsstruct.h"

#include <QSettings>
#include <QStandardPaths>

/**
 * @brief Unit tests for SettingsManager.
 *
 * The current implementation uses the application's regular QSettings
 * storage. Tests therefore preserve the original values and restore them
 * after every test.
 */
class SettingsManagerTest final : public QObject
{
    Q_OBJECT

private slots:
    /**
     * @brief Verifies default settings values.
     */
    void defaultValues();

    /**
     * @brief Verifies language persistence and notification.
     */
    void language();

    /**
     * @brief Verifies theme persistence and notification.
     */
    void theme();

    /**
     * @brief Verifies library directory persistence and notification.
     */
    void baseDir();

    /**
     * @brief Verifies application window state persistence.
     */
    void applicationState();

private:
    /**
     * @brief Restores the original QSettings values.
     */
    static void restoreSettings(
        const QMap<QString, QVariant> &values
    );
};

void SettingsManagerTest::restoreSettings(
    const QMap<QString, QVariant> &values
)
{
    QSettings settings;

    for (auto it = values.cbegin(); it != values.cend(); ++it) {
        if (it.value().isValid())
            settings.setValue(it.key(), it.value());
        else
            settings.remove(it.key());
    }

    settings.sync();
}

void SettingsManagerTest::defaultValues()
{
    Settings settingsStruct;
    QSettings settings;

    const QString languageKey =settingsStruct.general.language.key;

    const QString themeKey =settingsStruct.general.theme.key;

    const QString baseDirKey =settingsStruct.general.baseDir.key;

    const QMap<QString, QVariant> oldValues{
        {
            languageKey,
            settings.contains(languageKey)
                ? settings.value(languageKey)
                : QVariant()
        },
        {
            themeKey,
            settings.contains(themeKey)
                ? settings.value(themeKey)
                : QVariant()
        },
        {
            baseDirKey,
            settings.contains(baseDirKey)
                ? settings.value(baseDirKey)
                : QVariant()
        }
    };

    /*
     * Remove the settings so the constructor has to use its defaults.
     */
    settings.remove(languageKey);
    settings.remove(themeKey);
    settings.remove(baseDirKey);
    settings.sync();

    SettingsManager manager;

    QCOMPARE(manager.language(), QStringLiteral("system"));

    QCOMPARE(manager.theme(), QStringLiteral("dark"));

    QCOMPARE(manager.baseDir(), QStandardPaths::writableLocation(QStandardPaths::MusicLocation));

    restoreSettings(oldValues);
}

void SettingsManagerTest::language()
{
    SettingsManager manager;

    const QString original =
        manager.language();

    QSignalSpy spy(&manager, &SettingsManager::languageChanged);

    const QString value = QStringLiteral("test-language");

    manager.setLanguage(value);

    QCOMPARE(manager.language(), value);
    QCOMPARE(spy.count(), 1);

    manager.setLanguage(value);

    QCOMPARE(spy.count(), 1);

    /*
     * Restore the original value so the test does not modify the user's
     * actual application configuration.
     */
    manager.setLanguage(original);
}

void SettingsManagerTest::theme()
{
    SettingsManager manager;

    const QString original = manager.theme();

    QSignalSpy spy(&manager, &SettingsManager::themeChanged);

    const QString value = QStringLiteral("test-theme");

    manager.setTheme(value);

    QCOMPARE(manager.theme(), value);
    QCOMPARE(spy.count(), 1);

    manager.setTheme(value);

    QCOMPARE(spy.count(), 1);

    manager.setTheme(original);
}

void SettingsManagerTest::baseDir()
{
    SettingsManager manager;

    const QString original = manager.baseDir();

    QSignalSpy spy(&manager, &SettingsManager::baseDirChanged);

    const QString value = QStringLiteral("/tmp/audio-librarian-test");

    manager.setBaseDir(value);

    QCOMPARE(manager.baseDir(), value);
    QCOMPARE(spy.count(), 1);

    manager.setBaseDir(value);

    QCOMPARE(spy.count(), 1);

    manager.setBaseDir(original);
}

void SettingsManagerTest::applicationState()
{
    SettingsManager manager;

    manager.saveApplicationState(
        1280,
        720,
        100,
        200,
        600.0,
        QStringLiteral("library")
    );

    QCOMPARE(manager.windowWidth(), 1280);
    QCOMPARE(manager.windowHeight(), 720);
    QCOMPARE(manager.windowX(), 100);
    QCOMPARE(manager.windowY(), 200);

    QCOMPARE(manager.navigationWidth(), 600.0);

    QCOMPARE(manager.activeSection(), QStringLiteral("library"));
}

QTEST_GUILESS_MAIN(SettingsManagerTest)

#include "tst_settingsmanager.moc"