import "../../../utils"

import Quickshell
import QtQuick

// Floating todo list. Type in the field to add, click the circle to toggle,
// hover a row to reveal its delete button.
TrayPopup {
    id: root

    property var todoList: null
    readonly property int rowWidth: 240

    readonly property int pendingCount: todoList ? todoList.pendingCount : 0
    readonly property int doneCount: todoList ? todoList.todos.length - pendingCount : 0

    onVisibleChanged: {
        if (visible)
            addField.forceActiveFocus();
        else
            addField.text = "";
    }

    Column {
        spacing: 6

        // Header
        Item {
            width: root.rowWidth
            implicitHeight: 18

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                font.pixelSize: 12
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                text: "Todo"
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.withAlpha("#ffffff", 0.45)
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                text: root.pendingCount > 0 ? root.pendingCount + " left" : "all done"
            }
        }

        Rectangle {
            width: root.rowWidth
            height: 1
            color: Colors.withAlpha("#ffffff", 0.08)
        }

        // Add field
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

            Text {
                id: addGlyph
                anchors.left: parent.left
                anchors.leftMargin: 9
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.withAlpha("#ffffff", 0.45)
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
                text: ""
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
                    text: "Add a task…"
                }

                onAccepted: {
                    root.todoList.addTodo(text);
                    text = "";
                }
            }
        }

        Repeater {
            model: root.todoList ? root.todoList.todos : []

            delegate: Rectangle {
                id: todoRow
                required property var modelData

                width: root.rowWidth
                implicitHeight: 28
                radius: 8
                color: rowArea.containsMouse ? Colors.withAlpha("#ffffff", 0.1) : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.todoList.toggleDone(todoRow.modelData.id)
                }

                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    // Checkbox
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        radius: 7
                        color: todoRow.modelData.done ? "#4caf50" : "transparent"
                        border.width: 1.2
                        border.color: todoRow.modelData.done ? "#4caf50" : Colors.withAlpha("#ffffff", 0.35)

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

                        Text {
                            anchors.centerIn: parent
                            color: "#1c1c28"
                            font.pixelSize: 9
                            font.bold: true
                            font.family: "JetBrainsMono Nerd Font"
                            text: ""
                            opacity: todoRow.modelData.done ? 1 : 0
                            scale: todoRow.modelData.done ? 1 : 0.5

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                    }

                    Text {
                        width: root.rowWidth - 16 - 14 - 14 - 16
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        color: todoRow.modelData.done ? Colors.withAlpha("#ffffff", 0.4) : "#ffffff"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        font.strikeout: todoRow.modelData.done
                        text: todoRow.modelData.text

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    // Delete
                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        opacity: rowArea.containsMouse || delArea.containsMouse ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            color: delArea.containsMouse ? "#f44336" : Colors.withAlpha("#ffffff", 0.45)
                            font.pixelSize: 11
                            font.family: "JetBrainsMono Nerd Font"
                            text: ""

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        MouseArea {
                            id: delArea
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            enabled: rowArea.containsMouse || delArea.containsMouse
                            onClicked: root.todoList.remove(todoRow.modelData.id)
                        }
                    }
                }
            }
        }

        // Empty state
        Item {
            visible: !root.todoList || root.todoList.todos.length === 0
            width: root.rowWidth
            implicitHeight: 44

            Column {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.withAlpha("#ffffff", 0.3)
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                    text: ""
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.withAlpha("#ffffff", 0.4)
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    text: "Nothing to do"
                }
            }
        }

        // Footer
        Rectangle {
            visible: root.doneCount > 0
            width: root.rowWidth
            height: 1
            color: Colors.withAlpha("#ffffff", 0.08)
        }

        Rectangle {
            visible: root.doneCount > 0
            width: root.rowWidth
            implicitHeight: 24
            radius: 8
            color: clearArea.containsMouse ? Colors.withAlpha("#ffffff", 0.1) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                color: clearArea.containsMouse ? "#ffffff" : Colors.withAlpha("#ffffff", 0.45)
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                text: "Clear completed (" + root.doneCount + ")"
            }

            MouseArea {
                id: clearArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.todoList.clearCompleted()
            }
        }
    }
}
