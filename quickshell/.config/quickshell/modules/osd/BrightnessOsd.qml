import "../bar/utils"
import "../../utils"

import Quickshell.Io
import QtQuick

OsdWindow {
    id: root

    property string device: "intel_backlight"
    readonly property int sideMargin: 16
    readonly property int sliderGap: 8

    property int current: 0
    property int max: 1
    readonly property real pct: max > 0 ? current / max : 0
    property bool ready: false

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
        onLoaded: root.max = parseInt(text().trim())
    }

    FileView {
        id: curFile
        path: "/sys/class/backlight/" + root.device + "/brightness"
        watchChanges: true
        onLoaded: root.current = parseInt(text().trim())
        onFileChanged: reload()
    }

    onPctChanged: {
        if (root.ready)
            root.pulse();
    }

    Component.onCompleted: {
        root.ready = true;
    }

    BarText {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: root.sideMargin
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf185"
    }

    BarText {
        id: pctText
        width: 44
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.pct * 100) + "%"
    }

    Rectangle {
        height: 4
        radius: 2
        anchors.left: icon.right
        anchors.leftMargin: root.sliderGap
        anchors.right: pctText.left
        anchors.rightMargin: root.sliderGap
        anchors.verticalCenter: parent.verticalCenter
        color: Colors.withAlpha("#ffffff", 0.15)

        Rectangle {
            width: parent.width * Math.min(root.pct, 1)
            height: parent.height
            radius: 2
            color: "#ffffff"
        }
    }
}
