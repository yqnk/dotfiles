import "modules/bar"
import "modules/bar/components"
import "modules/osd"
import Quickshell

ShellRoot {
    id: root

    // not actually used, but this ensures the singleton is created and acts
    // without this instanciation, the notifier would never initialize hence never trigger
    property real _batteryNotifierInitSingleton: BatteryNotifier.percent
    // Same deal: the tracker must tick and fire reminders even with no popup open
    property bool _trackerInitSingleton: Tracker.isRunning

    Bar {}

    VolumeOsd {}
    BrightnessOsd {}
}
