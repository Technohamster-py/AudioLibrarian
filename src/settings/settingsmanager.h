#pragma once

#include <QObject>
#include <QSettings>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

#include "settingsstruct.h"

class SettingsManager : public QObject{
    Q_OBJECT

    QML_ELEMENT
    QML_SINGLETON

    /**
     * @brief Persisted application window width.
     */
    Q_PROPERTY(int windowWidth
               READ windowWidth
               NOTIFY windowWidthChanged)

    /**
     * @brief Persisted application window height.
     */
    Q_PROPERTY(int windowHeight
               READ windowHeight
               NOTIFY windowHeightChanged)

    /**
     * @brief Persisted application window X position.
     */
    Q_PROPERTY(int windowX
               READ windowX
               NOTIFY windowXChanged)

    /**
     * @brief Persisted application window Y position.
     */
    Q_PROPERTY(int windowY
               READ windowY
               NOTIFY windowYChanged)

    /**
     * @brief Persisted width of the navigation/workspace pane.
     */
    Q_PROPERTY(double navigationWidth
               READ navigationWidth
               NOTIFY navigationWidthChanged)

    /**
     * @brief Persisted top-level navigation section.
     *
     * The section is stored by name rather than by numeric index so that
     * adding or reordering navigation items does not invalidate saved state.
     */
    Q_PROPERTY(QString activeSection
               READ activeSection
               NOTIFY activeSectionChanged)

    /**
     * @brief Currently selected application language.
     */
    Q_PROPERTY(QString language
               READ language
               NOTIFY languageChanged)

    /**
     * @brief Currently selected application theme.
     */
    Q_PROPERTY(QString theme
               READ theme
               NOTIFY themeChanged)

    /**
     * @brief Default directory used as the root of the music library.
     */
    Q_PROPERTY(QString baseDir
               READ baseDir
               NOTIFY baseDirChanged)
public:
    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager() = default;

    int windowWidth() const;
    int windowHeight() const;
    int windowX() const;
    int windowY() const;
    double navigationWidth() const;
    QString activeSection() const;

    QString language() const;
    Q_INVOKABLE void setLanguage(const QString &value);

    QString theme() const;
    Q_INVOKABLE void setTheme(const QString &value);

    QString baseDir() const;
    Q_INVOKABLE void setBaseDir(const QString &value);

    /**
     * @brief Persists the current application state.
     *
     * This method is intended to be called when the main window is closed.
     *
     * @param windowWidth Current main window width.
     * @param windowHeight Current main window height.
     * @param windowX Current main window X position.
     * @param windowY Current main window Y position.
     * @param navigationWidth
     * @param navigationWidth
     * @param activeSection Currently selected navigation section.
     */
    Q_INVOKABLE void saveApplicationState(
        int windowWidth,
        int windowHeight,
        int windowX,
        int windowY,
        double navigationWidth, const QString &activeSection);

signals:
    void windowWidthChanged(int value);
    void windowHeightChanged(int value);
    void windowXChanged(int value);
    void windowYChanged(int value);
    void navigationWidthChanged(double value);
    void activeSectionChanged(QString value);
    void languageChanged(const QString &value);
    void themeChanged(const QString &value);
    void baseDirChanged(const QString &value);

private:
    SettingsManager(const SettingsManager &) = delete;
    SettingsManager &operator=(const SettingsManager &) = delete;

    QSettings m_settings;
    const Settings m_settingsStruct;

    int m_windowWidth;
    int m_windowHeight;
    int m_windowX;
    int m_windowY;
    double m_navigationWidth;
    QString m_activeSection;
    QString m_language;
    QString m_theme;
    QString m_baseDir;
};
