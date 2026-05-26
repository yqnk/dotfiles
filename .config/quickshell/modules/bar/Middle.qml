import "components"
import "utils"

import QtQuick

Row {
    id: midSection
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4

    BarRect {
        onClicked: {
            console.log("left");
        }
        Clock {}
    }
}
