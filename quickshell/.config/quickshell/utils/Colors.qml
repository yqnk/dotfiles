pragma Singleton

import QtQuick

QtObject {
    function withAlpha(color: color, alpha: real): color {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }
}
