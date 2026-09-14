import "../../../utils"
import "../utils"

import QtQuick
import Quickshell.Hyprland

Rectangle {
    property int vpad: 2
    property int hpad: 4
    property int innerSpacing: 0
    property var screen

    color: Colors.withAlpha("#ffffff", 0.06)
    border.width: 0

    property string unfocusedColor: Colors.withAlpha("#ffffff", 0.2)
    property string focusedColor: Colors.withAlpha("#ffffff", 0.8)
    property string hoveredColor: Colors.withAlpha("#ffffff", 0.5)
    property string urgentColor: "#e06c75"

    implicitWidth: repeaterContainer.width + (2 * hpad)
    implicitHeight: repeaterContainer.height + (2 * vpad)
    radius: 8

    // Compositor-agnostic model: { key, label, focused, urgent } plus the
    // backend-specific handle used when the pill is clicked.
    property var filteredWorkspaces: {
        if (Niri.available) {
            return Niri.workspaces.filter(ws => !screen || ws.output === screen.name).map(ws => ({
                        key: "niri:" + ws.id,
                        // niri workspaces can be named; fall back to the
                        // per-output index, which is what Mod+<n> refers to.
                        label: ws.name ? ws.name : ws.idx,
                        // isActive, not isFocused: each bar highlights the
                        // current workspace of its own monitor.
                        focused: ws.isActive,
                        urgent: ws.isUrgent,
                        niri: ws
                    }));
        }

        return Hyprland.workspaces.values.filter(ws => !screen || ws.monitor?.name === screen.name).map(ws => ({
                    key: "hypr:" + ws.id,
                    label: ws.id < 0 ? "S" : ((ws.id - 1) % 10) + 1,
                    focused: ws.focused,
                    urgent: false,
                    hyprland: ws
                }));
    }

    Row {
        id: repeaterContainer
        anchors.centerIn: parent
        spacing: parent.innerSpacing

        Repeater {
            model: parent.parent.filteredWorkspaces

            delegate: Item {
                required property var modelData

                property bool isHovered: false

                implicitWidth: label.width + 8
                implicitHeight: label.height

                BarText {
                    id: label
                    anchors.centerIn: parent
                    text: parent.modelData.label
                    color: parent.modelData.urgent ? urgentColor : parent.modelData.focused ? focusedColor : parent.isHovered ? hoveredColor : unfocusedColor

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.isHovered = true
                    onExited: parent.isHovered = false
                    onClicked: () => {
                        const ws = parent.modelData;
                        if (ws.niri)
                            Niri.focusWorkspace(ws.niri);
                        else
                            Hyprland.dispatch("workspace " + ws.hyprland.id);
                    }
                }
            }
        }
    }
}
