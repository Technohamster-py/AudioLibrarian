#include "settingsmanager.h"

#include <QStandardPaths>

#include "settingsstruct.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent), m_settings() {
    m_windowWidth = m_settings.value(m_settingsStruct.appState.windowWidth, 1080).toInt();
    m_windowHeight = m_settings.value(m_settingsStruct.appState.windowHeight, 1920).toInt();
    m_windowX = m_settings.value(m_settingsStruct.appState.windowX, 0).toInt();
    m_windowY = m_settings.value(m_settingsStruct.appState.windowY, 0).toInt();

    m_navigationWidth = m_settings.value(m_settingsStruct.appState.navigationWidth, 500.0).toDouble();
    m_activeSection = m_settings.value(m_settingsStruct.appState.activeSection, QStringLiteral("files")).toString();

    m_language = m_settings.value(m_settingsStruct.general.language.key,QStringLiteral("system")).toString();

    m_theme = m_settings.value(m_settingsStruct.general.theme.key,QStringLiteral("dark")).toString();

    m_baseDir = m_settings.value(m_settingsStruct.general.baseDir.key, QStandardPaths::writableLocation(QStandardPaths::MusicLocation)).toString();
}

/**
 * @brief Returns the current window width.
 */
int SettingsManager::windowWidth() const
{
    return m_windowWidth;
}

/**
 * @brief Returns the current window height.
 */
int SettingsManager::windowHeight() const
{
    return m_windowHeight;
}

/**
 * @brief Returns the current window X position.
 */
int SettingsManager::windowX() const
{
    return m_windowX;
}

/**
 * @brief Returns the current window Y position.
 */
int SettingsManager::windowY() const
{
    return m_windowY;
}

/**
 * @brief Returns the current navigation/workspace width.
 */
double SettingsManager::navigationWidth() const
{
    return m_navigationWidth;
}

/**
 * @brief Returns the current navigation section.
 */
QString SettingsManager::activeSection() const
{
    return m_activeSection;
}

/**
 * @brief Returns the selected application language.
 */
QString SettingsManager::language() const
{
    return m_language;
}

/**
 * @brief Updates and persists the application language.
 */
void SettingsManager::setLanguage(const QString &value)
{
    if (m_language == value)
        return;

    m_language = value;

    m_settings.setValue(
        m_settingsStruct.general.language.key,
        value
    );

    emit languageChanged(m_language);
}

QString SettingsManager::theme() const
{
    return m_theme;
}

void SettingsManager::setTheme(const QString &value)
{
    if (m_theme == value)
        return;

    m_theme = value;

    m_settings.setValue(m_settingsStruct.general.theme.key,value);

    emit themeChanged(m_theme);
}

QString SettingsManager::baseDir() const
{
    return m_baseDir;
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
