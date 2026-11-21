import QtQuick
import QtQuick.Controls
import QtQml

Rectangle {
    id: root
    visible: Hud.current === "audio"
    implicitWidth: 360
    implicitHeight: content.implicitHeight + 28
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
        anchors.margins: 14
        spacing: 10

        Row {
            width: parent.width
            height: 28
            spacing: 8
            Text { text: "󰕾"; color: Theme.primary; font.family: Theme.fontUi; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
            Text {
                text: "SOUND"
                color: Theme.textMuted
                font.family: Theme.fontUi
                font.pixelSize: Theme.fontBody
                font.weight: Font.Normal
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 108
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Column {
                    width: (parent.width - 22) / 2
                    spacing: 3
                    Item {
                        width: parent.width
                        height: 20
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "󰕾  OUTPUT"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Audio.muted ? "Muted" : Audio.volume + "%"
                            color: Audio.muted ? Theme.outline : Theme.primary
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Normal
                        }
                    }
                    Slider {
                        id: volumeSlider
                        width: parent.width
                        height: 28
                        from: 0; to: 150
                        onMoved: Audio.setVolume(value)
                        Binding { target: volumeSlider; property: "value"; value: Audio.volume; when: !volumeSlider.pressed }
                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            antialiasing: true
                            width: volumeSlider.availableWidth; height: 6; radius: 3; color: Theme.background
                            Rectangle { antialiasing: true; width: parent.width * volumeSlider.visualPosition; height: parent.height; radius: 3; color: Theme.primary }
                        }
                        handle: Rectangle {
                            x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                            y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                            antialiasing: true
                            width: 15; height: 15; radius: 8; color: Theme.primary; border.width: 2; border.color: Theme.primaryInk
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 28
                        antialiasing: true
                        radius: 8
                        color: Theme.background
                        Text {
                            anchors.left: parent.left; anchors.leftMargin: 8
                            anchors.right: parent.right; anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: Audio.sink ? (Audio.sink.description || Audio.sink.nickname || "Audio output") : "No output device"
                            color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight
                        }
                    }
                }

                Rectangle { width: 1; height: parent.height; color: Theme.outline; opacity: 0.3 }

                Column {
                    width: (parent.width - 22) / 2
                    spacing: 3
                    Item {
                        width: parent.width
                        height: 20
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: "󰍬  MIC"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Audio.micMuted ? "Muted" : Audio.micVolume + "%"
                            color: Audio.micMuted ? Theme.outline : Theme.secondary
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Normal
                        }
                    }
                    Slider {
                        id: micSlider
                        width: parent.width
                        height: 28
                        from: 0; to: 150
                        onMoved: Audio.setMicVolume(value)
                        Binding { target: micSlider; property: "value"; value: Audio.micVolume; when: !micSlider.pressed }
                        background: Rectangle {
                            x: micSlider.leftPadding
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            antialiasing: true
                            width: micSlider.availableWidth; height: 6; radius: 3; color: Theme.background
                            Rectangle { antialiasing: true; width: parent.width * micSlider.visualPosition; height: parent.height; radius: 3; color: Theme.secondary }
                        }
                        handle: Rectangle {
                            x: micSlider.leftPadding + micSlider.visualPosition * (micSlider.availableWidth - width)
                            y: micSlider.topPadding + micSlider.availableHeight / 2 - height / 2
                            antialiasing: true
                            width: 15; height: 15; radius: 8; color: Theme.secondary; border.width: 2; border.color: Theme.primaryInk
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 28
                        antialiasing: true
                        radius: 8
                        color: Theme.background
                        Text {
                            anchors.left: parent.left; anchors.leftMargin: 8
                            anchors.right: parent.right; anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: Audio.source ? (Audio.source.description || Audio.source.nickname || "Audio input") : "No microphone"
                            color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: 8
            Rectangle {
                width: (parent.width - 8) / 2
                height: 30
                antialiasing: true
                        radius: Theme.tileRadius
                color: Audio.muted ? Theme.error : Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: Audio.muted ? "Unmute output" : "Mute output"; color: Audio.muted ? Theme.onError : Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Audio.toggleMute() }
            }
            Rectangle {
                width: (parent.width - 8) / 2
                height: 30
                antialiasing: true
                        radius: Theme.tileRadius
                color: Audio.micMuted ? Theme.error : Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: Audio.micMuted ? "Unmute microphone" : "Mute microphone"; color: Audio.micMuted ? Theme.onError : Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Audio.toggleMicMute() }
            }
        }

        Text { visible: Audio.outputs.length > 1; text: "OUTPUT DEVICES"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal; leftPadding: 2 }
        Flow {
            width: parent.width
            spacing: 6
            visible: Audio.outputs.length > 1
            Repeater {
                model: Audio.outputs
                Rectangle {
                    required property var modelData
                    width: Math.min(156, deviceName.implicitWidth + 22)
                    height: 28
                    antialiasing: true
                    radius: Theme.tileRadius
                    color: modelData.active ? Theme.primary : Theme.surfaceHigh
                    Text { id: deviceName; anchors.centerIn: parent; width: parent.width - 12; text: modelData.name; color: modelData.active ? Theme.primaryInk : Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Audio.setOutput(modelData.node) }
                }
            }
        }

        Text { visible: Audio.inputs.length > 1; text: "INPUT DEVICES"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal; leftPadding: 2 }
        Flow {
            width: parent.width
            spacing: 6
            visible: Audio.inputs.length > 1
            Repeater {
                model: Audio.inputs
                Rectangle {
                    required property var modelData
                    width: Math.min(156, inputName.implicitWidth + 22)
                    height: 28
                    antialiasing: true
                    radius: Theme.tileRadius
                    color: modelData.active ? Theme.secondary : Theme.surfaceHigh
                    Text { id: inputName; anchors.centerIn: parent; width: parent.width - 12; text: modelData.name; color: modelData.active ? Theme.primaryInk : Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Audio.setInput(modelData.node) }
                }
            }
        }
    }
}
