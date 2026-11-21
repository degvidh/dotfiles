import QtQuick

Rectangle {
    id: root
    implicitWidth: 360
    implicitHeight: content.implicitHeight + 32
    color: Theme.surface
    antialiasing: true
    radius: Theme.radius
    border.width: 1
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.32)
    property bool entered: false
    opacity: entered ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    transform: Translate { y: root.entered ? 0 : -12; Behavior on y { NumberAnimation { duration: Theme.motion; easing.type: Easing.OutCubic } } }
    Component.onCompleted: entered = true

    MouseArea { anchors.fill: parent; onClicked: {} }

    Column {
        id: content
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Rectangle {
            width: parent.width
            height: 100
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 104
                spacing: 14

                Rectangle {
                    width: 54
                    height: 54
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: true
                    radius: 27
                    color: Battery.charging ? Theme.primary : Theme.background
                    Text {
                        anchors.centerIn: parent
                        text: Battery.charging ? "󰂄" : (Battery.percent <= 15 ? "󰂎" : "󰁹")
                        color: Battery.charging ? Theme.primaryInk : Theme.secondary
                        font.family: Theme.fontUi
                        font.pixelSize: 29
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: Battery.present ? (Battery.percent + "%") : "No battery"
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.pixelSize: 30
                        font.weight: Font.Normal
                    }
                    Text {
                        text: Battery.present ? Battery.statusLabel : "Power supply not detected"
                        color: Theme.textMuted
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                    }
                }

            }

            Column {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Battery.onAc ? "󰚥" : "󰚦"
                    color: Battery.onAc ? Theme.primary : Theme.outline
                    font.family: Theme.fontUi
                    font.pixelSize: 22
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Battery.onAc ? "PLUGGED IN" : "ON BATTERY"
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                }
            }
        }

        Rectangle {
            visible: Battery.present
            width: parent.width
            height: 9
            antialiasing: true
            radius: 5
            color: Theme.background
            Rectangle {
                height: parent.height
                width: parent.width * Math.max(0, Math.min(100, Battery.percent)) / 100
                antialiasing: true
                radius: 5
                color: Battery.percent <= 15 ? Theme.error : (Battery.charging ? Theme.secondary : Theme.primary)
            }
        }

        Row {
            width: parent.width
            spacing: 10

            Rectangle {
                width: (parent.width - 10) / 2
                height: 80
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "ESTIMATE"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Battery.timeLabel || "Time unavailable"; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight }
                }
            }

            Rectangle {
                width: (parent.width - 10) / 2
                height: 80
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Battery.charging ? "INPUT POWER" : "POWER DRAW"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Battery.watts > 0.05 ? (Battery.watts.toFixed(1) + " W") : (Battery.onAc ? "AC power" : "Low activity"); color: Theme.text; font.family: Theme.fontUi; font.pixelSize: 15; font.weight: Font.Normal }
                }
            }
        }
    }
}
