import "components"
import "utils"

import QtQuick

Row {
    id: rightSection
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 4
    spacing: 4

    property var barWindow

    // Systray
    BarRect {
        id: trayRect
        onClicked: systemTray.toggle()

        SystemTray {
            id: systemTray
            barWindow: rightSection.barWindow
            anchorItem: trayRect
        }
    }

    // CPU / RAM / Disk usage, unfolds on hover
    SystemStats {
        mode: "hover"
    }

    // Color picker
    // BarRect {
    //     onClicked: {
    //         picker.pickColor();
    //     }
    //
    //     ColorPicker {
    //         id: picker
    //     }
    // }

    // Network + Volume + Bluetooth + Mic (?)
    BarRect {
        Network {}
        Volume {}
    }

    // Battery
    BarRect {
        Battery {}
    }

    // Un rect de screenshot avec les 4 types que j'ai dans ma config

}
