#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QStyleHints>
#include <QtQml/QQmlExtensionPlugin>

#include "settings/settingsstruct.h"

Q_IMPORT_QML_PLUGIN(AudioLibrarianPlugin)

/**
 * @brief Application entry point
 *
 * Initializes the Qt application, selects the Fluent WinUI 3 controls style,
 * and loads the root QML type from the AudioLibrarian QML module.
 *
 * @param argc Number of command-line arguments
 * @param argv Command-line arguments
 * @return Application exit code
 */
int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    app.setOrganizationName(QStringLiteral(ORGANIZATION_NAME));
    app.setOrganizationDomain(QStringLiteral(ORGANIZATION_DOMAIN));
    app.setApplicationName(QStringLiteral(APPLICATION_NAME));
    app.setApplicationVersion(QStringLiteral(VERSION));

    app.styleHints()->setColorScheme(Qt::ColorScheme::Dark);
    QQuickStyle::setStyle(QStringLiteral("FluentWinUI3"));

    QQmlApplicationEngine engine;

    engine.loadFromModule(QStringLiteral("AudioLibrarian"),QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}