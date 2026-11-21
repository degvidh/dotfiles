pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    property string current: ""
    property int anchorX: 0

    property string osdKind: ""
    property bool osdVisible: false

    Timer {
        id: osdHide
        interval: 1800
        onTriggered: {
            root.osdKind = ""
            osdClose.restart()
        }
    }

    Timer {
        id: osdClose
        interval: 220
        onTriggered: root.osdVisible = false
    }

    function showOsd(kind) {
        root.osdKind = kind
        root.osdVisible = true
        osdClose.stop()
        if (kind === "brightness")
            Brightness.refresh()
        osdHide.restart()
    }

    function close() {
        root.current = ""
    }

    function toggleAt(id, x, y) {
        root.anchorX = x
        if (root.current === id) {
            root.current = ""
            return
        }
        root.current = id
        if (id === "wifi")
            Wifi.onShown()
        else if (id === "bluetooth")
            Bluetooth.onShown()
        else if (id === "brightness")
            Brightness.refresh()
        else if (id === "battery")
            Battery.refresh()
        else if (id === "powerplan")
            PowerPlan.refresh()
    }
}
