import QtQuick

// Foldable content: size along `orientation` animates 0 <-> natural
// content size, clipped so folded content stays invisible without
// unloading it. Driven by external `expanded` binding — parent decides
// hover vs click. Put a single Row (horizontal) or Column (vertical) as
// the content.
Item {
    id: root

    default property alias content: contentItem.data
    property bool expanded: false
    property int duration: 180
    property string orientation: "vertical" // "vertical" | "horizontal"

    implicitWidth: orientation === "horizontal" ? (expanded ? contentItem.childrenRect.width : 0) : contentItem.childrenRect.width
    implicitHeight: orientation === "vertical" ? (expanded ? contentItem.childrenRect.height : 0) : contentItem.childrenRect.height
    width: implicitWidth
    height: implicitHeight
    clip: true

    Behavior on implicitWidth {
        NumberAnimation { duration: root.duration; easing.type: Easing.OutQuad }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: root.duration; easing.type: Easing.OutQuad }
    }

    Item {
        id: contentItem
        width: childrenRect.width
        height: childrenRect.height
    }
}
