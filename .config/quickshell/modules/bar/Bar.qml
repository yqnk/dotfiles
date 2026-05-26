import "components"
import "../../utils"

import Quickshell
import QtQuick

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 28
    color: Colors.withAlpha("#000000", 0.35)

    Item {
        anchors.fill: parent

        Left {}

        Middle {
            anchors.centerIn: parent
        }

        Right {}
    }
}
