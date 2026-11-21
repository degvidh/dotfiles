pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int percent: 0
    property string status: "Unknown"
    property real watts: 0
    property int minutesLeft: -1
    property bool charging: false
    property bool onAc: false
    property bool present: false

    readonly property string statusLabel: {
        if (status === "Charging")
            return "Charging"
        if (status === "Full")
            return "Full"
        if (status === "Discharging")
            return onAc ? "On AC" : "Discharging"
        if (status === "Not charging")
            return "Plugged"
        return status
    }

    readonly property string timeLabel: {
        if (minutesLeft < 0)
            return ""
        const h = Math.floor(minutesLeft / 60)
        const m = minutesLeft % 60
        const tail = status === "Charging" ? "to full" : "left"
        if (h <= 0)
            return m + "m " + tail
        return h + "h " + m + "m " + tail
    }

    function refresh() {
        readProc.running = true
    }

    Process {
        id: readProc
        command: [
            "sh", "-c",
            "b=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1); " +
            "a=$(ls -d /sys/class/power_supply/AC* /sys/class/power_supply/ADP* /sys/class/power_supply/ACAD 2>/dev/null | head -n1); " +
            "if [ -z \"$b\" ]; then echo '0|Missing|0|-1|0|0'; exit 0; fi; " +
            "cap=$(cat \"$b/capacity\" 2>/dev/null || echo 0); " +
            "st=$(cat \"$b/status\" 2>/dev/null || echo Unknown); " +
            "en=$(cat \"$b/energy_now\" 2>/dev/null || echo 0); " +
            "ef=$(cat \"$b/energy_full\" 2>/dev/null || echo 0); " +
            "pw=$(cat \"$b/power_now\" 2>/dev/null || echo 0); " +
            "if [ \"$pw\" = 0 ]; then " +
            "  cu=$(cat \"$b/current_now\" 2>/dev/null || echo 0); " +
            "  vu=$(cat \"$b/voltage_now\" 2>/dev/null || echo 0); " +
            "  pw=$((cu * vu / 1000000)); " +
            "fi; " +
            "ac=0; [ -n \"$a\" ] && [ \"$(cat \"$a/online\" 2>/dev/null)\" = 1 ] && ac=1; " +
            "mins=-1; " +
            "if [ \"$pw\" -gt 0 ]; then " +
            "  if [ \"$st\" = Discharging ] && [ \"$en\" -gt 0 ]; then mins=$((en * 60 / pw)); fi; " +
            "  if [ \"$st\" = Charging ] && [ \"$ef\" -gt \"$en\" ]; then mins=$(((ef - en) * 60 / pw)); fi; " +
            "fi; " +
            "echo \"$cap|$st|$pw|$mins|$ac|1\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|")
                if (p.length < 6)
                    return
                root.percent = parseInt(p[0]) || 0
                root.status = p[1]
                root.watts = (parseInt(p[2]) || 0) / 1000000
                root.minutesLeft = parseInt(p[3])
                root.onAc = p[4] === "1"
                root.present = p[5] === "1"
                root.charging = root.status === "Charging" || root.status === "Full"
            }
        }
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
