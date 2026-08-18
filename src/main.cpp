#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtQml/QQmlExtensionPlugin>

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

    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QQmlApplicationEngine engine;

    engine.loadFromModule(
        QStringLiteral("AudioLibrarian"),
        QStringLiteral("Main")
    );

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}