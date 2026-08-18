import "../bar/utils"
import "../../utils"

import Quickshell.Services.Pipewire
import QtQuick

OsdWindow {
    id: root

    readonly property int sideMargin: 16
    readonly property int sliderGap: 8

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false
    property bool ready: false

    function volumeIcon(): string {
        if (muted)
            return "";
        if (volume === 0)
            return "-";
        if (volume < 0.33)
            return "";
        if (volume < 0.66)
            return "";
        return "";
    }

    onVolumeChanged: {
        if (root.ready)
            root.pulse();
    }
    onMutedChanged: {
        if (root.ready)
            root.pulse();
    }

    Component.onCompleted: {
        // Skip the pulse caused by the initial property binding resolving.
        root.ready = true;
    }

    BarText {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: root.sideMargin
        anchors.verticalCenter: parent.verticalCenter
        text: root.volumeIcon()
    }

    BarText {
        id: pctText
        width: 44
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        anchors.verticalCenter: parent.verticalCenter
        text: root.muted ? "muted" : Math.round(root.volume * 100) + "%"
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
            width: parent.width * Math.min(root.volume, 1)
            height: parent.height
            radius: 2
            color: root.muted ? Colors.withAlpha("#ffffff", 0.3) : "#ffffff"
        }
    }
}
