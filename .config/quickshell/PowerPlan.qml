pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property string current: ""

    function refresh() { getProc.running = true }

    function setPlan(name) {
        setProc.command = ["powerprofilesctl", "set", name]
        setProc.running = true
    }

    Process {
        id: getProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector { onStreamFinished: root.current = text.trim() }
    }

    Process {
        id: setProc
        stdout: StdioCollector {}
        onExited: root.refresh()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
