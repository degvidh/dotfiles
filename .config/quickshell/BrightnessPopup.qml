import QtQuick
import QtQuick.Controls
import QtQml

Rectangle {
    id: root
    visible: Hud.current === "brightness"
    implicitWidth: 360
    implicitHeight: col.implicitHeight + 32
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

    Timer {
        interval: 350
        repeat: true
        running: root.visible
        onTriggered: Brightness.refresh()
    }

    Column {
        id: col
        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 9

        Rectangle {
            width: parent.width
            height: 54
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh
            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 70
                spacing: 10
                Text { text: "󰃠"; color: Theme.primary; font.family: Theme.fontUi; font.pixelSize: 23; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text { text: "DISPLAY BRIGHTNESS"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                    Text { text: "Screen brightness"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                }
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: Brightness.percent + "%"
                color: Theme.primary
                font.family: Theme.fontUi
                font.pixelSize: 20
                font.weight: Font.Normal
            }
        }

        Slider {
            id: brightnessSlider
            width: parent.width
            height: 30
            from: 1
            to: 100
            onMoved: Brightness.setPercent(value)
            Binding { target: brightnessSlider; property: "value"; value: Brightness.percent; when: !brightnessSlider.pressed }
            background: Rectangle {
                x: brightnessSlider.leftPadding
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                width: brightnessSlider.availableWidth
                height: 8
                antialiasing: true
                radius: 4
                color: Theme.background
                Rectangle {
                    width: parent.width * brightnessSlider.visualPosition
                    height: parent.height
                    antialiasing: true
                    radius: 4
                    color: Theme.primary
                }
            }
            handle: Rectangle {
                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                width: 20
                height: 20
                antialiasing: true
                radius: 10
                color: Theme.primary
                border.width: 2
                border.color: Theme.primaryInk
            }
        }

        Row {
            width: parent.width
            Text { text: "DIM"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
            Item { width: parent.width - 70; height: 1 }
            Text { text: "BRIGHT"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; horizontalAlignment: Text.AlignRight }
        }

        Rectangle {
            visible: Brightness.keyboardPresent
            width: parent.width
            height: 76
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 3
                Row {
                    width: parent.width
                    Text { text: "󰌌  KEYBOARD"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                    Item { width: parent.width - 130; height: 1 }
                    Text { text: Brightness.keyboardPercent + "%"; color: Theme.secondary; font.family: Theme.fontUi; font.pixelSize: 15; font.weight: Font.Normal }
                }
                Slider {
                    id: keyboardSlider
                    width: parent.width
                    height: 28
                    from: 0
                    to: 100
                    onMoved: Brightness.setKeyboardPercent(value)
                    Binding { target: keyboardSlider; property: "value"; value: Brightness.keyboardPercent; when: !keyboardSlider.pressed }
                    background: Rectangle {
                        x: keyboardSlider.leftPadding
                        y: keyboardSlider.topPadding + keyboardSlider.availableHeight / 2 - height / 2
                        antialiasing: true
                        width: keyboardSlider.availableWidth; height: 6; radius: 3; color: Theme.background
                        Rectangle { antialiasing: true; width: parent.width * keyboardSlider.visualPosition; height: parent.height; radius: 3; color: Theme.secondary }
                    }
                    handle: Rectangle {
                        x: keyboardSlider.leftPadding + keyboardSlider.visualPosition * (keyboardSlider.availableWidth - width)
                        y: keyboardSlider.topPadding + keyboardSlider.availableHeight / 2 - height / 2
                        antialiasing: true
                        width: 16; height: 16; radius: 8; color: Theme.secondary; border.width: 2; border.color: Theme.primaryInk
                    }
                }
            }
        }
    }
}
