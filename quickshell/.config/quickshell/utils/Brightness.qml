pragma Singleton

import QtQuick
import Quickshell.Io

// Backlight state shared by the OSD and every Control Center, so the sysfs
// files are watched once instead of once per consumer.
QtObject {
    id: root

    property string device: "intel_backlight"
    property int max: 1
    property int current: 0
    readonly property real pct: max > 0 ? current / max : 0

    function set(ratio) {
        const p = Math.round(Math.max(1, Math.min(100, ratio * 100)));
        current = Math.round(max * p / 100);
        setProc.command = ["brightnessctl", "-d", device, "set", p + "%"];
        setProc.running = true;
    }

    property Process setProc: Process {}

    // Blocking so the first value is there before the OSD arms itself.
    property FileView maxFile: FileView {
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
        blockLoading: true
        onLoaded: root.max = parseInt(text().trim())
    }

    property FileView currentFile: FileView {
        path: "/sys/class/backlight/" + root.device + "/brightness"
        blockLoading: true
        watchChanges: true
        onLoaded: root.current = parseInt(text().trim())
        onFileChanged: reload()
    }
}
