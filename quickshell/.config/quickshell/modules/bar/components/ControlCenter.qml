import "../../../utils"
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

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: Network.icon
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: controlPopup.bluetoothGlyph
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: Glyphs.volume(root.volume, root.muted)
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
