import "../../../utils"
import "../utils"

import Quickshell.Bluetooth
import QtQuick

// Bluetooth block of the control center, mirroring WifiSection: a round
// accent icon that toggles the adapter, the connected device underneath
// the label, and a chevron that folds out the nearby devices.
Column {
    id: root

    property int rowWidth: 260
    property int maxListHeight: 180
    property bool expanded: false

    readonly property color accent: "#3b82f6"

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool radioOn: adapter?.enabled ?? false

    // Paired first, then connected, then by name — keeps the useful
    // devices pinned above whatever the scan turns up.
    readonly property var devices: {
        const list = (adapter?.devices?.values ?? []).slice();
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return (a.deviceName || a.address).localeCompare(b.deviceName || b.address);
        });
        return list;
    }

    readonly property var connectedDevice: devices.find(d => d.connected) ?? null

    spacing: 2

    function bluetoothIcon(): string {
        if (!radioOn)
            return "󰂲";
        if (connectedDevice)
            return "󰂱";
        return "󰂯";
    }

    function deviceGlyph(dev): string {
        const icon = dev.icon || "";
        if (icon.indexOf("audio-headset") !== -1 || icon.indexOf("headphone") !== -1)
            return "󰋋";
        if (icon.indexOf("audio") !== -1)
            return "󰓃";
        if (icon.indexOf("input-keyboard") !== -1)
            return "󰌌";
        if (icon.indexOf("input-mouse") !== -1)
            return "󰍽";
        if (icon.indexOf("phone") !== -1)
            return "󰄜";
        if (icon.indexOf("computer") !== -1)
            return "󰟀";
        return "󰂯";
    }

    function toggleDevice(dev) {
        if (dev.state === BluetoothDeviceState.Connecting || dev.state === BluetoothDeviceState.Disconnecting)
            return;
        if (dev.connected)
            dev.disconnect();
        else if (dev.paired || dev.bonded)
            dev.connect();
        else
            dev.pair();
    }

    function toggleRadio() {
        if (!adapter)
            return;
        adapter.enabled = !adapter.enabled;
        if (!adapter.enabled)
            collapse();
    }

    function collapse() {
        expanded = false;
        if (adapter && adapter.discovering)
            adapter.discovering = false;
    }

    // Scan only while the fold is open — discovery is expensive and
    // keeps the radio busy.
    onExpandedChanged: {
        if (adapter && radioOn)
            adapter.discovering = expanded;
    }

    // Tile: accent toggle + label + chevron
    Rectangle {
        width: root.rowWidth
        implicitHeight: 44
        radius: 12
        color: tileArea.containsMouse ? Colors.withAlpha("#ffffff", 0.10) : Colors.withAlpha("#ffffff", 0.06)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            id: tileArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (root.radioOn)
                    root.expanded = !root.expanded;
                else
                    root.toggleRadio();
            }
        }

        Rectangle {
            id: iconBubble
            width: 28
            height: 28
            radius: 14
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            color: root.radioOn ? root.accent : Colors.withAlpha("#ffffff", 0.14)

            Behavior on color {
                ColorAnimation { duration: 180 }
            }

            BarText {
                anchors.centerIn: parent
                font.pixelSize: 14
                text: root.bluetoothIcon()
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.toggleRadio()
            }
        }

        Column {
            anchors.left: iconBubble.right
            anchors.leftMargin: 10
            anchors.right: chevron.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            BarText {
                width: parent.width
                elide: Text.ElideRight
                font.bold: true
                text: "Bluetooth"
            }

            BarText {
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: 10
                color: Colors.withAlpha("#ffffff", 0.55)
                text: {
                    if (!root.adapter)
                        return "Unavailable";
                    if (!root.radioOn)
                        return "Off";
                    if (root.connectedDevice)
                        return root.connectedDevice.deviceName || root.connectedDevice.address;
                    return "Not connected";
                }
            }
        }

        BarText {
            id: chevron
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 11
            color: Colors.withAlpha("#ffffff", 0.6)
            rotation: root.expanded ? 180 : 0
            text: "󰅀"

            Behavior on rotation {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }
    }

    FoldSection {
        expanded: root.expanded
        orientation: "vertical"

        Column {
            topPadding: 2
            spacing: 2

            // Scrollable device list: grows with content up to
            // maxListHeight, then scrolls instead of stretching the popup.
            Flickable {
                id: devFlick
                width: root.rowWidth
                height: Math.min(devList.height, root.maxListHeight)
                contentWidth: root.rowWidth
                contentHeight: devList.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 4000
                maximumFlickVelocity: 2000
                interactive: contentHeight > height

                Column {
                    id: devList
                    width: root.rowWidth
                    spacing: 2

                    Repeater {
                        model: root.devices

                        delegate: Rectangle {
                            id: devRow
                            required property var modelData

                            width: root.rowWidth
                            implicitHeight: 26
                            radius: 8
                            color: rowArea.containsMouse ? Colors.withAlpha("#ffffff", 0.10) : "transparent"

                            readonly property bool busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Row {
                                id: rowContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 14
                                anchors.rightMargin: 12
                                spacing: 6

                                BarText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 10
                                    color: Colors.withAlpha("#ffffff", 0.55)
                                    text: root.deviceGlyph(devRow.modelData)
                                }

                                BarText {
                                    width: rowContent.width - 58 - rowContent.spacing * 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    font.pixelSize: 11
                                    font.bold: devRow.modelData.connected
                                    text: devRow.modelData.deviceName || devRow.modelData.address
                                }

                                BarText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 10
                                    color: Colors.withAlpha("#ffffff", 0.45)
                                    text: devRow.modelData.batteryAvailable ? Math.round(devRow.modelData.battery * 100) + "%" : ""
                                }

                                BarText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 11
                                    color: devRow.modelData.connected ? root.accent : "#ffffff"
                                    text: devRow.busy ? "…" : (devRow.modelData.connected ? "" : (devRow.modelData.paired ? "" : ""))
                                }
                            }

                            MouseArea {
                                id: rowArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.toggleDevice(devRow.modelData)
                            }
                        }
                    }
                }

                // Scroll indicator: only while the list overflows.
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    width: 3
                    radius: 1.5
                    color: Colors.withAlpha("#ffffff", 0.25)
                    visible: devFlick.interactive
                    height: devFlick.height * (devFlick.height / devFlick.contentHeight)
                    y: devFlick.contentY + (devFlick.height - height) * devFlick.contentY / Math.max(1, devFlick.contentHeight - devFlick.height)
                }
            }

            BarText {
                visible: root.devices.length === 0
                width: root.rowWidth
                font.pixelSize: 10
                color: Colors.withAlpha("#ffffff", 0.45)
                text: "   Scanning…"
            }
        }
    }
}
