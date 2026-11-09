// RentPassQuality.qml — quality choice after a valid redeem, before Play.
// The customer picks a stream quality (bitrate) and a frame rate so a
// low-end laptop still gets a smooth stream. Default is High / 60 FPS,
// which is the HD behaviour from the server config, so existing users
// are unaffected. The choice is written to the same settings the stream
// reads (Chiaki.settings bitrate/fps for PS5, local AND remote) before
// the main view / Play appears, so it takes effect for this session.
// This screen is part of the redeem flow only — there is no settings
// menu anywhere else. ALL text is English.

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

Item {
    id: root

    // Emitted when the customer confirms. The caller (Main.qml) then
    // shows the RentPass main view (Play Now).
    signal qualityConfirmed()

    property int timeRemaining: 0

    // Bitrate in kbps. Low = 10000, Medium = 25000, High = 50000.
    // Applied to BOTH local and remote bitrate.
    property int selectedBitrate: 50000
    property int selectedFps: 60

    Material.theme: Material.Dark
    Material.accent: "#96a6fd"

    function formatTime(seconds) {
        var s = Math.max(0, seconds)
        var h = Math.floor(s / 3600)
        var m = Math.floor((s % 3600) / 60)
        var sec = s % 60
        return (h < 10 ? "0" + h : h) + ":" +
               (m < 10 ? "0" + m : m) + ":" +
               (sec < 10 ? "0" + sec : sec)
    }

    Rectangle {
        anchors.fill: parent
        color: "#0a0a14"

        ColumnLayout {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.85, 460)
            spacing: 14

            // RentPass logo (full image, not cropped).
            Image {
                source: "qrc:/icons/rentpass-logo.png"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200
                fillMode: Image.PreserveAspectFit
            }

            Label {
                text: "Choose your quality"
                font.pixelSize: 24
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Pick a quality that runs smoothly on your laptop."
                font.pixelSize: 13
                color: "#96a6fd"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: "Stream quality"
                font.pixelSize: 15
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                ButtonGroup { id: bitrateGroup }

                RadioButton {
                    text: "Low"
                    ButtonGroup.group: bitrateGroup
                    onCheckedChanged: if (checked) root.selectedBitrate = 10000
                }

                RadioButton {
                    text: "Medium"
                    ButtonGroup.group: bitrateGroup
                    onCheckedChanged: if (checked) root.selectedBitrate = 25000
                }

                RadioButton {
                    text: "High"
                    checked: true
                    ButtonGroup.group: bitrateGroup
                    onCheckedChanged: if (checked) root.selectedBitrate = 50000
                }
            }

            Label {
                text: "Low runs smooth on slow laptops. High is the best picture."
                font.pixelSize: 11
                color: "#888888"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: "Frames per second"
                font.pixelSize: 15
                font.bold: true
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                ButtonGroup { id: fpsGroup }

                RadioButton {
                    text: "30 FPS"
                    ButtonGroup.group: fpsGroup
                    onCheckedChanged: if (checked) root.selectedFps = 30
                }

                RadioButton {
                    text: "60 FPS"
                    checked: true
                    ButtonGroup.group: fpsGroup
                    onCheckedChanged: if (checked) root.selectedFps = 60
                }
            }

            Label {
                text: "30 FPS is smoother on slow laptops. 60 FPS is the smoothest motion."
                font.pixelSize: 11
                color: "#888888"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Button {
                text: "Continue"
                Layout.fillWidth: true
                Layout.topMargin: 8
                Material.background: "#6b4fd8"
                onClicked: {
                    // Apply the choice to the settings the stream reads
                    // (PS5, local AND remote) before Play / connect.
                    // Wrapped so a settings failure can never strand the
                    // user here: the confirm signal below must always fire,
                    // and the server config already carries working defaults.
                    try {
                        Chiaki.settings.bitrateLocalPS5 = root.selectedBitrate
                        Chiaki.settings.bitrateRemotePS5 = root.selectedBitrate
                        Chiaki.settings.fpsLocalPS5 = root.selectedFps
                        Chiaki.settings.fpsRemotePS5 = root.selectedFps
                    } catch (e) {
                    }
                    root.qualityConfirmed()
                }
            }

            Label {
                text: "Session time left: " + formatTime(root.timeRemaining)
                font.pixelSize: 13
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter
                visible: root.timeRemaining > 0
            }
        }
    }
}
