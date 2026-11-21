import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    Bar {}

    IpcHandler {
        target: "hud"

        function toggleAt(id: string, x: int, y: int): void {
            Hud.toggleAt(id, x, y)
        }

        function osd(kind: string): void {
            Hud.showOsd(kind)
        }
    }

    PanelWindow {
        visible: Hud.current !== ""
        // Every popup (not just the theme picker) needs keyboard focus so text
        // fields such as the Wi-Fi password field can be typed into.
        focusable: Hud.current !== ""
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            z: 0
            onClicked: Hud.close()
        }

        Loader {
            z: 1
            width: item ? item.implicitWidth : 0
            height: item ? item.implicitHeight : 0
            y: Hud.current === "theme"
                ? Math.max(12, (parent.height - height) / 2)
                : 10
            x: {
                const sw = parent.width
                const pw = width
                const raw = Hud.anchorX - pw / 2
                if (Hud.current === "theme")
                    return Math.max(12, (sw - pw) / 2)
                return Math.max(10, Math.min(sw - pw - 10, raw))
            }
            sourceComponent: {
                switch (Hud.current) {
                case "wifi": return wifiComp
                case "audio": return audioComp
                case "media": return mediaComp
                case "bluetooth": return btComp
                case "brightness": return brightComp
                case "battery": return batComp
                case "powerplan": return planComp
                case "session": return sessComp
                case "theme": return themeComp
                default: return null
                }
            }
        }

        Component { id: wifiComp; WifiPopup {} }
        Component { id: audioComp; AudioPopup {} }
        Component { id: mediaComp; MediaPopup {} }
        Component { id: btComp; BluetoothPopup {} }
        Component { id: brightComp; BrightnessPopup {} }
        Component { id: batComp; BatteryPopup {} }
        Component { id: planComp; PowerPlanPopup {} }
        Component { id: sessComp; SessionPopup {} }
        Component { id: themeComp; ThemePopup {} }
    }

    PanelWindow {
        visible: Hud.osdVisible
        exclusiveZone: 0
        implicitWidth: 400
        implicitHeight: 76
        color: "transparent"

        anchors {
            bottom: true
            left: true
            right: true
        }

        margins {
            bottom: 64
            left: Math.max(20, (screen ? screen.width : 1920) / 2 - 200)
            right: Math.max(20, (screen ? screen.width : 1920) / 2 - 200)
        }

        OsdBar {}
    }
}
