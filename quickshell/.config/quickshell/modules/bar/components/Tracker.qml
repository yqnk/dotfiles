pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "../../../utils"

// Time tracking service. Owns all state, persistence and reminders so the
// bar view stays dumb — important because the bar is instantiated once per
// screen and only a singleton avoids duplicate writers to the JSON file.
QtObject {
    id: root

    // ---- tuning -----------------------------------------------------------
    // Away for longer than this while a timer runs -> offer to discard it.
    readonly property int idleThresholdMs: 5 * 60 * 1000
    // A timer running this long is almost certainly one you forgot to stop.
    readonly property int longRunMs: 8 * 60 * 60 * 1000
    // Working this long with no timer running -> one nudge.
    readonly property int untrackedNudgeMs: 45 * 60 * 1000

    readonly property var projectPalette: ["#4caf50", "#3b82f6", "#f59e0b", "#ec4899", "#a78bfa", "#14b8a6", "#ef4444", "#84cc16"]

    // ---- persisted state --------------------------------------------------
    readonly property var entries: file.adapter ? file.adapter.entries : []
    readonly property var tasks: file.adapter ? file.adapter.tasks : []
    readonly property var projects: file.adapter ? file.adapter.projects : []
    // {} when nothing runs, else {taskId, name, project, start}
    readonly property var running: file.adapter && file.adapter.running ? file.adapter.running : ({})

    readonly property bool isRunning: !!running.start
    // Ticks every second while running, every minute otherwise, so "today"
    // stays fresh without burning cycles.
    property double now: Date.now()
    readonly property int elapsedMs: isRunning ? Math.max(0, now - running.start) : 0

    // ---- derived ----------------------------------------------------------
    readonly property double dayStart: {
        const d = new Date(now);
        d.setHours(0, 0, 0, 0);
        return d.getTime();
    }
    readonly property double weekStart: {
        const d = new Date(dayStart);
        // Monday-based week.
        d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
        return d.getTime();
    }

    readonly property double todayMs: rangeMs(dayStart, dayStart + 86400000)
    readonly property double weekMs: rangeMs(weekStart, weekStart + 7 * 86400000)

    // [{name, color, ms}] for today, biggest first.
    readonly property var todayByProject: {
        const from = dayStart;
        const to = from + 86400000;
        const acc = {};
        const add = (p, ms) => {
            if (ms <= 0)
                return;
            const key = p || "";
            acc[key] = (acc[key] || 0) + ms;
        };
        for (const e of entries)
            add(e.project, overlap(e.start, e.end, from, to));
        if (isRunning)
            add(running.project, overlap(running.start, now, from, to));
        return Object.keys(acc).map(k => ({
                    name: k,
                    color: colorFor(k),
                    ms: acc[k]
                })).sort((a, b) => b.ms - a.ms);
    }

    // Pinned first, then most recently used.
    readonly property var recentTasks: tasks.slice().sort((a, b) => {
        if (!!a.pinned !== !!b.pinned)
            return a.pinned ? -1 : 1;
        return (b.lastUsed || 0) - (a.lastUsed || 0);
    })

    // ---- helpers ----------------------------------------------------------
    function overlap(aStart, aEnd, bStart, bEnd) {
        return Math.max(0, Math.min(aEnd, bEnd) - Math.max(aStart, bStart));
    }

    // Time logged today for one task, running timer included.
    function taskTodayMs(taskId) {
        const from = dayStart;
        const to = from + 86400000;
        let total = 0;
        for (const e of entries)
            if (e.taskId === taskId)
                total += overlap(e.start, e.end, from, to);
        if (isRunning && running.taskId === taskId)
            total += overlap(running.start, now, from, to);
        return total;
    }

    function rangeMs(from, to) {
        let total = 0;
        for (const e of entries)
            total += overlap(e.start, e.end, from, to);
        if (isRunning)
            total += overlap(running.start, now, from, to);
        return total;
    }

    // "1h04m22s" — for the live timer.
    function fmtClock(ms) {
        const s = Math.floor(ms / 1000);
        const pad = n => (n < 10 ? "0" + n : "" + n);
        return Math.floor(s / 3600) + "h" + pad(Math.floor(s / 60) % 60) + "m" + pad(s % 60) + "s";
    }

    // "03:12:05" — for totals (day, week, per-task).
    function fmtShort(ms) {
        const s = Math.floor(Math.max(0, ms) / 1000);
        const pad = n => (n < 10 ? "0" + n : "" + n);
        return pad(Math.floor(s / 3600)) + ":" + pad(Math.floor(s / 60) % 60) + ":" + pad(s % 60);
    }

    function newId() {
        return Date.now() + "-" + Math.random().toString(36).slice(2);
    }

    function colorFor(project) {
        if (!project)
            return Colors.withAlpha("#ffffff", 0.35);
        const p = projects.find(x => x.name === project);
        return p ? p.color : "#3b82f6";
    }

    // "write report @ANSY" -> {name: "write report", project: "ANSY"}
    function parseInput(text) {
        const t = text.trim();
        const m = t.match(/^(.*?)\s*@\s*([^@]+)$/);
        if (m && m[1].length > 0)
            return {
                name: m[1].trim(),
                project: m[2].trim()
            };
        return {
            name: t,
            project: ""
        };
    }

    function persist() {
        file.writeAdapter();
    }

    // Mutations always read/write file.adapter.* directly, never the reactive
    // `tasks`/`entries`/`running` bindings above: those only settle on the next
    // event loop pass, so two writes in one tick would clobber each other.
    function ensureProject(name) {
        if (!name || file.adapter.projects.some(p => p.name === name))
            return;
        file.adapter.projects = file.adapter.projects.concat([
            {
                name: name,
                color: projectPalette[file.adapter.projects.length % projectPalette.length]
            }
        ]);
    }

    // ---- mutations --------------------------------------------------------
    function start(name, project) {
        const n = (name || "").trim();
        if (n.length === 0)
            return;
        if (file.adapter.running.start)
            stop();

        ensureProject(project);

        const proj = project || "";
        let task = file.adapter.tasks.find(t => t.name === n && (t.project || "") === proj);
        if (!task) {
            task = {
                id: newId(),
                name: n,
                project: proj,
                pinned: false,
                lastUsed: Date.now()
            };
            file.adapter.tasks = file.adapter.tasks.concat([task]);
        } else {
            touchTask(task.id);
        }

        file.adapter.running = {
            taskId: task.id,
            name: n,
            project: proj,
            start: Date.now()
        };
        awayStart = 0;
        awayEnd = 0;
        notifiedLongRun = false;
        persist();
    }

    function startFromInput(text) {
        const p = parseInput(text);
        start(p.name, p.project);
    }

    function resume(taskId) {
        const t = file.adapter.tasks.find(x => x.id === taskId);
        if (t)
            start(t.name, t.project);
    }

    // Closes the running entry. `endAt` lets the idle prompt cut it short.
    function stop(endAt) {
        const run = file.adapter.running;
        if (!run.start)
            return;
        const end = endAt || Date.now();
        // Anything under 5s is a misclick, not a work session.
        if (end - run.start >= 5000) {
            file.adapter.entries = file.adapter.entries.concat([
                {
                    id: newId(),
                    taskId: run.taskId,
                    name: run.name,
                    project: run.project,
                    start: run.start,
                    end: end
                }
            ]);
        }
        touchTask(run.taskId);
        file.adapter.running = ({});
        awayStart = 0;
        awayEnd = 0;
        lastStopped = Date.now();
        notifiedUntracked = false;
        persist();
    }

    function touchTask(id) {
        file.adapter.tasks = file.adapter.tasks.map(t => t.id === id ? Object.assign({}, t, {
                lastUsed: Date.now()
            }) : t);
    }

    function togglePin(id) {
        file.adapter.tasks = file.adapter.tasks.map(t => t.id === id ? Object.assign({}, t, {
                pinned: !t.pinned
            }) : t);
        persist();
    }

    function renameTask(id, name) {
        const n = (name || "").trim();
        if (n.length === 0)
            return;
        file.adapter.tasks = file.adapter.tasks.map(t => t.id === id ? Object.assign({}, t, {
                name: n
            }) : t);
        if (file.adapter.running.taskId === id)
            file.adapter.running = Object.assign({}, file.adapter.running, {
                name: n
            });
        persist();
    }

    // History keeps its own denormalised name/project, so removing a task
    // never rewrites the past.
    function removeTask(id) {
        if (file.adapter.running.taskId === id)
            stop();
        file.adapter.tasks = file.adapter.tasks.filter(t => t.id !== id);
        persist();
    }

    // Only drops closed entries from today; a running timer keeps going.
    function clearToday() {
        const cut = dayStart;
        file.adapter.entries = file.adapter.entries.filter(e => e.end <= cut);
        persist();
    }

    // ---- idle handling ----------------------------------------------------
    // Epoch ms at which the idle period began, 0 when active.
    property double awayStart: 0
    readonly property bool awayPending: awayStart > 0 && !idle.isIdle && isRunning && (awayEnd - awayStart) >= idleThresholdMs
    property double awayEnd: 0
    readonly property double awayMs: Math.max(0, awayEnd - awayStart)

    // Keep the away time: just dismiss the prompt.
    function keepAway() {
        awayStart = 0;
        awayEnd = 0;
    }

    // Drop it: close the entry where you left, restart the same task now.
    function discardAway() {
        const run = file.adapter.running;
        if (!run.start) {
            keepAway();
            return;
        }
        const name = run.name;
        const project = run.project;
        const cut = awayStart;
        stop(cut);
        start(name, project);
        keepAway();
    }

    property double lastStopped: 0
    property bool notifiedLongRun: false
    property bool notifiedUntracked: false

    function notify(summary, body, urgency) {
        notifyProc.command = ["notify-send", "-u", urgency || "normal", "-a", "Tracker", summary, body || ""];
        notifyProc.running = true;
    }

    // ---- children (QtObject can't hold visual children, hence properties) --
    property Process notifyProc: Process {}

    property FileView file: FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/data/timetracker.json"
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            adapter.entries = [];
            adapter.tasks = [];
            adapter.projects = [];
            adapter.running = ({});
            writeAdapter();
        }
        adapter: JsonAdapter {
            property var entries: []
            property var tasks: []
            property var projects: []
            property var running: ({})
        }
    }

    property Timer tick: Timer {
        interval: root.isRunning ? 1000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.now = Date.now();

            if (root.isRunning && !root.notifiedLongRun && root.elapsedMs >= root.longRunMs) {
                root.notifiedLongRun = true;
                root.notify("Timer running for " + root.fmtShort(root.elapsedMs), "\"" + root.running.name + "\" — did you forget to stop it?", "normal");
            }

            if (!root.isRunning && !root.idle.isIdle && !root.notifiedUntracked && root.lastStopped > 0 && Date.now() - root.lastStopped >= root.untrackedNudgeMs) {
                root.notifiedUntracked = true;
                root.notify("Not tracking", "Nothing tracked for " + root.fmtShort(Date.now() - root.lastStopped) + ".", "low");
            }
        }
    }

    property IdleMonitor idle: IdleMonitor {
        enabled: true
        // Seconds of no input before we call it away-from-keyboard.
        timeout: 300
        onIsIdleChanged: {
            if (isIdle) {
                root.awayStart = Date.now() - timeout * 1000;
                root.awayEnd = 0;
            } else if (root.awayStart > 0) {
                root.awayEnd = Date.now();
                if (root.isRunning && root.awayMs >= root.idleThresholdMs) {
                    root.notify("Away for " + root.fmtShort(root.awayMs), "\"" + root.running.name + "\" kept running. Open the tracker to discard it.", "normal");
                } else {
                    root.keepAway();
                }
                // Fresh activity restarts the untracked nudge window.
                if (!root.isRunning) {
                    root.notifiedUntracked = false;
                    root.lastStopped = Math.max(root.lastStopped, Date.now());
                }
            }
        }
    }
}
