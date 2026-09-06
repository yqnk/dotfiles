import "../../../utils"

import Quickshell
import QtQuick

PopupWindow {
    id: root

    default property alias content: contentColumn.data
    property alias radius: background.radius

    // Grabs the pointer/keyboard so the compositor sends a dismiss when
    // you click outside.
    grabFocus: true

    visible: false
    color: "transparent"

    anchor.adjustment: PopupAdjustment.Slide | PopupAdjustment.Flip

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight

    Rectangle {
        id: background
        implicitWidth: contentColumn.implicitWidth + 12
        implicitHeight: contentColumn.implicitHeight + 12
        width: implicitWidth
        height: implicitHeight

        radius: 10
        color: Colors.withAlpha("#12121a", 0.42)
        border.color: Colors.withAlpha("#ffffff", 0.10)
        border.width: 0.5

        Column {
            id: contentColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 6
            spacing: 2
        }
    }
}
