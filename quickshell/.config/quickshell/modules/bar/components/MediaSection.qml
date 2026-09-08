import "../../../utils"
import "../utils"

import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects

// Media block of the control center: album art, track info, transport
// controls and a progress bar for the active MPRIS player. Hidden when
// nothing is playing. Click the app name to cycle between players.
Column {
    id: root

    property int rowWidth: 260

    readonly property color accent: "#3b82f6"

    // Index into `players`, clamped whenever the list changes.
    property int playerIndex: 0

    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player: players.length > 0 ? players[Math.min(playerIndex, players.length - 1)] : null

    readonly property bool hasArt: (player?.trackArtUrl ?? "") !== ""
    readonly property real progress: (player?.lengthSupported && player?.length > 0) ? Math.max(0, Math.min(1, player.position / player.length)) : 0

    function cyclePlayer() {
        if (players.length > 1)
            playerIndex = (playerIndex + 1) % players.length;
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const total = Math.floor(seconds);
        const m = Math.floor(total / 60);
        const s = total % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    visible: player !== null
    spacing: 2

    onPlayersChanged: {
        if (playerIndex >= players.length)
            playerIndex = 0;
    }

    // MPRIS position is only refetched when the signal fires, so poll it
    // while something is actually playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.visible && (root.player?.isPlaying ?? false) && (root.player?.positionSupported ?? false)
        onTriggered: root.player.positionChanged()
    }

    // Round transport button.
    component TransportButton: Rectangle {
        property string glyph: ""
        property bool primary: false

        signal activated

        width: primary ? 28 : 24
        height: width
        radius: width / 2
        color: primary ? (btnArea.containsMouse ? Qt.lighter(root.accent, 1.15) : root.accent) : (btnArea.containsMouse ? Colors.withAlpha("#ffffff", 0.14) : "transparent")
        opacity: enabled ? 1 : 0.35

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        BarText {
            anchors.centerIn: parent
            font.pixelSize: parent.primary ? 12 : 11
            text: parent.glyph
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.activated()
        }
    }

    Rectangle {
        width: root.rowWidth
        implicitHeight: 76
        radius: 12
        color: Colors.withAlpha("#ffffff", 0.06)

        // Album art, or a note glyph when the player exposes none.
        Rectangle {
            id: art
            width: 42
            height: 42
            radius: 9
            clip: true
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 9
            color: Colors.withAlpha("#ffffff", 0.10)

            Image {
                id: artImage
                anchors.fill: parent
                visible: false
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                sourceSize.width: 84
                sourceSize.height: 84
            }

            // Rounded-corner mask: Rectangle.clip is rectangular, so the art
            // is masked by a copy of this tile's own shape instead.
            Rectangle {
                id: artMask
                anchors.fill: parent
                radius: parent.radius
                color: "black"
                visible: false
                layer.enabled: true
            }

            MultiEffect {
                anchors.fill: parent
                visible: root.hasArt && artImage.status === Image.Ready
                source: artImage
                maskEnabled: true
                maskSource: artMask
            }

            BarText {
                anchors.centerIn: parent
                visible: !root.hasArt || artImage.status !== Image.Ready
                font.pixelSize: 16
                color: Colors.withAlpha("#ffffff", 0.55)
                text: "󰎆"
            }
        }

        Column {
            id: info
            anchors.left: art.right
            anchors.leftMargin: 10
            anchors.right: transport.left
            anchors.rightMargin: 6
            anchors.top: parent.top
            anchors.topMargin: 9
            spacing: 1

            BarText {
                width: parent.width
                elide: Text.ElideRight
                font.bold: true
                font.pixelSize: 11
                text: root.player?.trackTitle || "Unknown track"
            }

            BarText {
                width: parent.width
                elide: Text.ElideRight
                font.pixelSize: 10
                color: Colors.withAlpha("#ffffff", 0.55)
                text: root.player?.trackArtist || root.player?.trackAlbum || ""
            }

            // App name doubles as the player switcher when several are up.
            Row {
                spacing: 4

                BarText {
                    elide: Text.ElideRight
                    font.pixelSize: 9
                    color: identityArea.containsMouse && root.players.length > 1 ? Colors.withAlpha("#ffffff", 0.7) : Colors.withAlpha("#ffffff", 0.4)
                    text: root.player?.identity ?? ""

                    MouseArea {
                        id: identityArea
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.players.length > 1
                        onClicked: root.cyclePlayer()
                    }
                }

                BarText {
                    visible: root.players.length > 1
                    font.pixelSize: 9
                    color: Colors.withAlpha("#ffffff", 0.4)
                    text: "󰓦 " + (root.playerIndex + 1) + "/" + root.players.length
                }
            }
        }

        Row {
            id: transport
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 12
            spacing: 2

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "󰒮"
                enabled: root.player?.canGoPrevious ?? false
                onActivated: root.player.previous()
            }

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                primary: true
                glyph: root.player?.isPlaying ? "󰏤" : "󰐊"
                enabled: root.player?.canTogglePlaying ?? false
                onActivated: root.player.togglePlaying()
            }

            TransportButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "󰒭"
                enabled: root.player?.canGoNext ?? false
                onActivated: root.player.next()
            }
        }

        // Progress bar + elapsed / total, only when the player reports a length.
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 9
            height: 12
            visible: root.player?.lengthSupported ?? false

            BarText {
                id: elapsed
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 9
                color: Colors.withAlpha("#ffffff", 0.45)
                text: root.formatTime(root.player?.position ?? 0)
            }

            BarText {
                id: total
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 9
                color: Colors.withAlpha("#ffffff", 0.45)
                text: root.formatTime(root.player?.length ?? 0)
            }

            Rectangle {
                id: track
                anchors.left: elapsed.right
                anchors.right: total.left
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                height: 3
                radius: 1.5
                color: Colors.withAlpha("#ffffff", 0.12)

                Rectangle {
                    width: parent.width * root.progress
                    height: parent.height
                    radius: parent.radius
                    color: root.accent

                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }

                // Click or drag anywhere on the bar to seek.
                MouseArea {
                    anchors.fill: parent
                    anchors.topMargin: -6
                    anchors.bottomMargin: -6
                    enabled: (root.player?.canSeek ?? false) && (root.player?.positionSupported ?? false)

                    function seekTo(x) {
                        const ratio = Math.max(0, Math.min(1, x / track.width));
                        root.player.position = ratio * root.player.length;
                    }

                    onPressed: mouse => seekTo(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed)
                            seekTo(mouse.x);
                    }
                }
            }
        }
    }
}
