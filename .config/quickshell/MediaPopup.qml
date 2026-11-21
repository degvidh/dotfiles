import QtQuick
import QtQuick.Controls
import QtQml
import Quickshell.Services.Mpris

Rectangle {
    id: root
    visible: Hud.current === "media"
    implicitWidth: 380
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
        spacing: 12

        Row {
            width: parent.width
            height: 24
            spacing: 8
            Text { text: "󰎇"; color: Theme.primary; font.family: Theme.fontUi; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "NOW PLAYING"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody; font.weight: Font.Normal; anchors.verticalCenter: parent.verticalCenter }
            Item { width: Math.max(0, parent.width - 280); height: 1 }
            Rectangle {
                visible: Media.players.length > 1
                antialiasing: true
                width: 28; height: 24; radius: 8; color: Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰒮"; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Media.cyclePlayer(-1) }
            }
            Text {
                visible: Media.available
                text: Media.player ? Media.player.identity : ""
                color: Theme.outline
                font.family: Theme.fontUi
                font.pixelSize: Theme.fontBody
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: Math.min(70, implicitWidth)
            }
            Rectangle {
                visible: Media.players.length > 1
                antialiasing: true
                width: 28; height: 24; radius: 8; color: Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰒭"; color: Theme.text; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Media.cyclePlayer(1) }
            }
        }

        Rectangle {
            width: parent.width
            height: 112
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.surfaceHigh
            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12
                Rectangle {
                    antialiasing: true
                    width: 88; height: 88; radius: Theme.tileRadius
                    color: Theme.background
                    clip: true
                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source: Media.art
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "󰎇"
                        color: Theme.primary
                        font.family: Theme.fontUi
                        font.pixelSize: 32
                        visible: albumArt.status !== Image.Ready
                    }
                }
                Column {
                    width: parent.width - 100
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 7
                    Text {
                        width: parent.width
                        text: Media.title
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                        font.weight: Font.Normal
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: Media.artist
                        color: Theme.textMuted
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: Media.player && Media.player.trackAlbum ? Media.player.trackAlbum : ""
                        color: Theme.outline
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Slider {
            id: seekSlider
            width: parent.width
            height: 26
            from: 0
            to: Math.max(1, Media.length)
            enabled: !!Media.player && Media.player.canSeek && Media.player.positionSupported && Media.length > 0
            onMoved: Media.seek(value)
            Binding { target: seekSlider; property: "value"; value: Media.position; when: !seekSlider.pressed }
            background: Rectangle {
                x: seekSlider.leftPadding
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                width: seekSlider.availableWidth
                height: 5
                antialiasing: true
                radius: 3
                color: Theme.background
                Rectangle { antialiasing: true; width: parent.width * seekSlider.visualPosition; height: parent.height; radius: 3; color: Theme.primary }
            }
            handle: Rectangle {
                x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                antialiasing: true
                width: 13; height: 13; radius: 7; color: Theme.primary; border.width: 2; border.color: Theme.primaryInk
            }
        }

        Row {
            width: parent.width
            height: 38
            spacing: 10
            Text {
                width: 38
                text: Media.available ? root.time(Media.position) : "--:--"
                color: Theme.outline
                font.family: Theme.fontUi
                font.pixelSize: Theme.fontBody
                anchors.verticalCenter: parent.verticalCenter
            }
            Item { width: Math.max(0, (parent.width - 318) / 2); height: 1 }
            Rectangle {
                antialiasing: true
                width: 26; height: 26; radius: 13
                color: Media.player && Media.player.shuffle ? Theme.primary : Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰒟"; color: Media.player && Media.player.shuffle ? Theme.primaryInk : Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea { anchors.fill: parent; enabled: Media.player && Media.player.canControl && Media.player.shuffleSupported; cursorShape: Qt.PointingHandCursor; onClicked: Media.player.shuffle = !Media.player.shuffle }
            }
            Rectangle {
                antialiasing: true
                width: 34; height: 34; radius: 17; color: Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰒮"; color: Media.player && Media.player.canGoPrevious ? Theme.text : Theme.outline; font.family: Theme.fontUi; font.pixelSize: 16 }
                MouseArea { anchors.fill: parent; enabled: Media.player && Media.player.canGoPrevious; cursorShape: Qt.PointingHandCursor; onClicked: Media.previous() }
            }
            Rectangle {
                antialiasing: true
                width: 42; height: 42; radius: 21; color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
                Text { anchors.centerIn: parent; text: Media.player && Media.player.isPlaying ? "󰏤" : "󰐊"; color: Theme.primaryInk; font.family: Theme.fontUi; font.pixelSize: 20 }
                MouseArea { anchors.fill: parent; enabled: Media.player && Media.player.canTogglePlaying; cursorShape: Qt.PointingHandCursor; onClicked: Media.togglePlayback() }
            }
            Rectangle {
                antialiasing: true
                width: 34; height: 34; radius: 17; color: Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰒭"; color: Media.player && Media.player.canGoNext ? Theme.text : Theme.outline; font.family: Theme.fontUi; font.pixelSize: 16 }
                MouseArea { anchors.fill: parent; enabled: Media.player && Media.player.canGoNext; cursorShape: Qt.PointingHandCursor; onClicked: Media.next() }
            }
            Rectangle {
                antialiasing: true
                width: 26; height: 26; radius: 13
                color: Media.player && Media.player.loopState !== MprisLoopState.None ? Theme.primary : Theme.surfaceHigh
                Text { anchors.centerIn: parent; text: "󰑖"; color: Media.player && Media.player.loopState !== MprisLoopState.None ? Theme.primaryInk : Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
                MouseArea {
                    anchors.fill: parent
                    enabled: Media.player && Media.player.canControl && Media.player.loopSupported
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Media.player.loopState === MprisLoopState.None)
                            Media.player.loopState = MprisLoopState.Playlist
                        else if (Media.player.loopState === MprisLoopState.Playlist)
                            Media.player.loopState = MprisLoopState.Track
                        else
                            Media.player.loopState = MprisLoopState.None
                    }
                }
            }
            Item { width: Math.max(0, (parent.width - 318) / 2); height: 1 }
            Text {
                width: 38
                text: Media.available ? root.time(Media.length) : "--:--"
                color: Theme.outline
                font.family: Theme.fontUi
                font.pixelSize: Theme.fontBody
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            visible: Media.players.length === 0
            width: parent.width
            height: 30
            antialiasing: true
            radius: Theme.tileRadius
            color: Theme.background
            Text { anchors.centerIn: parent; text: "Open a player that supports MPRIS"; color: Theme.textMuted; font.family: Theme.fontUi; font.pixelSize: Theme.fontBody }
        }
    }

    function time(seconds) {
        const total = Math.max(0, Math.floor(seconds || 0))
        const minutes = Math.floor(total / 60)
        const secs = total % 60
        return minutes + ":" + (secs < 10 ? "0" : "") + secs
    }
}
