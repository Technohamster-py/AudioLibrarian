#pragma once

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

class FileDialogController : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit FileDialogController(QObject *parent = nullptr);

    Q_INVOKABLE QString getExistingDirectory(const QString& title, const QString& initialDialog = {});
};
