pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool scanning: false
    property bool radioOn: true
    property var networks: []
    property var savedNetworks: []
    property string status: ""
    property string selectedSsid: ""
    property bool passwordRequired: false
    property string passwordError: ""

    property string connectingSsid: ""
    property bool connectingLocked: false
    property bool connectingSaved: false

    readonly property var connected: {
        for (let i = 0; i < networks.length; i++) {
            if (networks[i].used)
                return networks[i]
        }
        return null
    }

    readonly property var others: {
        const out = []
        for (let i = 0; i < networks.length; i++) {
            if (!networks[i].used)
                out.push(networks[i])
        }
        return out
    }

    // nmcli -t escapes ":" and "\" inside values, so a plain split(":") breaks
    // SSIDs containing a colon or a backslash.
    function splitTerse(line) {
        const out = []
        let field = ""
        for (let i = 0; i < line.length; i++) {
            const ch = line[i]
            if (ch === "\\" && i + 1 < line.length) {
                field += line[i + 1]
                i++
            } else if (ch === ":") {
                out.push(field)
                field = ""
            } else {
                field += ch
            }
        }
        out.push(field)
        return out
    }

    function cleanMessage(value) {
        const line = String(value || "").split("\n")
            .map(part => part.replace(/\u001b\[[0-9;]*m/g, "").trim())
            .filter(part => part.length > 0)[0] || ""
        return line.replace(/^Error:\s*/i, "")
    }

    function isSaved(ssid) {
        return savedNetworks.indexOf(ssid) !== -1
    }

    function toggleRadio() {
        radioSet.command = ["nmcli", "radio", "wifi", root.radioOn ? "off" : "on"]
        radioSet.running = true
    }

    function scan() {
        if (!root.radioOn) {
            root.networks = []
            root.status = "off"
            root.scanning = false
            return
        }
        root.scanning = true
        root.status = "Scanning for networks…"
        listProc.running = true
    }

    function onShown() {
        radioQuery.running = true
        savedProc.running = true
        scan()
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            radioQuery.running = true
            if (root.radioOn)
                stateProc.running = true
        }
    }

    function connectSaved(name) {
        root.connectingSsid = name
        root.connectingSaved = true
        root.connectingLocked = true
        root.status = "Connecting to " + name + "…"
        root.passwordRequired = false
        root.passwordError = ""
        savedConnectProc.command = ["nmcli", "connection", "up", "id", name]
        savedConnectProc.running = true
    }

    function connectTo(ssid, password) {
        root.connectingSsid = ssid
        root.connectingSaved = false
        root.status = "Connecting to " + ssid + "…"
        root.passwordError = ""
        root.selectedSsid = ""
        root.passwordRequired = false
        connectProc.command = password && password.length
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid]
        connectProc.running = true
    }

    function cancelPassword() {
        root.passwordRequired = false
        root.selectedSsid = ""
        root.passwordError = ""
        root.status = "on"
    }

    function selectNetwork(network) {
        if (root.isSaved(network.ssid)) {
            root.connectSaved(network.ssid)
            return
        }
        if (network.locked) {
            root.selectedSsid = network.ssid
            root.connectingLocked = true
            root.connectingSaved = false
            root.passwordRequired = true
            root.passwordError = ""
            root.status = "Enter the password for " + network.ssid
        } else {
            root.connectingLocked = false
            root.connectTo(network.ssid, "")
        }
    }

    function openEditor() {
        Quickshell.execDetached([
            "sh", "-c",
            "command -v nm-connection-editor >/dev/null 2>&1 && exec nm-connection-editor; " +
            "command -v ghostty >/dev/null 2>&1 && exec ghostty -e nmtui; " +
            "exec nmtui"
        ])
    }

    Process {
        id: radioQuery
        command: ["nmcli", "-t", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.radioOn = text.trim() === "enabled"
                if (!root.radioOn) {
                    root.networks = []
                    root.status = "off"
                    root.scanning = false
                }
            }
        }
    }

    Process {
        id: radioSet
        stdout: StdioCollector {}
        onExited: function(code) {
            radioQuery.running = true
            if (code === 0)
                scan()
        }
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const out = []
                const seen = {}
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i]
                    if (!line)
                        continue
                    const parts = root.splitTerse(line)
                    if (parts.length < 4)
                        continue
                    const ssid = parts.slice(3).join(":")
                    if (!ssid || ssid === "--" || seen[ssid])
                        continue
                    seen[ssid] = true
                    const sec = parts[2]
                    out.push({
                        used: parts[0].trim() === "*",
                        signal: parts[1],
                        locked: sec.length > 0 && sec !== "--",
                        ssid: ssid
                    })
                }
                root.networks = out
                root.scanning = false
                root.status = out.length ? "on" : "no networks"
            }
        }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    if (!lines[i]) continue
                    const parts = root.splitTerse(lines[i])
                    const type = parts.pop()
                    const name = parts.join(":")
                    if (type === "802-11-wireless") out.push(name)
                }
                root.savedNetworks = out
            }
        }
    }

    Process {
        id: savedConnectProc
        stderr: StdioCollector {
            onStreamFinished: root.status = root.cleanMessage(text) || "Could not connect"
        }
        onExited: function(code) {
            if (code === 0) {
                root.status = "Connected"
                listProc.running = true
            } else if (root.status === "") {
                root.status = "Could not connect"
            }
        }
    }

    Process {
        id: stateProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID", "device", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                let activeSsid = ""
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const parts = root.splitTerse(lines[i])
                    if (parts.length > 1 && parts[0].trim() === "*") {
                        activeSsid = parts.slice(1).join(":")
                        break
                    }
                }
                // Nothing changed: keep the existing model so open lists don't
                // rebuild (and jump) every three seconds.
                const current = root.connected ? root.connected.ssid : ""
                if (activeSsid === current)
                    return
                const updated = []
                let found = false
                for (let i = 0; i < root.networks.length; i++) {
                    const isActive = !!activeSsid && root.networks[i].ssid === activeSsid
                    if (isActive) found = true
                    updated.push(Object.assign({}, root.networks[i], { used: isActive }))
                }
                if (activeSsid && !found)
                    updated.unshift({ used: true, ssid: activeSsid, locked: true, signal: "" })
                root.networks = updated
            }
        }
    }

    Process {
        id: connectProc
        stderr: StdioCollector {
            onStreamFinished: root.status = root.cleanMessage(text) || "Could not connect"
        }
        onExited: function(code) {
            if (code === 0) {
                root.status = "Connected"
                root.passwordRequired = false
                root.passwordError = ""
                listProc.running = true
                return
            }
            if (root.connectingLocked && !root.connectingSaved && root.connectingSsid) {
                // Keep the prompt open so a typo can be corrected immediately.
                root.selectedSsid = root.connectingSsid
                root.passwordRequired = true
                root.passwordError = root.status
                root.status = "Wrong password? Try again"
            } else if (root.status === "") {
                root.status = "Could not connect"
            }
        }
    }
}
