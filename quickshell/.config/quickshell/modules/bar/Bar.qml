import "components"
import "../../utils"

import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens
    PanelWindow {
        id: panelWindow
        property var modelData
        screen: modelData

        // Layer surfaces get no keyboard by default, so popups never saw
        // Escape. Take on-demand focus only while a popup is open.
        WlrLayershell.keyboardFocus: PopupState.anyOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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
                barWindow: panelWindow
            }

            Right {
                barWindow: panelWindow
            }
        }
    }
}
