import "../utils"
import "../popups"

import QtQuick

BarText {
    id: root
    text: "\uf40e"

    property var barWindow
    property var anchorItem: root

    function toggle() {
        trayList.visible = !trayList.visible;
    }

    TrayList {
        id: trayList
        anchor.window: root.barWindow
        anchor.item: root.anchorItem
    }
}
