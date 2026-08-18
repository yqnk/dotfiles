import "components"
import "../../utils"

import Quickshell
import QtQuick

Variants {
    model: Quickshell.screens
    PanelWindow {
        id: panelWindow
        property var modelData
        screen: modelData

        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 28

        color: Colors.withAlpha("#121220", 0.15)

        Item {
            anchors.fill: parent

            Left {}

            Middle {
                anchors.centerIn: parent
            }

            Right {
                barWindow: panelWindow
            }
        }
    }
}
