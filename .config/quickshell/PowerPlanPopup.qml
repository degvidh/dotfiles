import QtQuick

Rectangle {
    id: root
    visible: Hud.current === "powerplan"
    implicitWidth: 276
    implicitHeight: col.implicitHeight + 28
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
        id: col
        width: parent.width - 24
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        spacing: 6

        Text {
            width: parent.width
            text: "POWER PROFILE"
            color: Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontUi
            font.pixelSize: 12
            font.weight: Font.Normal
            font.letterSpacing: 0.7
        }

        Repeater {
            model: [
                { id: "performance", label: "Performance", detail: "Fast response · higher draw", icon: "󰓅" },
                { id: "balanced", label: "Balanced", detail: "Everyday use", icon: "󰾆" },
                { id: "power-saver", label: "Power saver", detail: "Longer battery life", icon: "󰌪" }
            ]
            Rectangle {
                required property var modelData
                width: col.width
                height: 54
                antialiasing: true
                radius: Theme.tileRadius
                color: PowerPlan.current === modelData.id
                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
                    : planMouse.containsMouse
                        ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
                        : Theme.surfaceHigh
                border.width: PowerPlan.current === modelData.id ? 1 : 0
                border.color: Theme.primary
                Behavior on color { ColorAnimation { duration: Theme.motionFast } }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 13
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.icon
                    color: PowerPlan.current === modelData.id ? Theme.primary : Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 19
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 45
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    color: Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Normal
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 45
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    text: modelData.detail
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 11
                    font.weight: Font.Normal
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    visible: PowerPlan.current === modelData.id
                    text: "󰄬"
                    color: Theme.primary
                    font.family: Theme.fontUi
                    font.pixelSize: 18
                }
                MouseArea { id: planMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: PowerPlan.setPlan(modelData.id) }
            }
        }
    }
}
