import "../utils"

import QtQuick
import Quickshell.Services.UPower

Row {
    property var battery: UPower.displayDevice
    property real percent: Math.round(battery?.percentage * 100) ?? 0
    property bool charging: !(UPower.onBattery)

    function batteryIcon(): string {
        if (charging)
            return "\udb80\udc84";

        if (percent < 5)
            return "\udb80\udc8e";
        if (percent < 15)
            return "\udb80\udc7a";
        if (percent < 25)
            return "\udb80\udc7b";
        if (percent < 35)
            return "\udb80\udc7c";
        if (percent < 45)
            return "\udb80\udc7d";
        if (percent < 55)
            return "\udb80\udc7e";
        if (percent < 65)
            return "\udb80\udc7f";
        if (percent < 75)
            return "\udb80\udc80";
        if (percent < 85)
            return "\udb80\udc81";
        if (percent < 95)
            return "\udb80\udc82";

        return "\udb80\udc79";
    }

    BarText {
        text: parent.percent + "% " + parent.batteryIcon()
    }
}
