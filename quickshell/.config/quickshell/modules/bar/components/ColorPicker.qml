import "../utils/"

import Quickshell.Io

BarText {
    text: "\uf1fb"

    function pickColor() {
        picker.running = true;
    }

    Process {
        id: picker
        command: ["hyprpicker", "-a"]
        running: false
    }
}
