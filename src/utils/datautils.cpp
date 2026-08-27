#include "datautils.h"

#include <QMimeDatabase>
#include <QMimeType>

QUrl DataUrl::makeDataUrl(const QByteArray &data, const QString &mimeType) {
    if (data.isEmpty() || mimeType.isEmpty())
        return {};

    return QUrl(QStringLiteral("data:%1;base64,%2").arg(mimeType).arg(data.toBase64()));
}

QUrl DataUrl::makeDataUrl(const QByteArray &data) {
    if (data.isEmpty())
        return {};

    const QMimeType mimeType = QMimeDatabase().mimeTypeForData(data);

    if (!mimeType.isValid() || mimeType.name().isEmpty())
        return {};

    return makeDataUrl(data, mimeType.name());
}
