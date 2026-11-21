pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property int percent: 0
    property int keyboardPercent: 0
    property bool keyboardPresent: false
    property int pendingPercent: -1
    property int pendingKeyboardPercent: -1
    property int sentPercent: -1
    property int sentKeyboardPercent: -1

    function refresh() {
        if (!getProc.running) getProc.running = true
        if (!keyboardProc.running) keyboardProc.running = true
    }

    function nudge(spec) {
        setProc.command = ["brightnessctl", "set", spec]
        setProc.running = true
    }

    function setPercent(value) {
        pendingPercent = Math.max(1, Math.min(100, Math.round(value)))
        setTimer.restart()
    }

    function setKeyboardPercent(value) {
        pendingKeyboardPercent = Math.max(0, Math.min(100, Math.round(value)))
        keyboardSetTimer.restart()
    }

    Timer {
        id: setTimer
        interval: 80
        onTriggered: {
            if (root.pendingPercent < 0 || setProc.running) return
            root.sentPercent = root.pendingPercent
            setProc.command = ["brightnessctl", "set", root.sentPercent + "%"]
            setProc.running = true
        }
    }

    Timer {
        id: keyboardSetTimer
        interval: 80
        onTriggered: {
            if (root.pendingKeyboardPercent < 0 || keyboardSetProc.running) return
            root.sentKeyboardPercent = root.pendingKeyboardPercent
            keyboardSetProc.command = ["brightnessctl", "-d", "platform::kbd_backlight", "set", root.sentKeyboardPercent + "%"]
            keyboardSetProc.running = true
        }
    }

    Timer { interval: 2500; running: true; repeat: true; onTriggered: root.refresh() }
    Component.onCompleted: root.refresh()

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                if (parts.length > 3)
                    root.percent = parseInt(parts[3]) || 0
            }
        }
    }

    Process {
        id: keyboardProc
        command: ["brightnessctl", "-m", "-d", "platform::kbd_backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                root.keyboardPresent = parts.length > 3 && parts[1] === "leds"
                if (root.keyboardPresent)
                    root.keyboardPercent = parseInt(parts[3]) || 0
            }
        }
    }

    Process {
        id: setProc
        stdout: StdioCollector {}
        onExited: {
            if (root.pendingPercent !== root.sentPercent) setTimer.restart()
            else root.refresh()
        }
    }

    Process {
        id: keyboardSetProc
        stdout: StdioCollector {}
        onExited: {
            if (root.pendingKeyboardPercent !== root.sentKeyboardPercent) keyboardSetTimer.restart()
            else root.refresh()
        }
    }
}
