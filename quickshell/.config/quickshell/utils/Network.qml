pragma Singleton

import QtQuick
import Quickshell.Io

// Wi-Fi state shared by every bar. `nmcli monitor` prints a line whenever
// NetworkManager changes state, so we only query nmcli when something moved
// instead of polling. Singleton so N monitors don't mean N watchers.
QtObject {
    id: root

    property string ssid: ""
    property int strength: 0
    property bool radioOn: true

    readonly property string icon: {
        if (!radioOn || ssid === "")
            return "󰤭";
        if (strength < 25)
            return "󰤟";
        if (strength < 50)
            return "󰤢";
        if (strength < 75)
            return "󰤥";
        return "󰤨";
    }

    // Signal strength isn't reported by the monitor; popups call this on open.
    function refresh() {
        stateProc.running = true;
        radioStateProc.running = true;
    }

    // `nmcli -t` separates fields with ":" and escapes a colon inside a field
    // as "\\:", so a plain split() mangles any SSID containing one. Hide the
    // escaped colons, split, then put them back.
    function fields(line) {
        return line.replace(/\\:/g, "\u0001").split(":").map(f => f.replace(/\u0001/g, ":"));
    }

    function setRadio(on) {
        radioProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"];
        radioProc.running = true;
        // Optimistic: radioStateProc confirms it when nmcli exits.
        radioOn = on;
    }

    property Process radioProc: Process {
        onExited: root.refresh()
    }

    // SSID comes last: it is the only field that can contain a separator.
    property Process stateProc: Process {
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,SSID", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const parts = root.fields(line);
                    if (parts[0] === "yes") {
                        root.strength = parseInt(parts[1]) || 0;
                        root.ssid = parts.slice(2).join(":");
                        return;
                    }
                }
                root.ssid = "";
                root.strength = 0;
            }
        }
    }

    property Process radioStateProc: Process {
        command: ["nmcli", "-t", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.radioOn = text.trim() === "enabled"
        }
    }

    property Process monitorProc: Process {
        // pdeathsig: exit with qs; the monitor only writes on changes, so it
        // would otherwise linger until the next network event.
        command: ["setpriv", "--pdeathsig", "TERM", "nmcli", "monitor"]
        running: true

        // A single reconnect emits a burst of lines; coalesce them.
        stdout: SplitParser {
            onRead: debounce.restart()
        }

        onRunningChanged: if (running)
            root.refresh()
        // NetworkManager restarted or nmcli died; pick it back up.
        onExited: restartTimer.start()
    }

    property Timer debounce: Timer {
        interval: 300
        onTriggered: root.refresh()
    }

    property Timer restartTimer: Timer {
        interval: 2000
        onTriggered: root.monitorProc.running = true
    }
}
