import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import QtQuick

PanelWindow {
    id: bar

    exclusiveZone: 44
    implicitHeight: 52
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    readonly property string batIcon: {
        if (Battery.charging)
            return "󰂄"

        const p = Battery.percent

        if (p >= 90) return "󰁹"
        if (p >= 70) return "󰂂"
        if (p >= 50) return "󰂀"
        if (p >= 30) return "󰁾"
        if (p >= 15) return "󰁼"
        return "󰂎"
    }

    readonly property var extraWs: {
        const out = []
        const list = Hyprland.workspaces.values

        for (let i = 0; i < list.length; i++) {
            const id = list[i].id

            if (id > 5)
                out.push(id)
        }

        out.sort(function(a, b) {
            return a - b
        })

        return out
    }

    function goWs(n) {
        const list = Hyprland.workspaces.values

        for (let i = 0; i < list.length; i++) {
            if (list[i].id === n) {
                list[i].activate()
                return
            }
        }

        Hyprland.dispatch(
            "hl.dsp.focus({ workspace = " + n + " })"
        )
    }

    function workspaceLabel(n) {
        let value = Math.trunc(n)
        if (!Number.isFinite(value) || value < 1)
            return String(n)

        const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        const numerals = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let result = ""
        for (let i = 0; i < values.length; i++) {
            while (value >= values[i]) {
                result += numerals[i]
                value -= values[i]
            }
        }
        return result
    }

    function trayDesktopId(item) {
        const names = [item.id, item.title, item.tooltipTitle]
            .filter(Boolean)
            .map(value => String(value).toLowerCase())

        // Spotify's StatusNotifier ID is not always its desktop application ID.
        if (names.some(value => value.includes("spotify")))
            return "com.spotify.Client"

        const id = item.id ? String(item.id) : ""
        return id.endsWith(".desktop") ? id.slice(0, -8) : id
    }

    function openHud(id, item) {
        const g = item.mapToGlobal(
            Qt.point(item.width / 2, 0)
        )

        Hud.toggleAt(
            id,
            Math.round(g.x),
            0
        )
    }

    Item {
        anchors.fill: parent

        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 7
        anchors.bottomMargin: 2


        // =========================================================
        // LEFT — WORKSPACES
        // =========================================================

        Rectangle {
            id: leftPill

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            height: 38
            width: leftRow.implicitWidth + 16

            radius: 19

            color: Theme.surface
            opacity: 0.96

            Behavior on width {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                id: leftRow

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8

                spacing: 3


                // -------------------------------------------------
                // NORMAL WORKSPACES
                // -------------------------------------------------

                Repeater {
                    model: 5

                    Rectangle {
                        required property int index

                        readonly property int ws: index + 1

                        readonly property bool current:
                            Hyprland.focusedWorkspace &&
                            Hyprland.focusedWorkspace.id === ws

                        readonly property bool hovered:
                            mouse.containsMouse

                        width: current ? 40 : 31
                        height: 26

                        radius: 13

                        color: current
                            ? Theme.primary
                            : hovered
                                ? Theme.surfaceHigh
                                : "transparent"

                        Behavior on width {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 160
                            }
                        }

                        scale: hovered ? 1.02 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 120
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text: bar.workspaceLabel(parent.ws)

                            color: parent.current
                                ? Theme.primaryInk
                                : Theme.text

                            font.family: Theme.fontUi
                            font.pixelSize: 13
                            font.weight: Font.Normal

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }
                        }

                        MouseArea {
                            id: mouse

                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                bar.goWs(parent.ws)
                        }
                    }
                }


                // -------------------------------------------------
                // EXTRA WORKSPACES
                // -------------------------------------------------

                Repeater {
                    model: bar.extraWs

                    Rectangle {
                        required property int modelData

                        readonly property int ws: modelData

                        readonly property bool current:
                            Hyprland.focusedWorkspace &&
                            Hyprland.focusedWorkspace.id === ws

                        readonly property bool hovered:
                            mouse.containsMouse

                        width: current ? 40 : 31
                        height: 26

                        radius: 13

                        color: current
                            ? Theme.primary
                            : hovered
                                ? Theme.surfaceHigh
                                : "transparent"

                        Behavior on width {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 160
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text: bar.workspaceLabel(parent.ws)

                            color: parent.current
                                ? Theme.primaryInk
                                : Theme.text

                            font.family: Theme.fontUi
                            font.pixelSize: 13
                            font.weight: Font.Normal
                        }

                        MouseArea {
                            id: mouse

                            anchors.fill: parent

                            cursorShape: Qt.PointingHandCursor

                            onClicked:
                                bar.goWs(parent.ws)
                        }
                    }
                }


                // -------------------------------------------------
                // ACTIVE WINDOW
                // -------------------------------------------------

                Rectangle {
                    visible: Hyprland.activeToplevel

                    width: visible
                        ? Math.min(
                            250,
                            windowTitle.implicitWidth + 18
                        )
                        : 0

                    height: 26

                    radius: 13

                    color: Theme.surfaceHigh

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        id: windowTitle

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter

                        width: Math.min(
                            232,
                            implicitWidth
                        )

                        elide: Text.ElideRight

                        text:
                            Hyprland.activeToplevel
                                ? Hyprland.activeToplevel.title
                                : ""

                        color: Theme.textMuted

                        font.family: Theme.fontUi
                        font.pixelSize: 13
                        font.weight: Font.Normal
                    }
                }
            }
        }


        // =========================================================
        // CENTER — CLOCK
        // =========================================================

        Rectangle {
            id: clockPill

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            height: 38

            width: clockContent.implicitWidth + 30

            radius: 19

            color: clockMouse.containsMouse
                ? Theme.surfaceHigh
                : Theme.surface

            opacity: 0.96

            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }

            scale: clockMouse.containsMouse ? 1.015 : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                id: clockContent
                anchors.centerIn: parent
                spacing: 7

                Text {
                    text: "󰥔"
                    color: clockMouse.containsMouse ? Theme.primary : Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 14
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: 11
                    font.weight: Font.Normal
                    font.letterSpacing: 0.6
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 1
                    height: 14
                    color: Theme.outline
                    opacity: 0.55
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    id: clockText
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: clockMouse.containsMouse ? Theme.primary : Theme.text
                    font.family: Theme.fontUi
                    font.pixelSize: 14
                    font.weight: Font.Normal
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 160 } }
                }
            }

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

            MouseArea {
                id: clockMouse

                anchors.fill: parent

                hoverEnabled: true

            }
        }


        // =========================================================
        // RIGHT — SYSTEM
        // =========================================================

        Rectangle {
            id: rightPill

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            height: 38

            width:
                rightRow.implicitWidth + 18

            radius: 19

            color: Theme.surface

            opacity: 0.96

            Row {
                id: rightRow

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 9

                spacing: 3


                // -------------------------------------------------
                // SYSTEM TRAY
                // -------------------------------------------------

                Repeater {
                    model: SystemTray.items

                    Item {
                        required property var modelData

                        Process {
                            id: launchTrayApp
                            command: ["gtk-launch", bar.trayDesktopId(modelData)]
                        }

                        width: 26
                        height: 28

                        Rectangle {
                            anchors.fill: parent

                            anchors.margins: 1

                            radius: 14

                            color:
                                trayMouse.containsMouse
                                    ? Theme.surfaceHigh
                                    : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        Image {
                            anchors.centerIn: parent

                            source:
                                modelData.icon

                            width: 14
                            height: 14

                            fillMode:
                                Image.PreserveAspectFit
                        }

                        MouseArea {
                            id: trayMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            acceptedButtons:
                                Qt.LeftButton |
                                Qt.RightButton

                            onClicked: function(ev) {
                                if (
                                    ev.button === Qt.RightButton &&
                                    modelData.hasMenu
                                ) {
                                    modelData.display(
                                        bar,
                                        0,
                                        28
                                    )
                                } else {
                                    modelData.activate()
                                    const desktopId = bar.trayDesktopId(modelData)
                                    if (desktopId)
                                        launchTrayApp.running = true
                                }
                            }
                        }
                    }
                }


                // -------------------------------------------------
                // STATUS ITEMS
                // -------------------------------------------------

                Repeater {
                    model: [
                        { id: "media", icon: "󰎇" },
                        { id: "theme", icon: "󰸉" },
                        { id: "powerplan", icon: "󰓅" },
                        { id: "brightness", icon: "󰃠" },
                        { id: "audio", icon: "󰕾" },
                        { id: "bluetooth", icon: "󰂯" },
                        { id: "wifi", icon: "󰖩" },
                        { id: "battery", icon: "󰁹" },
                        { id: "session", icon: "󰐥" }
                    ]

                    Item {
                        id: statusItem
                        required property var modelData

                        // Computed here instead of inside the model so state
                        // changes don't rebuild every bar icon.
                        readonly property bool dim:
                            modelData.id === "media" ? !Media.available
                            : modelData.id === "audio" ? Audio.muted
                            : modelData.id === "bluetooth" ? !Bluetooth.powered
                            : modelData.id === "wifi" ? !Wifi.radioOn
                            : false

                        readonly property string glyph:
                            modelData.id === "battery" ? bar.batIcon
                            : modelData.id === "media" ? (Media.player && Media.player.isPlaying ? "󰏤" : "󰎇")
                            : modelData.id === "audio" ? (Audio.muted ? "󰝟" : "󰕾")
                            : modelData.id === "bluetooth" ? (Bluetooth.powered ? "󰂯" : "󰂲")
                            : modelData.id === "wifi" ? (Wifi.radioOn ? "󰖩" : "󰖪")
                            : modelData.icon

                        width: 28
                        height: 28

                        Rectangle {
                            anchors.fill: parent

                            radius: 14

                            color:
                                statusMouse.containsMouse
                                    ? Theme.surfaceHigh
                                    : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text: statusItem.glyph

                            color:
                                (
                                    modelData.id === "battery" &&
                                    Battery.percent <= 15 &&
                                    !Battery.charging
                                )
                                    ? Theme.error
                                    : statusItem.dim
                                        ? Theme.outline
                                        : Theme.textMuted

                            font.family:
                                "Noto Sans"

                            font.pixelSize: Theme.fontBody

                            scale:
                                statusMouse.containsMouse
                                ? 1.07
                                    : 1.0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 120
                                    easing.type:
                                        Easing.OutCubic
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 140
                                }
                            }
                        }

                        MouseArea {
                            id: statusMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                bar.openHud(
                                    modelData.id,
                                    parent
                                )
                        }
                    }
                }
            }
        }
    }
}
