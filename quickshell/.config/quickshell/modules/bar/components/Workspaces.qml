import "../../../utils"
import "../utils"

import QtQuick
import Quickshell.Hyprland

Rectangle {
    property int vpad: 2
    property int hpad: 4
    property int innerSpacing: 0
    property var screen

    color: Colors.withAlpha("#ffffff", 0.08)
    border.color: Colors.withAlpha("#ffffff", 0.1)
    border.width: 1

    property string unfocusedColor: Colors.withAlpha("#ffffff", 0.2)
    property string focusedColor: Colors.withAlpha("#ffffff", 0.8)
    property string hoveredColor: Colors.withAlpha("#ffffff", 0.5)

    implicitWidth: repeaterContainer.width + (2 * hpad)
    implicitHeight: repeaterContainer.height + (2 * vpad)
    radius: 2

    property var filteredWorkspaces: {
        if (!screen) return Hyprland.workspaces.values;
        return Hyprland.workspaces.values.filter(ws => ws.monitor?.name === screen.name);
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
                    text: parent.modelData.id
                    color: parent.modelData.focused ? focusedColor : parent.isHovered ? hoveredColor : unfocusedColor

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
                        console.log(Hyprland.workspaces.values);
                        Hyprland.dispatch("workspace " + parent.modelData.id);
                    }
                }
            }
        }
    }
}
