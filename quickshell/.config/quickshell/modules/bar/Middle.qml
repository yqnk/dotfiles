import "components"
import "utils"
import "../../utils"

import QtQuick

Row {
    id: midSection
    anchors.verticalCenter: parent.verticalCenter
    spacing: 0

    property var barWindow

    // Keep the clock itself dead centre on screen: shift the whole row right
    // by half of whatever the tracker segment currently occupies.
    anchors.horizontalCenterOffset: trackerRect.width / 2

    // TODO: le calendar LINK AVEC MON GOOGLE CALENDAR ??

    BarRect {
        // Right side is squared off so the tracker fuses onto it.
        rightRadius: 0
        onClicked: {
            console.log("left");
        }
        Clock {}
    }

    // Hairline seam between the two halves of the merged pill.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 14
        color: Colors.withAlpha("#ffffff", 0.12)
        z: 1
    }

    // Time tracker, tinted so it reads as its own segment.
    BarRect {
        id: trackerRect
        leftRadius: 0
        normalColor: Colors.withAlpha(timeTracker.accent, timeTracker.active ? 0.18 : 0.08)
        hoveredColor: Colors.withAlpha(timeTracker.accent, timeTracker.active ? 0.3 : 0.2)
        onClicked: timeTracker.toggle()
        // Right click anywhere on the segment stops the running timer.
        onRightClicked: Tracker.stop()

        TimeTracker {
            id: timeTracker
            barWindow: midSection.barWindow
            anchorItem: trackerRect
        }
    }

    // TODO: mpris ?
}
