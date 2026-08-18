import "../../../utils"

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

// Floating list of all systray items. Clicking an item opens a small
// context menu with proposals (Quit / Activate / ...).
TrayPopup {
    id: root

    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Right

    readonly property int rowWidth: 160

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: row
            required property var modelData

            width: root.rowWidth
            implicitHeight: rowContent.implicitHeight + 8
            radius: 2
            color: rowArea.containsMouse ? Colors.withAlpha("#ffffff", 0.12) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Row {
                id: rowContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    implicitSize: 14
                    source: row.modelData.icon
                }

                Text {
                    width: rowContent.width - 14 - rowContent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    text: row.modelData.title || row.modelData.id
                }
            }

            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    itemMenu.trayItem = row.modelData;
                    itemMenu.anchor.item = row;
                    itemMenu.visible = true;
                }
            }
        }
    }

    TrayItemMenu {
        id: itemMenu
        anchor.window: root
    }
}
