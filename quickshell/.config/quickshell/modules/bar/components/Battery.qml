import "../../../utils"
import "../utils"

import QtQuick
import Quickshell.Services.UPower

Row {
    id: root

    property var battery: UPower.displayDevice
    property real percent: BatteryNotifier.percent
    property bool charging: !(UPower.onBattery)
    property bool low: !charging && percent < 20

    property color fillColor: charging ? "#4caf50" : (low ? "#f44336" : "#ffffff")
    property color outlineColor: low ? "#f44336" : "#ffffff"

    spacing: 4

    // Body, fill and nub as plain Rectangles. This used to be an Image fed by
    // a data: URI SVG rebuilt and re-rasterised at 288x160 on every 1% step.
    Item {
        anchors.verticalCenter: parent.verticalCenter
        width: 18
        height: 10

        Rectangle {
            id: body
            width: 16
            height: parent.height
            radius: 2.5
            color: "transparent"
            border.width: 1
            border.color: Colors.withAlpha(root.outlineColor, 0.6)

            Rectangle {
                x: 1.3
                y: 1.3
                width: (body.width - 2.6) * Math.max(0, Math.min(100, root.percent)) / 100
                height: body.height - 2.6
                radius: 1.3
                color: root.fillColor

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Rectangle {
            anchors.left: body.right
            anchors.leftMargin: 0.4
            anchors.verticalCenter: body.verticalCenter
            width: 1.6
            height: 3
            radius: 0.8
            color: Colors.withAlpha(root.outlineColor, 0.6)
        }
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: root.percent + "%"
    }
}
