import "../../../utils"
import "../utils"

import QtQuick
import Quickshell.Hyprland

BarText {
    id: root

    property int maxLength: 32

    readonly property string title: Niri.available ? Niri.focusedTitle : (Hyprland.activeToplevel?.title ?? "")

    text: title === "" ? "-" : (title.length > maxLength ? title.substring(0, maxLength - 1) + "…" : title)
}
