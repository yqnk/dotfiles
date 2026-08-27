pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell.Services.UPower

QtObject {
    property var battery: UPower.displayDevice
    property real percent: Math.round(battery?.percentage * 100) ?? 0
    property bool charging: !(UPower.onBattery)

    property bool notified20: false
    property bool notified5: false
    property bool notifiedFull: false
    property int chargeLimit: 100

    function notify(summary: string, urgency: string): void {
        notifyProcess.command = ["notify-send", "-u", urgency, "-a", "Battery", summary];
        notifyProcess.running = true;
    }

    property Process notifyProcess: Process {}

    property Process chargeLimitProcess: Process {
        command: ["cat", "/sys/class/power_supply/BAT0/charge_control_end_threshold"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim());
                if (!isNaN(value))
                    chargeLimit = value;
            }
        }
    }

    Component.onCompleted: chargeLimitProcess.running = true

    onChargingChanged: {
        if (charging) {
            notified20 = false;
            notified5 = false;
        } else {
            notifiedFull = false;
        }
    }

    onPercentChanged: {
        if (charging) {
            if (percent >= chargeLimit && !notifiedFull) {
                notifiedFull = true;
                notify("Battery fully charged (" + percent + "%)", "normal");
            }
            return;
        }

        if (percent <= 5) {
            if (!notified5) {
                notified5 = true;
                notify("Battery critically low (" + percent + "%)", "critical");
            }
        } else if (percent > 5) {
            notified5 = false;
        }

        if (percent <= 20) {
            if (!notified20) {
                notified20 = true;
                notify("Battery low (" + percent + "%)", "normal");
            }
        } else if (percent > 20) {
            notified20 = false;
        }
    }
}
