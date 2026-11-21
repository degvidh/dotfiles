pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property string selectedPlayer: ""
    readonly property var players: Mpris.players.values

    readonly property var player: {
        const list = Mpris.players.values
        if (!list.length) return null
        if (selectedPlayer) {
            for (let i = 0; i < list.length; i++)
                if (list[i].dbusName === selectedPlayer) return list[i]
        }
        for (let i = 0; i < list.length; i++)
            if (list[i].isPlaying) return list[i]
        return list[0]
    }

    readonly property bool available: player !== null
    readonly property string title: player ? (player.trackTitle || "Unknown track") : "Nothing playing"
    readonly property string artist: player ? (player.trackArtist || player.identity) : "Start music in any app"
    readonly property string art: player ? player.trackArtUrl : ""
    readonly property real position: player ? player.position : 0
    readonly property real length: player ? player.length : 0

    Timer {
        interval: 1000
        repeat: true
        running: !!root.player && root.player.isPlaying
        onTriggered: if (root.player) root.player.positionChanged()
    }

    function cyclePlayer(direction) {
        const list = Mpris.players.values
        if (!list.length) return
        let index = -1
        for (let i = 0; i < list.length; i++)
            if (list[i] === player) index = i
        index = (index + direction + list.length) % list.length
        selectedPlayer = list[index].dbusName
    }

    function previous() { if (player && player.canGoPrevious) player.previous() }
    function next() { if (player && player.canGoNext) player.next() }
    function togglePlayback() { if (player && player.canTogglePlaying) player.togglePlaying() }
    function seek(value) { if (player && player.canSeek && player.positionSupported) player.position = value }
}
