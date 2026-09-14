import "../../../utils"

import Quickshell
import QtQuick
import QtQuick.Window

PopupWindow {
    id: root

    default property alias content: contentColumn.data
    property alias radius: background.radius

    // Close on its own after this long with no pointer over the popup and no
    // text field focused. 0 disables it.
    property int autoCloseMs: 10000

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

    // The bar only becomes keyboard-focusable while a popup is open, which is
    // what lets Escape reach us at all.
    onVisibleChanged: visible ? PopupState.opened() : PopupState.closed()
    Component.onDestruction: if (visible)
        PopupState.closed()

    // Typing in a popup field must not count as "idle", and neither does
    // hovering it. PopupWindow has no activeFocusItem of its own, so it comes
    // from the attached Window object; duck-typed because TextField, TextInput
    // and TextEdit all qualify.
    readonly property bool editing: {
        const it = background.Window.activeFocusItem;
        return !!it && it.cursorPosition !== undefined;
    }

    Timer {
        interval: root.autoCloseMs
        repeat: false
        running: root.visible && root.autoCloseMs > 0 && !hover.hovered && !root.editing
        onTriggered: root.visible = false
    }

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

        // Hovering keeps the popup alive; a HoverHandler doesn't eat clicks
        // the way a MouseArea would.
        HoverHandler {
            id: hover
        }

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
