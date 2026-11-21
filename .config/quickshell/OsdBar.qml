import QtQuick

Rectangle {
    id: root
    anchors.fill: parent
    color: Theme.surface
    antialiasing: true
    radius: Theme.radius
    border.width: 1
    border.color: Theme.outline
    opacity: Hud.osdKind !== "" ? 1 : 0
    transform: Translate {
        y: Hud.osdKind !== "" ? 0 : 14
        Behavior on y { NumberAnimation { duration: Theme.motion; easing.type: Easing.OutCubic } }
    }
    Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 46
            height: 46
            radius: 23
            color: Hud.osdKind === "brightness" ? Theme.secondary : Theme.primary
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: Hud.osdKind === "brightness" ? "󰃠" : (Audio.muted ? "󰝟" : "󰕾")
                color: Theme.primaryInk
                font.family: Theme.fontUi
                font.pixelSize: 21
            }
        }

        Column {
            width: parent.width - 60
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Row {
                width: parent.width
                Text {
                    text: Hud.osdKind === "brightness" ? "DISPLAY BRIGHTNESS" : "OUTPUT VOLUME"
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: Math.max(0, parent.width - 206); height: 1 }
                Text {
                    text: Hud.osdKind === "brightness"
                        ? Brightness.percent + "%"
                        : Audio.muted ? "MUTED" : Audio.volume + "%"
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 8
                radius: 4
                color: Theme.background
                Rectangle {
                    height: parent.height
                    radius: 4
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.primary }
                        GradientStop { position: 1.0; color: Theme.secondary }
                    }
                    width: {
                        const max = Hud.osdKind === "brightness" ? 100 : 150
                        const value = Hud.osdKind === "brightness" ? Brightness.percent : Audio.muted ? 0 : Audio.volume
                        return parent.width * Math.max(0, Math.min(max, value)) / max
                    }
                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
