import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Layouts 1.3

Window {
    width: 1280
    height: 720
    visible: true
    title: qsTr("Wordle")

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "WORDLE"
            font.pixelSize: parent.height/18
            font.letterSpacing: 10

            font.weight: 200
            horizontalAlignment: Text.AlignHCenter | Text.AlignTop
            anchors.horizontalCenter: parent.horizontalCenter
        }

        WordleBoard {
            width: parent.height * 0.9
            height: parent.height * 0.9
            // anchors.horizontalCenter: parent.horizontalCenter
        }

        // TODO
        // WordleKeyboard{

        // }
    }
}
