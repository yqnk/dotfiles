import "../../utils"

import Quickshell
import QtQuick

PanelWindow {
    id: root

    default property alias content: contentColumn.data
    property int autoHideMs: 1000

    property int boxWidth: 180
    property int boxHeight: 36

    anchors.bottom: true
    margins.bottom: 60
    exclusiveZone: 0
    color: Colors.withAlpha("#000000", 0.35)
    visible: false

    implicitWidth: boxWidth
    implicitHeight: boxHeight

    function pulse() {
        root.visible = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: root.autoHideMs
        onTriggered: root.visible = false
    }

    Rectangle {
        id: background
        anchors.fill: parent

        radius: 4
        color: "transparent"
        border.color: Colors.withAlpha("#ffffff", 0.1)
        border.width: 1

        Item {
            id: contentColumn
            anchors.fill: parent
        }
    }
}
