import "../utils"

import QtQuick
import Quickshell.Services.UPower

Row {
    property var battery: UPower.displayDevice
    property real percent: Math.round(battery?.percentage * 100) ?? 0
    property bool charging: !(UPower.onBattery)
    property bool low: !charging && percent < 20

    property color fillColor: charging ? "#4caf50" : (low ? "#f44336" : "#ffffff")
    property color outlineColor: low ? "#f44336" : "#ffffff"

    // inner fill area is 15.2 wide, inset from the outline stroke
    property real fillWidth: Math.max(0, 15.2 * percent / 100)

    function svgSource(): string {
        return "data:image/svg+xml;utf8," +
            "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 5 23 13'>" +
            "<rect x='2' y='6' width='18' height='10' rx='2.5' fill='none' stroke='" + outlineColor + "' stroke-width='1.3' stroke-opacity='0.6'/>" +
            "<rect x='3.4' y='7.3' width='" + fillWidth + "' height='7.4' rx='1.3' fill='" + fillColor + "'/>" +
            "<rect x='20.3' y='9.5' width='1.6' height='3' rx='0.8' fill='" + outlineColor + "' fill-opacity='0.6'/>" +
            "</svg>";
    }

    spacing: 4

    Image {
        anchors.verticalCenter: parent.verticalCenter
        // aspect matches the svg viewBox (23x13) to avoid stretching
        width: 18
        height: 10
        sourceSize.width: 288
        sourceSize.height: 160
        smooth: true
        mipmap: false
        antialiasing: true
        source: parent.svgSource()
    }

    BarText {
        anchors.verticalCenter: parent.verticalCenter
        text: parent.percent + "%"
    }
}
