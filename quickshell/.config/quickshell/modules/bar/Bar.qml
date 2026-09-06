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

        color: Colors.withAlpha("#1c1c28", 0.55)

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
