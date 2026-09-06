import "../../../utils"

import QtQuick

Rectangle {
    id: barRectRoot
    property int vpad: 2
    property int hpad: 7
    property int innerSpacing: 5

    property string hoveredColor: Colors.withAlpha("#ffffff", 0.18)
    property string normalColor: Colors.withAlpha("#ffffff", 0.06)

    default property alias innerContent: contentContainer.data

    signal clicked

    radius: 7
    implicitWidth: contentContainer.childrenRect.width + (hpad * 2)
    implicitHeight: contentContainer.childrenRect.height + (vpad * 2)

    color: mouseArea.containsMouse ? hoveredColor : normalColor

    border.width: 0

    Behavior on color {
        ColorAnimation {
            duration: 300
        }
    }

    // Behavior on implicitWidth {
    //     NumberAnimation {
    //         duration: 100
    //     }
    // }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: barRectRoot.clicked()
    }

    Row {
        id: contentContainer
        anchors.centerIn: parent
        spacing: barRectRoot.innerSpacing
        width: childrenRect.width
        height: childrenRect.height
    }
}
