pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    property bool powered: false
    property var devices: []
    property var pairedDevices: []
    property bool scanning: false
    property string status: ""
    readonly property var nearbyDevices: {
        const paired = {}
        for (let i = 0; i < pairedDevices.length; i++) paired[pairedDevices[i].mac] = true
        const out = []
        for (let i = 0; i < devices.length; i++)
            if (!paired[devices[i].mac]) out.push(devices[i])
        return out
    }

    function onShown() {
        powerQuery.running = true
        listProc.running = true
        pairedProc.running = true
    }

    function scan() {
        if (!powered) { status = "Turn Bluetooth on to scan"; return }
        status = "Scanning nearby devices…"
        scanning = true
        scanProc.running = true
    }

    function togglePower() {
        powerSet.command = ["bluetoothctl", "power", root.powered ? "off" : "on"]
        powerSet.running = true
    }

    // Avoid rebuilding device lists (and resetting scroll/hover) every poll.
    function sameDevices(left, right) {
        if (left.length !== right.length) return false
        for (let i = 0; i < left.length; i++) {
            if (left[i].mac !== right[i].mac || left[i].name !== right[i].name)
                return false
        }
        return true
    }

    function connectTo(mac) {
        root.pendingMac = mac
        let paired = false
        for (let i = 0; i < pairedDevices.length; i++)
            if (pairedDevices[i].mac === mac) paired = true
        if (paired) {
            trustProc.command = ["bluetoothctl", "trust", mac]
            trustProc.running = true
            return
        }
        pairProc.command = ["bluetoothctl", "pair", mac]
        pairProc.running = true
    }
    property string pendingMac: ""

    Process {
        id: powerQuery
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.powered = /Powered:\s+yes/.test(text)
        }
    }

    Process {
        id: powerSet
        stdout: StdioCollector {}
        onExited: onShown()
    }

    Process {
        id: listProc
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const m = lines[i].match(/^Device\s+(\S+)\s+(.+)$/)
                    if (m)
                        out.push({ mac: m[1], name: m[2] })
                }
                if (!root.sameDevices(root.devices, out))
                    root.devices = out
            }
        }
    }

    Process {
        id: pairedProc
        command: ["bluetoothctl", "devices", "Paired"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const m = lines[i].match(/^Device\s+(\S+)\s+(.+)$/)
                    if (m) out.push({ mac: m[1], name: m[2] })
                }
                if (!root.sameDevices(root.pairedDevices, out))
                    root.pairedDevices = out
            }
        }
    }

    Process {
        id: scanProc
        command: ["bluetoothctl", "--timeout", "8", "scan", "on"]
        stdout: StdioCollector {}
        onExited: {
            root.scanning = false
            root.status = "Scan complete"
            listProc.running = true
            pairedProc.running = true
        }
    }

    Process {
        id: pairProc
        property string output: ""
        stdout: StdioCollector {
            onStreamFinished: pairProc.output = text
        }
        onExited: function(code) {
            if (code !== 0 || /failed/i.test(pairProc.output)) {
                root.status = "Could not pair device"
                return
            }
            root.status = "Paired · trusting device…"
            trustProc.command = ["bluetoothctl", "trust", root.pendingMac]
            trustProc.running = true
        }
    }

    Process {
        id: trustProc
        stdout: StdioCollector {}
        onExited: {
            root.status = "Connecting…"
            connProc.command = ["bluetoothctl", "connect", root.pendingMac]
            connProc.running = true
        }
    }

    Process {
        id: connProc
        property string output: ""
        stdout: StdioCollector {
            onStreamFinished: connProc.output = text
        }
        onExited: function(code) {
            root.onShown()
            root.status = code === 0 && !/failed/i.test(connProc.output)
                ? "Connected"
                : "Could not connect"
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            powerQuery.running = true
            if (root.powered) {
                listProc.running = true
                pairedProc.running = true
            }
        }
    }
    Component.onCompleted: root.onShown()
}
