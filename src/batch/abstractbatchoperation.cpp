#include "abstractbatchoperation.h"

AbstractBatchOperation::AbstractBatchOperation(QObject *parent) {

}

void AbstractBatchOperation::reportProgress(qsizetype current, qsizetype total, const QString &phase, const QString &currentFile) {
    emit progressChanged(current, total, phase, currentFile);
}


