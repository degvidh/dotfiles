pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property int volume: sink && sink.ready && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink && sink.ready && sink.audio ? sink.audio.muted : false
    readonly property int micVolume: source && source.ready && source.audio ? Math.round(source.audio.volume * 100) : 0
    readonly property bool micMuted: source && source.ready && source.audio ? source.audio.muted : false

    readonly property var outputs: {
        const out = []
        const nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i]
            if (!node.isStream && node.isSink && node.audio)
                out.push({ node: node, name: node.description || node.nickname || node.name, active: node === sink })
        }
        return out
    }

    readonly property var inputs: {
        const out = []
        const nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            const node = nodes[i]
            if (!node.isStream && !node.isSink && node.audio)
                out.push({ node: node, name: node.description || node.nickname || node.name, active: node === source })
        }
        return out
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    function setVolume(value) {
        if (sink && sink.ready && sink.audio)
            sink.audio.volume = Math.max(0, Math.min(1.5, value / 100))
    }

    function setMicVolume(value) {
        if (source && source.ready && source.audio)
            source.audio.volume = Math.max(0, Math.min(1.5, value / 100))
    }

    function toggleMute() {
        if (sink && sink.ready && sink.audio)
            sink.audio.muted = !sink.audio.muted
    }

    function toggleMicMute() {
        if (source && source.ready && source.audio)
            source.audio.muted = !source.audio.muted
    }

    function setOutput(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function setInput(node) {
        Pipewire.preferredDefaultAudioSource = node
    }
}
