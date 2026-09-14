pragma Singleton

import QtQuick

// Shared bookkeeping for bar popups.
//
// The bar is a layer-shell surface with no keyboard focus by default, and a
// popup can only receive key events while its parent surface is focusable.
// Popups bump `openCount` while shown so the bar can switch itself to
// on-demand keyboard focus only for as long as something is open.
QtObject {
    id: root

    property int openCount: 0
    readonly property bool anyOpen: openCount > 0

    function opened() {
        openCount += 1;
    }

    function closed() {
        openCount = Math.max(0, openCount - 1);
    }
}
