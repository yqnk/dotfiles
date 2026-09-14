pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// niri IPC bridge. Quickshell 0.3.1 ships no Niri module, so we tail
// `niri msg --json event-stream` and keep the workspace list in sync from the
// events. Singleton because the bar is instantiated once per screen and one
// event stream is enough for all of them.
QtObject {
    id: root

    readonly property bool available: !!Quickshell.env("NIRI_SOCKET")

    // [{ id, idx, name, output, isActive, isFocused, isUrgent }],
    // ordered by output, then by the index niri assigns within that output.
    property var workspaces: []

    // niri's focus-workspace takes an index relative to the focused output,
    // so hop to the workspace's monitor first. Arguments are passed to sh
    // positionally, never interpolated into the command string.
    function focusWorkspace(ws) {
        if (!ws)
            return;

        actionProc.command = ["sh", "-c", "niri msg action focus-monitor \"$1\" && niri msg action focus-workspace \"$2\"", "sh", String(ws.output), String(ws.idx)];
        actionProc.running = true;
    }

    function _normalize(ws) {
        return {
            id: ws.id,
            idx: ws.idx,
            name: ws.name,
            output: ws.output,
            isActive: ws.is_active,
            isFocused: ws.is_focused,
            isUrgent: ws.is_urgent
        };
    }

    function _order(a, b) {
        if (a.output !== b.output)
            return a.output < b.output ? -1 : 1;
        return a.idx - b.idx;
    }

    function _ingest(line) {
        if (!line)
            return;

        let event;
        try {
            event = JSON.parse(line);
        } catch (e) {
            return;
        }

        if (event.WorkspacesChanged) {
            root.workspaces = event.WorkspacesChanged.workspaces.map(root._normalize).sort(root._order);
            return;
        }

        if (event.WorkspaceActivated) {
            const activated = event.WorkspaceActivated;
            const target = root.workspaces.find(ws => ws.id === activated.id);
            if (!target)
                return;

            // Only one workspace is active per output, and at most one has
            // keyboard focus across all outputs.
            root.workspaces = root.workspaces.map(ws => {
                const updated = Object.assign({}, ws);
                if (ws.output === target.output)
                    updated.isActive = ws.id === activated.id;
                if (activated.focused)
                    updated.isFocused = ws.id === activated.id;
                return updated;
            });
            return;
        }

        if (event.WorkspaceUrgencyChanged) {
            const changed = event.WorkspaceUrgencyChanged;
            root.workspaces = root.workspaces.map(ws => ws.id === changed.id ? Object.assign({}, ws, {
                isUrgent: changed.urgent
            }) : ws);
        }
    }

    property Process actionProc: Process {}

    property Process eventProc: Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: root.available

        stdout: SplitParser {
            onRead: data => root._ingest(data)
        }

        // The stream dies when niri restarts; pick it back up.
        onExited: restartTimer.start()
    }

    property Timer restartTimer: Timer {
        interval: 1000
        onTriggered: {
            if (root.available)
                root.eventProc.running = true;
        }
    }
}
