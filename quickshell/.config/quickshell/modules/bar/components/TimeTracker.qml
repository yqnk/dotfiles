import QtQuick

import "../../../utils"
import "../utils"
import "../popups"

// Bar readout for the Tracker service. Idle: today's total. Running: live
// elapsed time plus the task name. Sits glued to the right of the clock.
Row {
    id: root
    spacing: 5

    property var barWindow
    property var anchorItem: root

    readonly property bool active: Tracker.isRunning
    readonly property bool longRun: active && Tracker.elapsedMs >= Tracker.longRunMs

    // Accent the enclosing BarRect picks up, so the segment reads as its own
    // thing next to the clock without breaking the bar's palette.
    readonly property color accent: longRun ? "#f59e0b" : active ? "#4caf50" : "#8ab4f8"

    function toggle() {
        popup.visible = !popup.visible;
    }

    // Click the glyph to start/stop without opening the popup.
    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: 11
        height: 12

        BarText {
            anchors.centerIn: parent
            font.pixelSize: 10
            //  stop when running,  play when a previous task can resume,
            //  history when there is nothing to resume yet.
            text: root.active ? "" : Tracker.recentTasks.length > 0 ? "" : ""
            color: root.active ? root.accent : Colors.withAlpha("#ffffff", glyphArea.containsMouse ? 0.9 : 0.5)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: glyphArea
            anchors.fill: parent
            anchors.margins: -3
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton || root.active)
                    Tracker.stop();
                else if (Tracker.recentTasks.length > 0)
                    Tracker.resume(Tracker.recentTasks[0].id);
                else
                    root.toggle();
            }
        }
    }

    // Elapsed time when running, today's total otherwise. Right-aligned in a
    // fixed box so the ticking seconds never shove the clock around.
    Item {
        anchors.verticalCenter: parent.verticalCenter
        // Monospace, so the width only moves when the digit count does (hour
        // rollover), never on every tick.
        width: Math.max(root.active ? 50 : 32, timeText.implicitWidth)
        height: timeText.implicitHeight

        Behavior on width {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        BarText {
            id: timeText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 12
            text: root.active ? Tracker.fmtClock(Tracker.elapsedMs) : Tracker.fmtShort(Tracker.todayMs)
            color: root.active ? "#ffffff" : Colors.withAlpha("#ffffff", 0.6)
        }
    }

    // Task name, only while running.
    FoldSection {
        anchors.verticalCenter: parent.verticalCenter
        orientation: "horizontal"
        expanded: root.active

        Row {
            spacing: 5

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 10
                color: Colors.withAlpha("#ffffff", 0.15)
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                visible: !!Tracker.running.project
                width: 5
                height: 5
                radius: 2.5
                color: Tracker.colorFor(Tracker.running.project)
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 110)
                elide: Text.ElideRight
                font.pixelSize: 12
                color: Colors.withAlpha("#ffffff", 0.85)
                text: Tracker.running.name || ""
            }
        }
    }

    // Away-from-keyboard badge; the popup carries the keep/discard prompt.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        visible: Tracker.awayPending
        width: 12
        height: 12
        radius: 6
        color: Colors.withAlpha("#f59e0b", 0.25)

        BarText {
            anchors.centerIn: parent
            font.pixelSize: 8
            color: "#f59e0b"
            text: ""
        }
    }

    TimeTrackerPopup {
        id: popup
        anchor.window: root.barWindow
        anchor.item: root.anchorItem
    }
}
