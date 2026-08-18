import "../utils"

import QtQuick
import Quickshell.Hyprland

BarText {
    property int maxLength: 16

    function trimTitle(): string {
        var title = Hyprland.activeToplevel?.title;

        if (title.length > maxLength - 3) {
            return title.substring(0, maxLength - 3) + "...";
        }

        return title.substring(0, maxLength - 3);
    }

    text: Hyprland.activeToplevel ? trimTitle() : "-"
}
