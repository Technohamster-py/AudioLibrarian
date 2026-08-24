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
               WRITE setWindowWidth
               NOTIFY windowWidthChanged)

    /**
     * @brief Persisted application window height.
     */
    Q_PROPERTY(int windowHeight
               READ windowHeight
               WRITE setWindowHeight
               NOTIFY windowHeightChanged)

    /**
     * @brief Persisted application window X position.
     */
    Q_PROPERTY(int windowX
               READ windowX
               WRITE setWindowX
               NOTIFY windowXChanged)

    /**
     * @brief Persisted application window Y position.
     */
    Q_PROPERTY(int windowY
               READ windowY
               WRITE setWindowY
               NOTIFY windowYChanged)

    /**
     * @brief Persisted width of the navigation/workspace pane.
     */
    Q_PROPERTY(double navigationWidth
               READ navigationWidth
               WRITE setNavigationWidth
               NOTIFY navigationWidthChanged)

    /**
     * @brief Persisted top-level navigation section.
     *
     * The section is stored by name rather than by numeric index so that
     * adding or reordering navigation items does not invalidate saved state.
     */
    Q_PROPERTY(QString activeSection
               READ activeSection
               WRITE setActiveSection
               NOTIFY activeSectionChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);
    ~SettingsManager() = default;

    int windowWidth() const;
    void setWindowWidth(int value);

    int windowHeight() const;
    void setWindowHeight(int value);

    int windowX() const;
    void setWindowX(int value);

    int windowY() const;
    void setWindowY(int value);

    double navigationWidth() const;
    void setNavigationWidth(double value);

    QString activeSection() const;
    void setActiveSection(const QString &value);

signals:
    void windowWidthChanged(int value);
    void windowHeightChanged(int value);
    void windowXChanged(int value);
    void windowYChanged(int value);
    void navigationWidthChanged(double value);
    void activeSectionChanged(QString value);

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
};
