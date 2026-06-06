import QtQuick
import Quickshell.Services.Pipewire

import "../utils"

Row {
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

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
        text: parent.volumeIcon()
    }
}
