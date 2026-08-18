import QtQuick
import Quickshell.Io

import "../utils"

Row {
    id: root
    spacing: 4

    property string ssid: ""
    property int strength: 0

    function networkIcon(): string {
        if (ssid === "")
            return "󰤭";
        if (strength < 25)
            return "󰤟";
        if (strength < 50)
            return "󰤢";
        if (strength < 75)
            return "󰤥";
        return "󰤨";
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: nmcli.running = true
    }

    Process {
        id: nmcli
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                for (const line of lines) {
                    const parts = line.split(":");
                    if (parts[0] === "yes") {
                        root.ssid = parts[1];
                        root.strength = parseInt(parts[2]) || 0;
                        return;
                    }
                }
                root.ssid = "";
                root.strength = 0;
            }
        }
    }

    BarText {
        text: root.networkIcon()
    }
}
