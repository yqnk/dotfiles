import QtQuick
import Quickshell
import Quickshell.Io

import "../../../utils"
import "../utils"
import "../popups"

Row {
    id: root
    spacing: 4

    property var barWindow
    property var anchorItem: root

    property var todos: todoFile.adapter ? todoFile.adapter.todos : []
    readonly property int pendingCount: todos.filter(t => !t.done).length

    function toggle() {
        todoPopup.visible = !todoPopup.visible;
    }

    function persist() {
        todoFile.writeAdapter();
    }

    function addTodo(text) {
        if (text.trim().length === 0)
            return;
        todoFile.adapter.todos = todos.concat([{
            id: Date.now() + "-" + Math.random().toString(36).slice(2),
            text: text.trim(),
            done: false
        }]);
        persist();
    }

    function toggleDone(id) {
        todoFile.adapter.todos = todos.map(t => t.id === id ? Object.assign({}, t, { done: !t.done }) : t);
        persist();
    }

    function remove(id) {
        todoFile.adapter.todos = todos.filter(t => t.id !== id);
        persist();
    }

    function clearCompleted() {
        todoFile.adapter.todos = todos.filter(t => !t.done);
        persist();
    }

    FileView {
        id: todoFile
        path: Quickshell.env("HOME") + "/.config/quickshell/data/todos.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            adapter.todos = [];
        }
        adapter: JsonAdapter {
            property var todos: []
        }
    }

    // Pending count pill
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(16, countText.implicitWidth + 8)
        height: 16
        radius: 8
        clip: true
        color: Colors.withAlpha("#ffffff", 0.16)

        Behavior on width {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        BarText {
            id: countText
            anchors.centerIn: parent
            font.pixelSize: 10
            // Dash when nothing is pending
            text: root.pendingCount > 0 ? root.pendingCount : "–"
            color: root.pendingCount > 0 ? "#ffffff" : Colors.withAlpha("#ffffff", 0.55)
        }
    }

    TodoPopup {
        id: todoPopup
        todoList: root
        anchor.window: root.barWindow
        anchor.item: root.anchorItem
    }
}
