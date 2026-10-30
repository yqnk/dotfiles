import "../../../utils"
import "../utils"
import "../components"

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

// Unified macOS-style Control Center: Wi-Fi and Bluetooth tiles, a card
// holding the volume and brightness pill sliders, and a footer of
// battery / system chips.
TrayPopup {
    id: root

    radius: 14

    readonly property int rowWidth: 260
    readonly property color accent: "#3b82f6"

    property PwNode sink: null

    // Glyph for the bar cluster, kept in sync with the Bluetooth section.
    readonly property string bluetoothGlyph: bluetooth.bluetoothIcon()

    // Volume
    property real localVolume: sink?.audio?.volume ?? 0

    function commitVolume(ratio) {
        const v = Math.max(0, Math.min(1, ratio));
        localVolume = v;
        if (sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = v;
        }
    }

    // System stats
    property real cpuPct: 0
    property real ramPct: 0
    property real diskPct: 0

    property var battery: UPower.displayDevice
    readonly property int batteryPercent: BatteryNotifier.percent
    readonly property bool charging: !UPower.onBattery
    readonly property color batteryColor: charging ? "#4caf50" : (batteryPercent < 20 ? "#f44336" : "#ffffff")

    onVisibleChanged: {
        if (visible) {
            statsProc.running = true;
            Network.refresh();
        } else {
            wifi.collapse();
            bluetooth.collapse();
        }
    }

    Process {
        id: statsProc
        command: ["bash", "-c",
            "read -a c1 < <(grep '^cpu ' /proc/stat); sleep 0.2; read -a c2 < <(grep '^cpu ' /proc/stat); " +
            "i1=${c1[4]}; i2=${c2[4]}; t1=0; t2=0; " +
            "for v in \"${c1[@]:1}\"; do t1=$((t1+v)); done; " +
            "for v in \"${c2[@]:1}\"; do t2=$((t2+v)); done; " +
            "dt=$((t2-t1)); di=$((i2-i1)); " +
            "if [ \"$dt\" -gt 0 ]; then cpu=$((100*(dt-di)/dt)); else cpu=0; fi; " +
            "ram=$(free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'); " +
            "disk=$(df --output=pcent / | tail -1 | tr -d '% '); " +
            "echo \"$cpu $ram $disk\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.trim().split(/\s+/);
                if (parts.length === 3) {
                    root.cpuPct = parseFloat(parts[0]);
                    root.ramPct = parseFloat(parts[1]);
                    root.diskPct = parseFloat(parts[2]);
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        onTriggered: statsProc.running = true
    }

    // Small labelled gauge used by the footer chips.
    component StatChip: Rectangle {
        property string label: ""
        property real pct: 0
        property color barColor: "#ffffff"

        implicitHeight: 30
        radius: 9
        color: Colors.withAlpha("#ffffff", 0.06)

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 7
            anchors.rightMargin: 7
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Row {
                width: parent.width

                BarText {
                    font.pixelSize: 9
                    color: Colors.withAlpha("#ffffff", 0.5)
                    text: label
                }

                BarText {
                    width: parent.width - implicitWidth
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 9
                    color: Colors.withAlpha("#ffffff", 0.75)
                    text: Math.round(pct) + "%"
                }
            }

            Rectangle {
                width: parent.width
                height: 3
                radius: 1.5
                color: Colors.withAlpha("#ffffff", 0.12)

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(pct / 100, 1))
                    height: parent.height
                    radius: parent.radius
                    color: barColor

                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }

    Column {
        spacing: 8
        opacity: root.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        WifiSection {
            id: wifi
            rowWidth: root.rowWidth
        }

        BluetoothSection {
            id: bluetooth
            rowWidth: root.rowWidth
        }

        MediaSection {
            rowWidth: root.rowWidth
            popupVisible: root.visible
        }

        // Sliders card
        Rectangle {
            width: root.rowWidth
            implicitHeight: sliders.implicitHeight + 16
            radius: 12
            color: Colors.withAlpha("#ffffff", 0.06)

            Column {
                id: sliders
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                BarSlider {
                    width: parent.width
                    icon: Glyphs.volume(root.localVolume, root.sink?.audio?.muted ?? false)
                    value: root.sink?.audio?.muted ? 0 : root.localVolume
                    onMoved: ratio => root.commitVolume(ratio)
                    onReleased: root.localVolume = Qt.binding(() => root.sink?.audio?.volume ?? 0)
                }

                BarSlider {
                    width: parent.width
                    icon: ""
                    value: Brightness.pct
                    onMoved: ratio => Brightness.set(ratio)
                }
            }
        }

        // Footer: battery + system chips
        Row {
            width: root.rowWidth
            spacing: 6

            StatChip {
                width: (root.rowWidth - 18) / 4
                label: root.charging ? "CHG" : "BAT"
                pct: root.batteryPercent
                barColor: root.batteryColor
            }

            StatChip {
                width: (root.rowWidth - 18) / 4
                label: "CPU"
                pct: root.cpuPct
                barColor: root.accent
            }

            StatChip {
                width: (root.rowWidth - 18) / 4
                label: "RAM"
                pct: root.ramPct
                barColor: root.accent
            }

            StatChip {
                width: (root.rowWidth - 18) / 4
                label: "DISK"
                pct: root.diskPct
                barColor: root.accent
            }
        }
    }
}
