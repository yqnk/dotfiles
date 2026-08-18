import "../utils"
import "../../../utils"

import Quickshell.Io
import QtQuick

// BarRect-styled box that widens in place on hover (or click, see `mode`)
// to reveal CPU/RAM/Disk usage next to the glyph. No popup — the box
// itself resizes; height stays fixed (bar window is a fixed 28px strip),
// only width animates.
Rectangle {
    id: root

    property string mode: "hover" // "hover" | "click"
    property bool clickExpanded: false
    readonly property bool expanded: mode === "click" ? clickExpanded : hoverArea.containsMouse

    property real cpuPct: 0
    property real ramPct: 0
    property real diskPct: 0

    radius: 2
    color: hoverArea.containsMouse ? Colors.withAlpha("#ffffff", 0.15) : Colors.withAlpha("#ffffff", 0.08)
    border.color: Colors.withAlpha("#ffffff", 0.1)
    border.width: 1

    implicitWidth: rowContent.implicitWidth + 12
    implicitHeight: glyph.implicitHeight + 4
    clip: true

    Behavior on color {
        ColorAnimation { duration: 300 }
    }

    Row {
        id: rowContent
        x: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        BarText {
            id: glyph
            text: ""
        }

        FoldSection {
            id: fold
            orientation: "horizontal"
            expanded: root.expanded

            Row {
                spacing: 6
                opacity: root.expanded ? 1 : 0

                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: root.expanded ? 120 : 0 }
                        NumberAnimation { duration: 100 }
                    }
                }

                BarText {
                    font.pixelSize: 11
                    text: "CPU " + root.cpuPct.toFixed(0) + "%"
                }
                BarText {
                    font.pixelSize: 11
                    text: "RAM " + root.ramPct.toFixed(0) + "%"
                }
                BarText {
                    font.pixelSize: 11
                    text: "DISK " + root.diskPct.toFixed(0) + "%"
                }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (root.mode === "click")
                root.clickExpanded = !root.clickExpanded;
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
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }
}
