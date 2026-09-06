import "components"
import "utils"

import QtQuick

Row {
    id: rightSection
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 6
    spacing: 6

    property var barWindow

    // Wifi / volume / battery cluster, opens the unified Control Center menu
    BarRect {
        id: controlRect
        onClicked: controlCenter.toggle()

        ControlCenter {
            id: controlCenter
            barWindow: rightSection.barWindow
            anchorItem: controlRect
        }
    }

    // Todo list
    BarRect {
        id: todoRect
        onClicked: todoList.toggle()

        TodoList {
            id: todoList
            barWindow: rightSection.barWindow
            anchorItem: todoRect
        }
    }
}
