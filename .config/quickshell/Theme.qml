pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property color background: Colors.background
    readonly property color surface: Colors.surface
    readonly property color surfaceHigh: Colors.surfaceHigh
    readonly property color text: Colors.text
    readonly property color textMuted: Colors.textMuted
    readonly property color primary: Colors.primary
    readonly property color primaryInk: Colors.primaryInk
    readonly property color secondary: Colors.secondary
    readonly property color outline: Colors.outline
    readonly property color error: Colors.error
    readonly property color onError: Colors.onError
    readonly property int radius: 8
    readonly property int tileRadius: 8
    readonly property int radiusSmall: 8
    readonly property int pad: 12
    readonly property string fontUi: "Noto Sans"
    readonly property string fontMono: "JetBrains Mono"
    readonly property int fontBody: 14
    readonly property int motionFast: 140
    readonly property int motion: 220
}
