import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 900
    implicitHeight: 620

    property var files: []
    property string selected: ""
    property string query: ""
    property string status: "Tap a wallpaper to apply it and match your colors"
    property string applyStdout: ""
    property string applyStderr: ""
    property string matugenError: ""
    property bool applying: false
    property bool entered: false

    readonly property var filteredFiles: {
        const needle = query.trim().toLowerCase()
        if (!needle) return files
        return files.filter(path => path.toLowerCase().includes(needle))
    }

    function cleanError(value) {
        return value.replace(/\u001b\[[0-9;]*m/g, "").replace(/\s+/g, " ").trim()
    }

    function applyWallpaper(path) {
        if (applying || !path) return
        selected = path
        applying = true
        applyStdout = ""
        applyStderr = ""
        matugenError = ""
        status = "Setting wallpaper and building its color palette…"
        wallpaperApply.command = ["/home/david/.local/bin/qs-wallpaper-apply", path]
        wallpaperApply.running = true
    }

    Process {
        id: scan
        command: ["find", "/home/david/.local/share/waywallen/remote/wallhaven", "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")", "-print"]
        stdout: StdioCollector {
            onStreamFinished: {
                const paths = text.trim().split("\n").filter(path => path.length > 0)
                paths.sort((a, b) => a.localeCompare(b))
                root.files = paths
                Qt.callLater(() => gallery.positionViewAtBeginning())
            }
        }
    }

    Process {
        id: wallpaperApply
        stdout: StdioCollector { onStreamFinished: root.applyStdout = text.trim() }
        stderr: StdioCollector { onStreamFinished: root.applyStderr = root.cleanError(text) }
        onExited: function(code) {
            if (code === 0) {
                root.status = "Wallpaper set · updating colors…"
                // qs-wallpaper-apply only applies the wallpaper; Matugen is run
                // here exactly once so two writers never race over palette.json.
                imageTheme.command = [
                    "matugen", "image", root.selected,
                    "--mode", "dark",
                    "--prefer", "saturation"
                ]
                imageTheme.running = true
            } else {
                root.applying = false
                root.status = root.applyStderr || root.applyStdout || "Waywallen could not apply that wallpaper"
            }
        }
    }

    Process {
        id: imageTheme
        stdout: StdioCollector {}
        stderr: StdioCollector { onStreamFinished: root.matugenError = root.cleanError(text) }
        onExited: function(code) {
            root.applying = false
            if (code === 0) {
                Colors.refreshPalette()
                root.status = "Wallpaper and matching colors applied"
                Hud.close()
            } else {
                root.status = root.matugenError
                    ? "Wallpaper set · Matugen: " + root.matugenError
                    : "Wallpaper set, but Matugen exited with code " + code
            }
        }
    }

    opacity: entered ? 1 : 0
    scale: entered ? 1 : 0.985
    Behavior on opacity { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: Theme.motion; easing.type: Easing.OutCubic } }

    focus: true
    Keys.onEscapePressed: function(event) {
        if (!root.applying)
            Hud.close()
        event.accepted = true
    }

    Component.onCompleted: {
        entered = true
        scan.running = true
        Qt.callLater(() => search.forceActiveFocus())
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.surface
        border.width: 1
        border.color: Theme.outline
        clip: true

        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            Row {
                width: parent.width
                height: 58
                spacing: 14

                Column {
                    width: parent.width - closeButton.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        text: "Personalize your desktop"
                        color: Theme.text
                        font.family: Theme.fontUi
                        font.pixelSize: 24
                        font.weight: Font.Normal
                    }
                    Text {
                        text: "Wallhaven library · click a wallpaper to apply it"
                        color: Theme.textMuted
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                    }
                }

                Rectangle {
                    id: closeButton
                    width: 38
                    height: 38
                    radius: Theme.radius
                    anchors.verticalCenter: parent.verticalCenter
                    color: closeMouse.containsMouse ? Theme.surfaceHigh : "transparent"
                    Text { anchors.centerIn: parent; text: "󰅖"; color: Theme.text; font.pixelSize: 16 }
                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.applying
                        onClicked: Hud.close()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.outline; opacity: 0.35 }

            Row {
                width: parent.width
                height: 44
                spacing: 10

                Rectangle {
                    width: parent.width - refresh.width - parent.spacing
                    height: parent.height
                    radius: Theme.radius
                    color: Theme.background
                    border.width: search.activeFocus ? 1 : 0
                    border.color: Theme.primary
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 13
                        anchors.verticalCenter: parent.verticalCenter
                        text: "⌕"
                        color: Theme.textMuted
                        font.pixelSize: 18
                    }
                    TextField {
                        id: search
                        anchors.fill: parent
                        anchors.leftMargin: 38
                        placeholderText: "Search downloaded wallpapers"
                        color: Theme.text
                        placeholderTextColor: Theme.outline
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.fontBody
                        background: Item {}
                        onTextChanged: root.query = text
                    }
                }

                Rectangle {
                    id: refresh
                    width: 44
                    height: 44
                    radius: Theme.radius
                    color: refreshMouse.containsMouse ? Theme.surfaceHigh : Theme.background
                    Text { anchors.centerIn: parent; text: "󰑐"; color: Theme.text; font.pixelSize: 18 }
                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.applying
                        onClicked: scan.running = true
                    }
                }
            }

            GridView {
                id: gallery
                width: parent.width
                height: parent.height - 175
                clip: true
                cellWidth: width / Math.max(1, Math.floor(width / 250))
                cellHeight: 178
                model: root.filteredFiles
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    id: tile
                    required property string modelData
                    property string thumbnailUrl: ""

                    width: gallery.cellWidth - 12
                    height: gallery.cellHeight - 10
                    x: 6
                    y: 5
                    radius: Theme.radius
                    color: Theme.surfaceHigh
                    border.width: root.selected === modelData ? 2 : 1
                    border.color: root.selected === modelData ? Theme.primary : Theme.outline
                    clip: true
                    scale: tileMouse.containsMouse && !root.applying ? 1.015 : 1
                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        color: Theme.background
                        Text {
                            anchors.centerIn: parent
                            text: "󰸉"
                            color: Theme.outline
                            font.pixelSize: 26
                        }
                    }

                    Process {
                        id: thumbnailJob
                        command: ["/home/david/.local/bin/qs-wallpaper-thumbnail", tile.modelData]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                const path = text.trim()
                                if (path.length) tile.thumbnailUrl = "file://" + path
                            }
                        }
                    }

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: tile.thumbnailUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: status === Image.Ready
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 38
                        color: Theme.background
                        opacity: 0.94
                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: tile.modelData.split("/").pop().replace(/\.[^.]+$/, "")
                            color: Theme.text
                            elide: Text.ElideMiddle
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                        }
                    }

                    Rectangle {
                        visible: root.selected === tile.modelData && root.applying
                        anchors.fill: parent
                        color: "#88000000"
                        Text {
                            anchors.centerIn: parent
                            text: "Applying…"
                            color: "white"
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.Normal
                        }
                    }

                    Rectangle {
                        visible: root.selected === tile.modelData && !root.applying
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        width: 26
                        height: 26
                        radius: 13
                        color: Theme.primary
                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Theme.primaryInk
                            font.family: Theme.fontUi
                            font.pixelSize: 15
                            font.weight: Font.Normal
                        }
                    }

                    MouseArea {
                        id: tileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !root.applying
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.applyWallpaper(tile.modelData)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredFiles.length === 0
                    text: "No matching wallpapers found"
                    color: Theme.textMuted
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                }
            }

            Row {
                width: parent.width
                height: 24
                spacing: 14

                Text {
                    width: parent.width - galleryCount.width - parent.spacing
                    text: root.status
                    color: root.status.includes("Matugen") || root.status.includes("could not") || root.status.includes("failed") || root.status.includes("exited with code")
                        ? Theme.error : Theme.textMuted
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    font.family: Theme.fontUi
                    font.pixelSize: Theme.fontBody
                }
                Text {
                    id: galleryCount
                    text: root.filteredFiles.length + " wallpapers"
                    color: Theme.outline
                    verticalAlignment: Text.AlignVCenter
                    font.family: Theme.fontUi
                    font.pixelSize: 12
                }
            }
        }
    }
}
