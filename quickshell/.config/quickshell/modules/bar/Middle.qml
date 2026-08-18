import "components"
import "utils"

import QtQuick

Row {
    id: midSection
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    // TODO: le calendar LINK AVEC MON GOOGLE CALENDAR ??

    BarRect {
        onClicked: {
            console.log("left");
        }
        Clock {}
    }

    // TODO: mpris ?
}
