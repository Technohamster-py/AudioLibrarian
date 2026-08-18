import QtQuick
import QtQuick.Controls.Basic

/**
 * @brief Main content host.
 *
 * StackView is used here because the content area will eventually contain
 * independent workspaces such as the library, tag editor and duplicate
 * finder. Only the library is part of this first vertical slice.
 */
Item {
    id: root

    property alias currentItem: contentStack.currentItem
    property alias currentIndex: contentStack.currentIndex

    Rectangle {
        anchors.fill: parent
        color: AppColors.background
    }

    StackView {
        id: contentStack

        anchors.fill: parent

        initialItem: LibraryView {}
    }
}