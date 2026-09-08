import QtQuick

import "../../../utils"
import "../components"
import "../utils"

// Tracker panel: what's running now, a field to start something, your recent
// tasks one click away, and where today actually went.
TrayPopup {
    id: root

    radius: 12
    readonly property int rowWidth: 260
    readonly property int maxRecent: 6

    // Task id currently being renamed inline, "" when none.
    property string editingId: ""

    // Small glyph button used for the per-row pin / rename / delete actions.
    component RowAction: Item {
        id: rowAction

        property string glyph: ""
        property bool active: false
        property color activeColor: "#ffffff"
        property color hoverColor: "#ffffff"
        readonly property alias hovered: actionArea.containsMouse

        signal activated

        width: 13
        height: 13

        BarText {
            anchors.centerIn: parent
            font.pixelSize: 10
            text: rowAction.glyph
            color: actionArea.containsMouse ? rowAction.hoverColor : rowAction.active ? rowAction.activeColor : Colors.withAlpha("#ffffff", 0.4)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: actionArea
            anchors.fill: parent
            anchors.margins: -3
            hoverEnabled: true
            onClicked: rowAction.activated()
        }
    }

    // Compact labelled button for the away prompt.
    component PillButton: Rectangle {
        id: pillButton

        property string label: ""
        property color accent: "#ffffff"

        signal activated

        implicitWidth: pillLabel.implicitWidth + 16
        implicitHeight: 20
        radius: 10
        color: pillArea.containsMouse ? Colors.withAlpha(pillButton.accent, 0.28) : Colors.withAlpha("#ffffff", 0.1)

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        BarText {
            id: pillLabel
            anchors.centerIn: parent
            font.pixelSize: 11
            text: pillButton.label
        }

        MouseArea {
            id: pillArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: pillButton.activated()
        }
    }

    onVisibleChanged: {
        editingId = "";
        if (visible)
            addField.forceActiveFocus();
        else
            addField.text = "";
    }

    Column {
        spacing: 6
        opacity: root.visible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }

        // ---- header --------------------------------------------------------
        Item {
            width: root.rowWidth
            implicitHeight: 18

            BarText {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true
                text: "Tracker"
            }

            BarText {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 11
                color: Colors.withAlpha("#ffffff", 0.45)
                text: "today " + Tracker.fmtShort(Tracker.todayMs) + " · week " + Tracker.fmtShort(Tracker.weekMs)
            }
        }

        Rectangle {
            width: root.rowWidth
            height: 1
            color: Colors.withAlpha("#ffffff", 0.08)
        }

        // ---- away prompt ---------------------------------------------------
        Rectangle {
            visible: Tracker.awayPending
            width: root.rowWidth
            implicitHeight: 40
            radius: 9
            color: Colors.withAlpha("#f59e0b", 0.14)
            border.width: 0.5
            border.color: Colors.withAlpha("#f59e0b", 0.35)

            Row {
                id: awayButtons
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                PillButton {
                    label: "Discard"
                    accent: "#f59e0b"
                    onActivated: Tracker.discardAway()
                }

                PillButton {
                    label: "Keep"
                    onActivated: Tracker.keepAway()
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: awayButtons.left
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    color: "#f59e0b"
                    text: "Away " + Tracker.fmtShort(Tracker.awayMs)
                }

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: 10
                    color: Colors.withAlpha("#ffffff", 0.45)
                    text: "counted while idle"
                }
            }
        }

        // ---- running card --------------------------------------------------
        Rectangle {
            visible: Tracker.isRunning
            width: root.rowWidth
            implicitHeight: 46
            radius: 10
            color: Colors.withAlpha("#4caf50", 0.13)
            border.width: 0.5
            border.color: Colors.withAlpha("#4caf50", 0.3)

            // Anchored rather than laid out in a Row: the elapsed clock and the
            // stop button claim their space from the right edge first, so a long
            // task name elides instead of pushing them out of the card.
            Rectangle {
                id: liveDot
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 7
                height: 7
                radius: 3.5
                color: Tracker.running.project ? Tracker.colorFor(Tracker.running.project) : "#4caf50"

                SequentialAnimation on opacity {
                    running: Tracker.isRunning && root.visible
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: 0.25
                        duration: 900
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 1
                        duration: 900
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Rectangle {
                id: stopButton
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                radius: 11
                color: stopArea.containsMouse ? Colors.withAlpha("#f44336", 0.3) : Colors.withAlpha("#ffffff", 0.1)

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                BarText {
                    anchors.centerIn: parent
                    font.pixelSize: 9
                    text: ""
                }

                MouseArea {
                    id: stopArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Tracker.stop()
                }
            }

            BarText {
                id: elapsedText
                anchors.right: stopButton.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 13
                text: Tracker.fmtClock(Tracker.elapsedMs)
            }

            Column {
                anchors.left: liveDot.right
                anchors.right: elapsedText.left
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    text: Tracker.running.name || ""
                }

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    font.pixelSize: 10
                    color: Colors.withAlpha("#ffffff", 0.45)
                    text: Tracker.running.project ? Tracker.running.project : "no project"
                }
            }
        }

        // ---- start field ---------------------------------------------------
        Rectangle {
            width: root.rowWidth
            implicitHeight: 28
            radius: 8
            color: Colors.withAlpha("#ffffff", addField.activeFocus ? 0.12 : 0.07)
            border.width: 1
            border.color: addField.activeFocus ? Colors.withAlpha("#ffffff", 0.22) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            BarText {
                anchors.left: parent.left
                anchors.leftMargin: 9
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.withAlpha("#ffffff", 0.45)
                text: ""
            }

            TextInput {
                id: addField
                anchors.fill: parent
                anchors.leftMargin: 26
                anchors.rightMargin: 9
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                color: "#ffffff"
                selectionColor: Colors.withAlpha("#ffffff", 0.25)
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: addField.text.length === 0
                    color: Colors.withAlpha("#ffffff", 0.35)
                    font: addField.font
                    text: "What are you working on? @project"
                }

                onAccepted: {
                    Tracker.startFromInput(text);
                    text = "";
                }
            }
        }

        // ---- recent tasks --------------------------------------------------
        Repeater {
            model: Tracker.recentTasks.slice(0, root.maxRecent)

            delegate: Rectangle {
                id: taskRow
                required property var modelData

                readonly property bool isCurrent: Tracker.isRunning && Tracker.running.taskId === modelData.id
                readonly property bool editing: root.editingId === modelData.id
                readonly property bool actionsShown: rowArea.containsMouse || pinAction.hovered || editAction.hovered || delAction.hovered

                width: root.rowWidth
                implicitHeight: 28
                radius: 8
                color: actionsShown || editing ? Colors.withAlpha("#ffffff", 0.1) : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !taskRow.editing
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    // Left: (re)start, or stop if it's the one running.
                    // Right: delete the task.
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Tracker.removeTask(taskRow.modelData.id);
                        else if (taskRow.isCurrent)
                            Tracker.stop();
                        else
                            Tracker.resume(taskRow.modelData.id);
                    }
                }

                // Project colour / running indicator
                Rectangle {
                    id: taskDot
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: taskRow.isCurrent ? "#4caf50" : Tracker.colorFor(taskRow.modelData.project)
                }

                // Hover actions, pinned to the right edge so nothing can push
                // them out of the row.
                Row {
                    id: taskActions
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !taskRow.editing
                    spacing: 6
                    opacity: taskRow.actionsShown ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    RowAction {
                        id: pinAction
                        glyph: ""
                        active: !!taskRow.modelData.pinned
                        activeColor: "#f59e0b"
                        hoverColor: "#f59e0b"
                        onActivated: Tracker.togglePin(taskRow.modelData.id)
                    }

                    RowAction {
                        id: editAction
                        glyph: ""
                        onActivated: root.editingId = taskRow.modelData.id
                    }

                    RowAction {
                        id: delAction
                        glyph: ""
                        hoverColor: "#f44336"
                        onActivated: Tracker.removeTask(taskRow.modelData.id)
                    }
                }

                BarText {
                    id: taskTime
                    anchors.right: taskActions.visible ? taskActions.left : parent.right
                    anchors.rightMargin: taskActions.visible ? 8 : 8
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 11
                    color: Colors.withAlpha("#ffffff", 0.4)
                    text: Tracker.fmtShort(Tracker.taskTodayMs(taskRow.modelData.id))
                }

                BarText {
                    anchors.left: taskDot.right
                    anchors.right: taskTime.left
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !taskRow.editing
                    elide: Text.ElideRight
                    color: taskRow.isCurrent ? "#ffffff" : Colors.withAlpha("#ffffff", 0.85)
                    text: taskRow.modelData.name
                }

                TextInput {
                    id: renameField
                    anchors.left: taskDot.right
                    anchors.right: taskTime.left
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    visible: taskRow.editing
                    clip: true
                    color: "#ffffff"
                    selectionColor: Colors.withAlpha("#ffffff", 0.25)
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"

                    onVisibleChanged: {
                        if (visible) {
                            text = taskRow.modelData.name;
                            forceActiveFocus();
                            selectAll();
                        }
                    }
                    onAccepted: {
                        Tracker.renameTask(taskRow.modelData.id, text);
                        root.editingId = "";
                    }
                    Keys.onEscapePressed: root.editingId = ""
                }
            }
        }

        // ---- empty state ---------------------------------------------------
        Item {
            visible: Tracker.recentTasks.length === 0
            width: root.rowWidth
            implicitHeight: 40

            Column {
                anchors.centerIn: parent
                spacing: 2

                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 15
                    color: Colors.withAlpha("#ffffff", 0.3)
                    text: ""
                }

                BarText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 11
                    color: Colors.withAlpha("#ffffff", 0.4)
                    text: "Type a task above to start the clock"
                }
            }
        }

        // ---- today breakdown -----------------------------------------------
        Rectangle {
            visible: Tracker.todayByProject.length > 0
            width: root.rowWidth
            height: 1
            color: Colors.withAlpha("#ffffff", 0.08)
        }

        // Stacked bar: one segment per project, widths proportional to today.
        Row {
            visible: Tracker.todayByProject.length > 0
            width: root.rowWidth
            height: 5
            spacing: 2

            Repeater {
                model: Tracker.todayByProject

                delegate: Rectangle {
                    required property var modelData
                    height: 5
                    radius: 2.5
                    color: modelData.color
                    width: Math.max(3, (root.rowWidth - 2 * (Tracker.todayByProject.length - 1)) * (modelData.ms / Math.max(1, Tracker.todayMs)))

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Repeater {
            model: Tracker.todayByProject

            delegate: Item {
                required property var modelData
                width: root.rowWidth
                implicitHeight: 18

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: modelData.color
                    }

                    BarText {
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 11
                        color: Colors.withAlpha("#ffffff", 0.6)
                        text: modelData.name || "no project"
                    }
                }

                BarText {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 11
                    color: Colors.withAlpha("#ffffff", 0.6)
                    text: Tracker.fmtShort(modelData.ms)
                }
            }
        }

        // ---- footer ----------------------------------------------------------
        Rectangle {
            visible: Tracker.todayMs > 0
            width: root.rowWidth
            implicitHeight: 22
            radius: 8
            color: clearArea.containsMouse ? Colors.withAlpha("#ffffff", 0.1) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            BarText {
                anchors.centerIn: parent
                font.pixelSize: 11
                color: clearArea.containsMouse ? "#f44336" : Colors.withAlpha("#ffffff", 0.4)
                text: "Clear today"
            }

            MouseArea {
                id: clearArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Tracker.clearToday()
            }
        }
    }
}
