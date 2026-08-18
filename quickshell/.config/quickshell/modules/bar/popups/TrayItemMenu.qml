import "../../../utils"

import Quickshell
import Quickshell.Io
import QtQuick

TrayPopup {
    id: root

    property var trayItem: null
    readonly property int rowWidth: 160

    anchor.edges: Edges.Right | Edges.Top
    anchor.gravity: Edges.Left | Edges.Bottom

    QsMenuOpener {
        id: opener
        menu: root.trayItem && root.trayItem.hasMenu ? root.trayItem.menu.menu : null
    }

    function classSelector() {
        return "class:^(" + root.trayItem.id + ")$";
    }

    Process {
        id: openProc
    }

    // pkill -9 in a loop till no matching process left (exit != 0 = gone).
    // Handles multi-process apps (Steam etc.) a single PID kill misses.
    Process {
        id: killLookupProc
        command: ["sh", "-c", "while pkill -9 -if \"" + (root.trayItem ? root.trayItem.id : "") + "\"; do sleep 0.2; done"]
    }

    Rectangle {
        visible: root.trayItem !== null
        width: root.rowWidth
        implicitHeight: openText.implicitHeight + 6
        radius: 2
        color: openArea.containsMouse ? Colors.withAlpha("#ffffff", 0.12) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Text {
            id: openText
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            text: "Open here"
        }

        MouseArea {
            id: openArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                openProc.command = ["hyprctl", "dispatch", "movetoworkspace", "active," + root.classSelector()];
                openProc.running = true;
                root.visible = false;
            }
        }
    }

    Rectangle {
        visible: root.trayItem !== null
        width: root.rowWidth
        implicitHeight: killText.implicitHeight + 6
        radius: 2
        color: killArea.containsMouse ? Colors.withAlpha("#ff5555", 0.25) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Text {
            id: killText
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            text: "Kill"
        }

        MouseArea {
            id: killArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                killLookupProc.running = true;
                root.visible = false;
            }
        }
    }

    Repeater {
        model: root.trayItem && root.trayItem.hasMenu ? opener.children : 0
        delegate: Rectangle {
            id: entryRow
            required property var modelData

            visible: !modelData.isSeparator
            width: root.rowWidth
            implicitHeight: modelData.isSeparator ? 0 : entryText.implicitHeight + 6
            radius: 2
            opacity: entryRow.modelData.enabled ? 1 : 0.4
            color: entryArea.containsMouse ? Colors.withAlpha("#ffffff", 0.12) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                id: entryText
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                color: "#ffffff"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                text: entryRow.modelData.text
            }

            MouseArea {
                id: entryArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: entryRow.modelData.enabled
                onClicked: {
                    entryRow.modelData.sendTriggered();
                    root.visible = false;
                }
            }
        }
    }

    Rectangle {
        visible: root.trayItem !== null && !root.trayItem.hasMenu
        width: root.rowWidth
        implicitHeight: fallbackText.implicitHeight + 6
        radius: 2
        color: fallbackArea.containsMouse ? Colors.withAlpha("#ffffff", 0.12) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Text {
            id: fallbackText
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            text: "Activate"
        }

        MouseArea {
            id: fallbackArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (root.trayItem)
                    root.trayItem.activate();
                root.visible = false;
            }
        }
    }
}
