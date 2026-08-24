#include "settingsmanager.h"
#include "settingsstruct.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent), m_settings() {
    m_windowWidth = m_settings.value(Settings{}.appState.windowWidth, 1080).toInt();
    m_windowHeight = m_settings.value(Settings{}.appState.windowHeight, 1920).toInt();
    m_windowX = m_settings.value(Settings{}.appState.windowX, 0).toInt();
    m_windowY = m_settings.value(Settings{}.appState.windowY, 0).toInt();

    m_navigationWidth = m_settings.value(Settings{}.appState.navigationWidth, 500.0).toDouble();
    m_activeSection = m_settings.value(Settings{}.appState.activeSection, QStringLiteral("files")).toString();
}

/**
 * @brief Returns the current window width.
 */
int SettingsManager::windowWidth() const
{
    return m_windowWidth;
}

/**
 * @brief Updates and persists the window width.
 */
void SettingsManager::setWindowWidth(const int value)
{
    if (m_windowWidth == value)
        return;

    m_windowWidth = value;

    const Settings settings;
    m_settings.setValue(settings.appState.windowWidth, value);

    emit windowWidthChanged(m_windowWidth);
}

/**
 * @brief Returns the current window height.
 */
int SettingsManager::windowHeight() const
{
    return m_windowHeight;
}

/**
 * @brief Updates and persists the window height.
 */
void SettingsManager::setWindowHeight(const int value)
{
    if (m_windowHeight == value)
        return;

    m_windowHeight = value;

    const Settings settings;
    m_settings.setValue(settings.appState.windowHeight, value);

    emit windowHeightChanged(m_windowHeight);
}

/**
 * @brief Returns the current window X position.
 */
int SettingsManager::windowX() const
{
    return m_windowX;
}

/**
 * @brief Updates and persists the window X position.
 */
void SettingsManager::setWindowX(const int value)
{
    if (m_windowX == value)
        return;

    m_windowX = value;

    const Settings settings;
    m_settings.setValue(settings.appState.windowX, value);

    emit windowXChanged(m_windowX);
}

/**
 * @brief Returns the current window Y position.
 */
int SettingsManager::windowY() const
{
    return m_windowY;
}

/**
 * @brief Updates and persists the window Y position.
 */
void SettingsManager::setWindowY(const int value)
{
    if (m_windowY == value)
        return;

    m_windowY = value;

    const Settings settings;
    m_settings.setValue(settings.appState.windowY, value);

    emit windowYChanged(m_windowY);
}

/**
 * @brief Returns the current navigation/workspace width.
 */
double SettingsManager::navigationWidth() const
{
    return m_navigationWidth;
}

/**
 * @brief Updates and persists the navigation/workspace width.
 */
void SettingsManager::setNavigationWidth(const double value)
{
    if (qFuzzyCompare(m_navigationWidth, value))
        return;

    m_navigationWidth = value;

    const Settings settings;
    m_settings.setValue(settings.appState.navigationWidth, value);

    emit navigationWidthChanged(m_navigationWidth);
}

/**
 * @brief Returns the current navigation section.
 */
QString SettingsManager::activeSection() const
{
    return m_activeSection;
}

/**
 * @brief Updates and persists the active navigation section.
 */
void SettingsManager::setActiveSection(const QString &value)
{
    if (m_activeSection == value)
        return;

    m_activeSection = value;

    m_settings.setValue(m_settingsStruct.appState.activeSection, value);

    emit activeSectionChanged(m_activeSection);
}
