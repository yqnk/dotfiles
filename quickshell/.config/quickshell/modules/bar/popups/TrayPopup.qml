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

    // Bottom edge only => popup is centred horizontally under its bar item.
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    // Margins shrink the anchor rect, so a negative bottom margin grows it
    // downwards and leaves a gap between the bar and the popup.
    anchor.margins.bottom: -6

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight

    Rectangle {
        id: background
        implicitWidth: contentColumn.implicitWidth + 12
        implicitHeight: contentColumn.implicitHeight + 12
        width: implicitWidth
        height: implicitHeight

        // Focused so Escape reaches this window; children (e.g. text fields)
        // don't consume the key, so it propagates back up to here.
        focus: true
        Keys.onEscapePressed: root.visible = false

        radius: 10
        color: Colors.withAlpha("#12121a", 0.42)
        border.color: Colors.withAlpha("#ffffff", 0.32)
        border.width: 1.5

        Column {
            id: contentColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 6
            spacing: 2
        }
    }
}
