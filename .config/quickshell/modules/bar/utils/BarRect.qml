import "../../../utils"

import QtQuick

Rectangle {
    id: barRectRoot
    property int vpad: 2
    property int hpad: 6
    property int innerSpacing: 6

    property string hoveredColor: Colors.withAlpha("#ffffff", 0.15)
    property string normalColor: Colors.withAlpha("#ffffff", 0.08)
    property string borderColor: Colors.withAlpha("#ffffff", 0.1)

    default property alias innerContent: contentContainer.data

    signal clicked

    radius: 2
    implicitWidth: contentContainer.childrenRect.width + (hpad * 2)
    implicitHeight: contentContainer.childrenRect.height + (vpad * 2)

    color: mouseArea.containsMouse ? hoveredColor : normalColor

    border.color: borderColor
    border.width: 1

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
