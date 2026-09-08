import "../utils"
import "../popups"

import Quickshell.Services.Pipewire
import QtQuick

// Compact macOS-style status cluster: wifi, bluetooth, volume and battery
// glyphs in a single clickable group that opens one unified Control
// Center menu.
Row {
    id: root
    spacing: 6

    property var barWindow
    property var anchorItem: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    function toggle() {
        controlPopup.visible = !controlPopup.visible;
    }

    function volumeIcon(): string {
        if (muted)
            return "\ueee8";
        if (volume === 0)
            return "\uf026-";
        if (volume < 0.33)
            return "\uf026";
        if (volume < 0.66)
            return "\uf027";
        return "\uf028";
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: controlPopup.wifiGlyph
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: controlPopup.bluetoothGlyph
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: root.volumeIcon()
    }

    Battery {
        anchors.verticalCenter: parent.verticalCenter
    }

    ControlPopup {
        id: controlPopup
        sink: root.sink
        anchor.window: root.barWindow
        anchor.item: root.anchorItem
    }
}
