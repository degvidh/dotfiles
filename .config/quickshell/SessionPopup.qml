import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    visible: Hud.current === "session"
    implicitWidth: 286
    implicitHeight: col.implicitHeight + 32
    color: Theme.surface
    antialiasing: true
    radius: Theme.radius
    border.width: 1
    border.color: Qt.rgba(Theme.outline.r, Theme.outline.g, Theme.outline.b, 0.32)
    property string pendingLabel: ""
    property var pendingCmd: []
    property bool entered: false
    opacity: entered ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    transform: Translate { y: root.entered ? 0 : -12; Behavior on y { NumberAnimation { duration: Theme.motion; easing.type: Easing.OutCubic } } }

    // "Shut down" reads better than "Shutdown" in the confirmation sentence.
    readonly property string pendingVerb:
        root.pendingLabel === "Shutdown" ? "Shut down" : root.pendingLabel

    function tint(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    function confirmPowerAction() {
        if (!pendingCmd.length)
            return
        powerAction.command = pendingCmd
        powerAction.startDetached()
        Hud.close()
    }

    function cancelPending() {
        root.pendingCmd = []
        root.pendingLabel = ""
    }

    Process {
        id: powerAction
    }

    focus: true
    Keys.onEscapePressed: function(event) {
        if (root.pendingLabel !== "")
            root.cancelPending()
        else
            Hud.close()
        event.accepted = true
    }

    onVisibleChanged: if (visible) Qt.callLater(forceActiveFocus)

    Component.onCompleted: {
        entered = true
        if (visible)
            Qt.callLater(forceActiveFocus)
    }

    MouseArea { anchors.fill: parent; onClicked: {} }

    Column {
        id: col
        width: parent.width - 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 8

        Text {
            width: parent.width
            height: 20
            text: "SESSION"
            color: Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontBody
            font.weight: Font.Normal
            font.letterSpacing: 0.7
        }

        Repeater {
            model: root.pendingLabel === "" ? [
                { label: "Lock", cmd: ["/home/david/.local/bin/lock-screen"], icon: "󰌾", detail: "Secure this session" },
                { label: "Logout", cmd: ["/home/david/.local/bin/logout-to-greeter"], icon: "󰍃", detail: "Return to the login screen" },
                { label: "Reboot", cmd: ["/usr/bin/systemctl", "--no-block", "reboot"], icon: "󰜉", detail: "Restart this computer" },
                { label: "Shutdown", cmd: ["/usr/bin/systemctl", "--no-block", "poweroff"], icon: "󰐥", detail: "Power off this computer" }
            ] : []
            Rectangle {
                id: sessionRow
                required property var modelData
                readonly property bool destructive: modelData.label === "Shutdown"
                width: col.width
                height: 56
                antialiasing: true
                radius: Theme.tileRadius
                color: !sessionMouse.containsMouse
                    ? Theme.surfaceHigh
                    : root.tint(sessionRow.destructive ? Theme.error : Theme.primary, 0.12)
                border.width: sessionMouse.containsMouse ? 1 : 0
                border.color: sessionRow.destructive ? Theme.error : Theme.primary
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: sessionRow.modelData.icon
                    color: sessionRow.destructive ? Theme.error : Theme.primary
                    font.family: Theme.fontUi
                    font.pixelSize: 18
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.top: parent.top
                    anchors.topMargin: 9
                    text: sessionRow.modelData.label
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                    text: sessionRow.modelData.detail
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 11
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                }
                MouseArea {
                    id: sessionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.label === "Reboot" || modelData.label === "Shutdown") {
                            root.pendingCmd = modelData.cmd
                            root.pendingLabel = modelData.label
                        } else {
                            Quickshell.execDetached(modelData.cmd)
                            Hud.close()
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.pendingLabel !== ""
            width: col.width
            height: visible ? 92 : 0
            color: "transparent"
            Column {
                anchors.fill: parent
                spacing: 8
                Text {
                    width: parent.width
                    height: 28
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: root.pendingVerb + " this computer?"
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                    elide: Text.ElideRight
                }
                Row {
                    width: parent.width
                    height: 42
                    spacing: 8
                    Rectangle {
                        id: cancelButton
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: Theme.tileRadius
                        color: cancelMouse.containsMouse
                            ? root.tint(Theme.primary, 0.12)
                            : Theme.surfaceHigh
                        border.width: cancelMouse.containsMouse ? 1 : 0
                        border.color: Theme.primary
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: "Cancel"
                            color: Theme.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                        }
                        MouseArea {
                            id: cancelMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.cancelPending()
                        }
                    }
                    Rectangle {
                        id: confirmButton
                        width: (parent.width - parent.spacing) / 2
                        height: parent.height
                        radius: Theme.tileRadius
                        color: confirmMouse.containsMouse
                            ? Qt.lighter(Theme.error, 1.12)
                            : Theme.error
                        Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: root.pendingLabel === "Shutdown" ? "Shut down" : root.pendingLabel
                            color: Theme.onError
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Normal
                        }
                        MouseArea {
                            id: confirmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.confirmPowerAction()
                        }
                    }
                }
            }
        }
    }
}
