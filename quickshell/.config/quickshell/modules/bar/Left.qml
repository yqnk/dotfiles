import "components"
import "utils"

import QtQuick

Row {
    id: leftSection

    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 6
    spacing: 6

    BarRect {
        id: menuBtn
        anchors.verticalCenter: parent.verticalCenter

        Menu {}
    }

    Workspaces {
        screen: modelData
    }

    BarRect {
        FocusedWindow {}
    }
}
