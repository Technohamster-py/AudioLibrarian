#include "settingsmanager.h"

#include <QStandardPaths>

#include "settingsstruct.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent), m_settings() {
    m_language = m_settings.value(m_settingsStruct.general.language.key,QStringLiteral("system")).toString();
    m_theme = m_settings.value(m_settingsStruct.general.theme.key,QStringLiteral("dark")).toString();
    m_baseDir = m_settings.value(m_settingsStruct.general.baseDir.key, QStandardPaths::writableLocation(QStandardPaths::MusicLocation)).toString();
}

/**
 * @brief Updates and persists the application language.
 */
void SettingsManager::setLanguage(const QString &value)
{
    if (m_language == value)
        return;

    m_language = value;
    m_settings.setValue(m_settingsStruct.general.language.key,value);
    emit languageChanged(m_language);
}

void SettingsManager::setTheme(const QString &value)
{
    if (m_theme == value)
        return;

    m_theme = value;
    m_settings.setValue(m_settingsStruct.general.theme.key,value);
    emit themeChanged(m_theme);
}

void SettingsManager::setBaseDir(const QString &value)
{
    if (m_baseDir == value)
        return;

    m_baseDir = value;
    m_settings.setValue(m_settingsStruct.general.baseDir.key,value);
    emit baseDirChanged(m_baseDir);
}

void SettingsManager::saveApplicationState(int windowWidth, int windowHeight, int windowX, int windowY, double navigationWidth, const QString &activeSection) {
    m_settings.setValue(m_settingsStruct.appState.windowWidth, windowWidth);
    m_settings.setValue(m_settingsStruct.appState.windowHeight, windowHeight);
    m_settings.setValue(m_settingsStruct.appState.windowX, windowX);
    m_settings.setValue(m_settingsStruct.appState.windowY, windowY);
    m_settings.setValue(m_settingsStruct.appState.navigationWidth, navigationWidth);
    m_settings.setValue(m_settingsStruct.appState.activeSection, activeSection);

    m_settings.sync();
}
