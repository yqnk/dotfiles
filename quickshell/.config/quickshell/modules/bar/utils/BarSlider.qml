import "../../../utils"

import QtQuick

// macOS Control Center style slider: a thick rounded pill whose white fill
// tracks `value` (0..1), with the glyph sitting inside the track and
// inverting once the fill passes underneath it.
Item {
    id: root

    property real value: 0
    property string icon: ""
    property int trackHeight: 26
    property int glyphSize: 13
    property int glyphMargin: 8
    property color fillColor: "#ffffff"
    property bool interactive: true

    signal moved(real ratio)
    signal released

    implicitHeight: trackHeight

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Colors.withAlpha("#ffffff", 0.12)
        border.width: 0.5
        border.color: Colors.withAlpha("#ffffff", 0.10)
        clip: true

        Rectangle {
            id: fill
            width: track.width * Math.max(0, Math.min(root.value, 1))
            height: parent.height
            radius: parent.radius
            color: root.fillColor

            Behavior on width {
                enabled: !dragArea.pressed
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
        }

        BarText {
            id: glyph
            x: root.glyphMargin
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: root.glyphSize
            text: root.icon
            // dark on the filled part, light on the empty part
            color: fill.width > x + implicitWidth * 0.6 ? "#1c1c28" : "#ffffff"

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: root.interactive
        preventStealing: true

        function emit(x) {
            root.moved(Math.max(0, Math.min(1, x / track.width)));
        }

        onPressed: mouse => emit(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                emit(mouse.x);
        }
        onReleased: root.released()
    }
}
