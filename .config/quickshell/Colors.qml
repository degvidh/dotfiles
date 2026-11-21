pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: colors

    property var palette: ({})
    property string loadedText: ""

    function refreshPalette() {
        paletteFile.reload()
    }

    function readPalette() {
        const raw = paletteFile.text()
        if (raw === colors.loadedText)
            return
        try {
            const parsed = JSON.parse(raw)
            if (!parsed || typeof parsed !== "object" || Array.isArray(parsed))
                throw new Error("palette is not a JSON object")
            colors.loadedText = raw
            colors.palette = parsed
        } catch (error) {
            // Most likely caught Matugen mid-write; the poll below retries.
            console.warn("quickshell: ignoring incomplete palette.json:", error)
        }
    }

    FileView {
        id: paletteFile
        path: "/home/david/.config/quickshell/palette.json"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
        onLoaded: colors.readPalette()
    }

    // FileView can lose its inotify watch when Matugen replaces the file, so
    // check for external changes at a low frequency as a fallback.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: paletteFile.reload()
    }

    readonly property color background: palette.background || "#171214"
    readonly property color surface: palette.surface || "#231a1c"
    readonly property color surfaceHigh: palette.surfaceHigh || "#302527"
    readonly property color text: palette.text || "#f3e8e7"
    readonly property color textMuted: palette.textMuted || "#d5c4c2"
    readonly property color primary: palette.primary || "#ffb3af"
    readonly property color primaryInk: palette.primaryInk || "#571d1d"
    readonly property color secondary: palette.secondary || "#e7bdba"
    readonly property color outline: palette.outline || "#9c8786"
    readonly property color error: palette.error || "#ffb4ab"
    readonly property color onError: palette.onError || "#690005"
}
