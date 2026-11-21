import QtQuick

Rectangle {
    id: root
    visible: Hud.current === "bluetooth"
    implicitWidth: 344
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

        Item {
            width: parent.width
            height: 42
            Row {
                anchors.left: parent.left
                width: parent.width - 70
                height: parent.height
                spacing: 10
                Text { text: "󰂯"; color: Bluetooth.powered ? Theme.primary : Theme.outline; font.family: Theme.fontUi; font.pixelSize: 22; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    Text { text: "Bluetooth"; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal }
                    Text { text: Bluetooth.powered ? "Ready to connect" : "Radio is off"; color: Theme.outline; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 54
                height: 30
                antialiasing: true
                radius: 15
                color: Bluetooth.powered ? Theme.primary : Theme.surfaceHigh
                Rectangle {
                    x: Bluetooth.powered ? parent.width - width - 4 : 4
                    y: 4
                    width: 22
                    height: 22
                    antialiasing: true
                    radius: 11
                    color: Bluetooth.powered ? Theme.primaryInk : Theme.textMuted
                    Behavior on x { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.togglePower() }
            }
        }

        Rectangle {
            visible: Bluetooth.powered
            width: parent.width
            height: 38
            antialiasing: true
            radius: Theme.tileRadius
            color: Bluetooth.scanning ? Theme.primary : Theme.surfaceHigh
            Text {
                anchors.centerIn: parent
                text: Bluetooth.scanning ? "Scanning nearby…" : "⌕   Scan for devices"
                color: Bluetooth.scanning ? Theme.primaryInk : Theme.text
                font.family: Theme.fontUi
                font.pixelSize: Theme.fontBody
                font.weight: Font.Normal
            }
            MouseArea { anchors.fill: parent; enabled: !Bluetooth.scanning; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.scan() }
        }

        Text {
            visible: Bluetooth.powered && Bluetooth.pairedDevices.length > 0
            text: "YOUR DEVICES"
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontBody
            font.weight: Font.Normal
            leftPadding: 2
        }

        ListView {
            visible: Bluetooth.powered && Bluetooth.pairedDevices.length > 0
            width: parent.width
            height: Math.min(count, 4) * 42
            clip: true
            spacing: 5
            model: Bluetooth.pairedDevices
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 37
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Text { text: "󰂱"; color: Theme.primary; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; anchors.verticalCenter: parent.verticalCenter }
                    Text { width: parent.width - 34; text: modelData.name; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.connectTo(modelData.mac) }
            }
        }

        Text {
            visible: Bluetooth.powered && Bluetooth.nearbyDevices.length > 0
            text: "AVAILABLE NEARBY"
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontBody
            font.weight: Font.Normal
            leftPadding: 2
        }

        ListView {
            visible: Bluetooth.powered && Bluetooth.nearbyDevices.length > 0
            width: parent.width
            height: Math.min(count, 4) * 42
            clip: true
            spacing: 5
            model: Bluetooth.nearbyDevices
            boundsBehavior: Flickable.StopAtBounds
            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: 37
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Text { text: "󰂲"; color: Theme.secondary; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; anchors.verticalCenter: parent.verticalCenter }
                    Text { width: parent.width - 34; text: modelData.name; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Bluetooth.connectTo(modelData.mac) }
            }
        }

        Text {
            visible: Bluetooth.status !== ""
            width: parent.width
            text: Bluetooth.status
            color: Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontBody
            elide: Text.ElideRight
        }
    }
}
