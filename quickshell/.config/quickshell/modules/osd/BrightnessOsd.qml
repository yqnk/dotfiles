import "../bar/utils"
import "../../utils"

import QtQuick

OsdWindow {
    id: root

    readonly property int sideMargin: 16
    readonly property int sliderGap: 8

    readonly property real pct: Brightness.pct
    property bool ready: false

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
