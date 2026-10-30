import "../utils"

import QtQuick
import Quickshell

BarText {
    SystemClock {
        id: clock
        // precision: SystemClock.Seconds
        precision: SystemClock.Minutes
    }
    readonly property string hours: Qt.formatDateTime(clock.date, "hh")
    readonly property string minutes: Qt.formatDateTime(clock.date, "mm")
    readonly property string day: Qt.formatDateTime(clock.date, "dd")
    readonly property string month: Qt.formatDateTime(clock.date, "MM")
    readonly property string year: Qt.formatDateTime(clock.date, "yyyy")

    readonly property string middleSep: " • "

    anchors.centerIn: parent
    text: hours + ":" + minutes + middleSep + day + "/" + month
}
