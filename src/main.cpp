#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml/QQmlExtensionPlugin>

#include "settings/settingsstruct.h"

Q_IMPORT_QML_PLUGIN(AudioLibrarianPlugin)

/**
 * @brief Application entry point
 *
 * Initializes the Qt application, selects the Basic Qt Quick Controls style,
 * and loads the root QML type from the AudioLibrarian QML module.
 *
 * @param argc Number of command-line arguments
 * @param argv Command-line arguments
 * @return Application exit code
 */
int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral(ORGANIZATION_NAME));
    app.setOrganizationDomain(QStringLiteral(ORGANIZATION_DOMAIN));
    app.setApplicationName(QStringLiteral(APPLICATION_NAME));
    app.setApplicationVersion(QStringLiteral(VERSION));

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QQmlApplicationEngine engine;

    engine.loadFromModule(QStringLiteral("AudioLibrarian"),QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}