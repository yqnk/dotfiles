pragma Singleton

import QtQuick

// Nerd Font glyphs shared by the bar, the OSD and the control center, so the
// same state never shows two different icons.
QtObject {
    function volume(level: real, muted: bool): string {
        if (muted)
            return "";
        if (level === 0)
            return "-";
        if (level < 0.33)
            return "";
        if (level < 0.66)
            return "";
        return "";
    }
}
