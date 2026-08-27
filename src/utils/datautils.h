#pragma once

#include <QByteArray>
#include <QUrl>
#include <QString>

namespace DataUrl {
    QUrl makeDataUrl(const QByteArray &data, const QString &mimeType);
    QUrl makeDataUrl(const QByteArray &data);
}
