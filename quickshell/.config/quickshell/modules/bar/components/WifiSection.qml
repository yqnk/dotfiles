import "../../../utils"
import "../utils"

import Quickshell.Io
import QtQuick

// Wi-Fi block of the control center, styled like a macOS Control Center
// tile: a round accent icon that toggles the radio, the current connection
// underneath the label, and a chevron that folds out the nearby networks.
Column {
    id: root

    property int rowWidth: 260
    property string ssid: ""
    property int strength: 0
    property bool radioOn: true
    property bool expanded: false

    property var networks: []
    property var savedNames: []
    property string attemptSsid: ""
    property string pendingPasswordSsid: ""
    property string errorText: ""

    readonly property color accent: "#3b82f6"

    spacing: 2

    function networkIcon(): string {
        if (!radioOn)
            return "󰤭";
        if (ssid === "")
            return "󰤭";
        if (strength < 25)
            return "󰤟";
        if (strength < 50)
            return "󰤢";
        if (strength < 75)
            return "󰤥";
        return "󰤨";
    }

    function isSaved(name) {
        return savedNames.indexOf(name) !== -1;
    }

    function connectTo(name, secured) {
        errorText = "";
        if (isSaved(name) || !secured) {
            attemptSsid = name;
            connectProc.command = isSaved(name) ? ["nmcli", "connection", "up", "id", name] : ["nmcli", "device", "wifi", "connect", name];
            connectProc.running = true;
        } else {
            pendingPasswordSsid = name;
        }
    }

    function submitPassword(name, pw) {
        if (pw.length === 0)
            return;
        errorText = "";
        attemptSsid = name;
        connectProc.command = ["nmcli", "device", "wifi", "connect", name, "password", pw];
        connectProc.running = true;
    }

    function toggleRadio() {
        radioProc.command = ["nmcli", "radio", "wifi", radioOn ? "off" : "on"];
        radioProc.running = true;
        radioOn = !radioOn;
        if (!radioOn)
            collapse();
    }

    function collapse() {
        expanded = false;
        pendingPasswordSsid = "";
        errorText = "";
    }

    function refresh() {
        stateProc.running = true;
        radioStateProc.running = true;
    }

    onExpandedChanged: {
        if (expanded) {
            errorText = "";
            scanProc.running = true;
            savedProc.running = true;
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: stateProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const parts = line.split(":");
                    if (parts[0] === "yes") {
                        root.ssid = parts[1];
                        root.strength = parseInt(parts[2]) || 0;
                        return;
                    }
                }
                root.ssid = "";
                root.strength = 0;
            }
        }
    }

    Process {
        id: radioStateProc
        command: ["nmcli", "-t", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.radioOn = text.trim() === "enabled"
        }
    }

    Process {
        id: radioProc
        onExited: root.refresh()
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,ACTIVE", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                const list = [];
                for (const line of text.split("\n")) {
                    const parts = line.split(":");
                    const name = parts[0];
                    if (!name || seen[name])
                        continue;
                    seen[name] = true;
                    list.push({
                        ssid: name,
                        signal: parseInt(parts[1]) || 0,
                        secured: (parts[2] || "").length > 0,
                        active: parts[3] === "yes"
                    });
                }
                list.sort((a, b) => b.signal - a.signal);
                root.networks = list;
            }
        }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.savedNames = text.split("\n").filter(n => n.length > 0);
            }
        }
    }

    Process {
        id: connectProc
        onExited: exitCode => {
            if (exitCode !== 0) {
                if (root.pendingPasswordSsid === "")
                    root.pendingPasswordSsid = root.attemptSsid;
                root.errorText = "Connection failed";
            } else {
                root.pendingPasswordSsid = "";
                root.errorText = "";
                scanProc.running = true;
                root.refresh();
            }
            root.attemptSsid = "";
        }
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
                text: root.networkIcon()
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
                text: "Wi-Fi"
            }

            BarText {
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: 10
                color: Colors.withAlpha("#ffffff", 0.55)
                text: !root.radioOn ? "Off" : (root.ssid === "" ? "Not connected" : root.ssid)
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

            Repeater {
                model: root.networks

                delegate: Column {
                    id: netRow
                    required property var modelData
                    width: root.rowWidth
                    spacing: 2

                    Rectangle {
                        width: root.rowWidth
                        implicitHeight: 26
                        radius: 8
                        color: rowArea.containsMouse ? Colors.withAlpha("#ffffff", 0.10) : "transparent"

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
                                width: rowContent.width - 40 - rowContent.spacing * 2
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                font.pixelSize: 11
                                font.bold: netRow.modelData.active
                                text: netRow.modelData.ssid
                            }

                            BarText {
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 10
                                color: Colors.withAlpha("#ffffff", 0.45)
                                text: netRow.modelData.secured ? "" : ""
                            }

                            BarText {
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 11
                                color: netRow.modelData.active ? root.accent : "#ffffff"
                                text: root.attemptSsid === netRow.modelData.ssid ? "…" : (netRow.modelData.active ? "" : "")
                            }
                        }

                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.connectTo(netRow.modelData.ssid, netRow.modelData.secured)
                        }
                    }

                    Rectangle {
                        visible: root.pendingPasswordSsid === netRow.modelData.ssid
                        width: root.rowWidth
                        implicitHeight: 26
                        radius: 8
                        color: Colors.withAlpha("#ffffff", 0.08)

                        TextInput {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 12
                            verticalAlignment: TextInput.AlignVCenter
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.family: "JetBrainsMono Nerd Font"
                            echoMode: TextInput.Password
                            focus: root.pendingPasswordSsid === netRow.modelData.ssid
                            onAccepted: {
                                root.submitPassword(netRow.modelData.ssid, text);
                                text = "";
                            }
                        }
                    }
                }
            }

            BarText {
                visible: root.errorText.length > 0
                width: root.rowWidth
                font.pixelSize: 10
                color: "#f44336"
                text: "   " + root.errorText
            }

            BarText {
                visible: root.networks.length === 0
                width: root.rowWidth
                font.pixelSize: 10
                color: Colors.withAlpha("#ffffff", 0.45)
                text: "   Scanning…"
            }
        }
    }
}
