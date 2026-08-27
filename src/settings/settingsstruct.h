#pragma once

#include <QObject>
#include <QString>

#define ORGANIZATION_NAME "Technohamster"
#define ORGANIZATION_DOMAIN "github.com/Technohamster-py"
#define APPLICATION_NAME "AudioLibrarian"

#define DONATE_URL "https://technohamster.taplink.ws"
#define ISSUES_URL "https://github.com/Technohamster-py/AudioLibrarian/issues"
#define RELEASES_URL "https://github.com/Technohamster-py/AudioLibrarian/releases/latest"
#define VERSION "0.1"
#define SETTINGS_VERSION "2.0"

struct SettingsEntry {
    QString displayName;
    QString key;
};

struct Settings {
    struct AppState {
        QString windowWidth = "state/windowWidth";
        QString windowHeight = "state/windowHeight";
        QString windowX = "state/windowX";
        QString windowY = "state/windowY";

        QString navigationWidth = "state/navigationWidth";
        QString activeSection = "state/activeSection";
    };
    AppState appState; ///< Hidden from user

    struct PlayerState {
        const QString volume = "player/volume";
    };
    PlayerState playerState;

    struct General {
        SettingsEntry language{
            QObject::tr("Language"),
            "common/language"
        };

        SettingsEntry theme{
            QObject::tr("Theme"),
            "common/theme"
        };

        SettingsEntry baseDir{
            QObject::tr("Library default directory"),
            "common/baseDir"
        };
    };
    General general;


};