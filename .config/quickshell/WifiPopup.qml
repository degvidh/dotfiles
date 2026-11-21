import QtQuick

Rectangle {
    id: root

    readonly property int rowH: 36
    readonly property int maxRows: 4

    implicitWidth: 340
    implicitHeight: col.implicitHeight + 24

    color: Theme.surface
    antialiasing: true
    radius: Theme.radius
    border.width: 1
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.32)
    property bool entered: false
    opacity: entered ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    transform: Translate { y: root.entered ? 0 : -12; Behavior on y { NumberAnimation { duration: Theme.motion; easing.type: Easing.OutCubic } } }
    Component.onCompleted: {
        entered = true
        forceActiveFocus()
    }

    focus: true
    Keys.onEscapePressed: function(event) {
        if (Wifi.passwordRequired)
            root.cancelPassword()
        else
            Hud.close()
        event.accepted = true
    }

    function submitPassword() {
        const password = passwordInput.text
        if (!password.length) {
            passwordInput.forceActiveFocus()
            return
        }
        passwordInput.text = ""
        Wifi.connectTo(Wifi.selectedSsid, password)
    }

    function cancelPassword() {
        passwordInput.text = ""
        passwordInput.focus = false
        Wifi.cancelPassword()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Column {
        id: col
        width: parent.width - 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12
        spacing: 7

        Rectangle {
            width: parent.width
            height: root.rowH
            antialiasing: true
            radius: Theme.tileRadius
            color: Wifi.radioOn ? Theme.primary : Theme.surfaceHigh

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "󰖩"
                    color: Wifi.radioOn ? Theme.primaryInk : Theme.outline
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: Wifi.radioOn ? "WiFi  On" : "WiFi  Off"
                    color: Wifi.radioOn ? Theme.primaryInk : Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Wifi.toggleRadio()
            }
        }

        Rectangle {
            visible: Wifi.radioOn && Wifi.connected !== null
            width: parent.width
            height: 58
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.primary

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "󰖩"
                    color: Theme.primaryInk
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: Wifi.connected ? Wifi.connected.ssid : ""
                    color: Theme.primaryInk
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                    width: 174
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: Wifi.connected && Wifi.connected.locked ? "󰌾" : ""
                    color: Theme.primaryInk
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: Wifi.connected
                        ? Number(Wifi.connected.signal) > 0 ? Wifi.connected.signal + "%" : "—"
                        : ""
                    color: Theme.primaryInk
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Text {
            visible: Wifi.savedNetworks.length > 0
            text: "SAVED NETWORKS"
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: 13
            font.weight: Font.Normal
            leftPadding: 2
        }

        ListView {
            visible: Wifi.savedNetworks.length > 0
            width: parent.width
            height: Math.min(count, 3) * root.rowH + Math.max(0, Math.min(count, 3) - 1) * 4
            clip: true
            spacing: 4
            model: Wifi.savedNetworks
            delegate: Rectangle {
                required property string modelData
                width: ListView.view.width
                height: root.rowH
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8
                    Text { text: "󰖩"; color: Theme.primary; font.family: Theme.fontUi; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                    Text { width: parent.width - 36; text: modelData; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: 13; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Wifi.connectSaved(modelData) }
            }
        }

        Text {
            visible: Wifi.radioOn && Wifi.others.length > 0
            text: "NEARBY NETWORKS"
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: 13
            font.weight: Font.Normal
            leftPadding: 2
        }

        ListView {
            visible: Wifi.radioOn
            width: parent.width
            implicitHeight: Math.min(count, root.maxRows) * (root.rowH + 5) - (count > 0 ? 5 : 0)
            clip: true
            spacing: 5
            model: Wifi.others
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                required property var modelData
                width: ListView.view.width
                height: root.rowH
                antialiasing: true
                radius: Theme.tileRadius
                color: Theme.surfaceHigh

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "󰖩"
                        color: Theme.secondary
                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.ssid
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        width: parent.width - 104
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.locked ? "󰌾" : ""
                        color: Theme.textMuted
                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.signal + "%"
                        color: Theme.textMuted
                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Wifi.selectNetwork(modelData)
                }
            }
        }

        Rectangle {
            id: passwordRow
            visible: Wifi.passwordRequired
            width: parent.width
            height: 36
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh
            onVisibleChanged: if (visible) Qt.callLater(passwordInput.forceActiveFocus)

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                selectedTextColor: Theme.primaryInk
                selectionColor: Theme.primary
                font.family: Theme.fontUi
                font.pixelSize: 13
                echoMode: TextInput.Password
                clip: true
                onAccepted: root.submitPassword()
                Keys.onEscapePressed: function(event) {
                    root.cancelPassword()
                    event.accepted = true
                }
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Password for " + Wifi.selectedSsid
                    color: Theme.outline
                    font: passwordInput.font
                    elide: Text.ElideRight
                    visible: !passwordInput.text
                }
            }
        }

        Rectangle {
            visible: Wifi.passwordRequired
            width: parent.width
            height: root.rowH
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.primary
            opacity: passwordInput.text.length > 0 ? 1 : 0.65
            Text {
                anchors.centerIn: parent
                text: "Connect"
                color: Theme.primaryInk
                font.family: Theme.fontUi
                font.pixelSize: 13
                font.weight: Font.Normal
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.submitPassword()
            }
        }

        Text {
            visible: Wifi.status !== "" && Wifi.status !== "on" && Wifi.status !== "off"
            width: parent.width
            text: Wifi.status
            color: Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontUi
            font.pixelSize: 13
            elide: Text.ElideRight
        }

        Text {
            visible: Wifi.radioOn && Wifi.others.length > root.maxRows
            width: parent.width
            height: 14
            horizontalAlignment: Text.AlignHCenter
            text: "—  scroll for more  —"
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: 13
        }

        Rectangle {
            visible: Wifi.radioOn
            width: parent.width
            height: root.rowH
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 8

                Text {
                    text: "󰑐"
                    color: Theme.primary
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: Wifi.scanning ? "Scanning ..." : "Refresh"
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Wifi.scan()
            }
        }

        Rectangle {
            width: parent.width
            height: root.rowH
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                spacing: 8

                Text {
                    text: "󰨝"
                    color: Theme.secondary
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Open editor..."
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.italic: true
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Wifi.openEditor()
            }
        }
    }
}
