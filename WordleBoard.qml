import QtQuick 2.14
import QtQuick.Controls 2.14
import Wordle 1.0
import Theme 1.0

GridView {
    id: wordleGrid

    property int boardWidth: parent.width
    property int boardHeight: parent.height
    property int rowCount: 6
    property int colCount: 5
    property int cellMargin: 2

    property int focusedIndex: 0
    property string inputStr: ""
    property int focusedRow: 0
    property int status: 0 // -1 for failed, 1 for won, 0 for gameplay

    property int animationRotationDuration: 200
    property int animationRotationPause: 50
    property int animationRotationDegreeFrom: 0
    property int animationRotationDegreeTo: 360

    signal newWord()
    signal gameReset()

    width: boardWidth
    height: boardHeight

    // property int cellWidth: boardWidth / colCount
    // property int cellHeight: boardHeight / rowCount

    cellWidth: (boardWidth / colCount) * 0.9
    cellHeight: (boardHeight / rowCount) * 0.9

    model: Wordle
    delegate: wordleDelegate
    focus: true

    Component {

        id: wordleDelegate

        Rectangle {

            id: cellRect

            width: cellWidth - 2 * cellMargin
            height: cellHeight - 2 * cellMargin

            border.color: Theme.emptyBorderColor;
            border.width: 2
            radius: cellWidth / 10

            color: Theme.textColor;

            focus:true


            Text {

                id: cellText


                // readOnly: index < 5 ? false : true

                anchors.fill: parent
                anchors.margins: 5

                font.bold: true
                font.pixelSize: 25
                // text: model.text

                color: "#000"

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Keys.onPressed: event => {

                if(status === 1){
                    return
                }

                const isLetter = (character) => /^[A-Za-z]$/.test(character);

                if(isLetter(event.text)){
                    if(wordleGrid.currentIndex < (focusedRow+1)*5){

                        cellText.text= event.text.toUpperCase();
                        cellText.color = Theme.writeTextColor;


                        wordleGrid.currentIndex++;
                        inputStr +=  event.text.toUpperCase();

                        console.log("key inserted  : " + inputStr)
                    }

                } else if(event.key === Qt.Key_Backspace) {

                        cellText.text = "";

                        wordleGrid.currentIndex--;
                        inputStr = inputStr.slice(0, -1)

                        if(wordleGrid.currentIndex <= focusedRow*5){
                            wordleGrid.currentIndex = focusedRow*5;
                        }

                        console.log("key deleted  : " + inputStr)

                } else if(event.key === Qt.Key_Return) {
                    if(wordleGrid.currentIndex === (focusedRow+1) * 5){

                        console.log("key max  : " + inputStr)

                        wordleGrid.currentIndex = (focusedRow+1) * 5;

                        if(Wordle.isValidWord(inputStr)){

                            console.log(inputStr + " is valid!")

                            for(let i=0;i<5;i++){

                                let wordCharacter = inputStr[i]
                                let idx = wordleGrid.model.index((focusedRow*5)+i, 0);
                                Wordle.setData(idx,wordCharacter,Wordle.valueRole);

                            }

                            let idx_l = wordleGrid.model.index(0, 0);
                            let idx_h = wordleGrid.model.index((focusedRow*5)+4, 0);

                            if(inputStr === Wordle.wordle){
                                status = 1;
                                levelWinPopup.open()
                            }

                            wordleGrid.newWord();

                            inputStr = "";
                            wordleGrid.focusedRow++;

                        } else{

                            console.log("Word is not found !")
                            invalidWord.open();
                        }
                    }

                    let idx = wordleGrid.model.index(rowCount*colCount-1, 0);
                    let lastChar = Wordle.data(idx, Wordle.valueRole);

                    if(lastChar !== " "){

                        status = -1
                        console.log("Failed....")
                        levelFailPopup.open()
                    }
                }

                console.log("currentIndex : " + wordleGrid.currentIndex)
                console.log("focusedRow   : " + wordleGrid.focusedRow)
            }


            transform: Rotation {
                id: rotation
                origin.x: cellRect.width / 2
                origin.y: cellRect.height / 2
                axis.x: 1
                axis.y: 0
                axis.z: 0
                angle: 1
            }

            // TODO: not working correctly
            // SequentialAnimation {
            //     id: vibrateAnimation
            //     loops: Animation.Infinite
            //     running: true
            //     NumberAnimation { property: "x"; to: -5; duration: 50; }
            //     NumberAnimation { property: "x"; to: 5; duration: 50; }
            //     NumberAnimation { property: "x"; to: -5; duration: 50; }
            //     NumberAnimation { property: "x"; to: 5; duration: 50; }
            //     NumberAnimation { property: "x"; to: 0; duration: 50; }
            // }

            // function startVibration() {
            //     vibrateAnimation.running = true;
            // }
        }
    }

    Popup {
        id: invalidWord

        modal: true

        width: boardWidth/2
        height: boardWidth/3

        opacity: 0.9

        closePolicy: Popup.NoAutoClose

        anchors.centerIn: parent

        onOpened: {
            closeTimer.start();
        }

        background: Rectangle {
            color: Theme.writeTextColor
            radius: 5
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "Word cannot found!"
                font.pixelSize: boardWidth/20
                color: Theme.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

       Timer {
            id: closeTimer

            interval: 1500 // 1.5 seconds
            running: false
            repeat: false

            onTriggered: {
                invalidWord.close();
            }
        }
    }

    Popup {
        id: levelFailPopup

        modal: true

        width: 300
        height: 200

        closePolicy: Popup.NoAutoClose

        anchors.centerIn: parent

        background: Rectangle {
            color: Theme.writeTextColor
            radius: 5
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                color: Theme.textColor
                text: "Game Failed! It was " + Wordle.wordle
                font.pixelSize: 20
            }

            Row {
                spacing: 10
                Button {
                    text: "Reset"
                    // anchors.fill: parent
                    onClicked: {
                        levelFailPopup.close();
                        gameReset();
                    }
                }

                Button {
                    text: "Exit"
                    onClicked: {
                        Qt.quit();
                    }
                }
            }
        }

    }

    Popup {
        id: levelWinPopup

        modal: true

        width: 300
        height: 200

        closePolicy: Popup.NoAutoClose

        anchors.centerIn: parent

        background: Rectangle {
            color: Theme.writeTextColor
            radius: 5
        }

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "You Win !"
                color: Theme.textColor
                font.pixelSize: 20
            }

            Row {

                spacing: 10

                Button {
                    text: "New Game?"
                    onClicked: {
                        levelWinPopup.close();
                        gameReset();
                    }
                }

                Button {
                    text: "Exit"
                    onClicked: {
                        Qt.quit();
                    }
                }
            }
        }
    }

    Connections {
        target: wordleGrid
        function onGameReset(){
            Wordle.resetGame()
            focusedRow = 0;
            status = 0;
            wordleGrid.currentIndex = 0;
            newWord()
        }

        function onNewWord() {
            for (let row = 0; row < rowCount; row++) {
                for (let col = 0; col < colCount; col++) {

                    let idx = wordleGrid.model.index(row * colCount + col, 0);
                    let item = wordleGrid.itemAtIndex(row * colCount + col);

                    if (item) {

                        let cellText = item.children[0];

                        if (cellText) {

                            let textValue = Wordle.data(idx, Wordle.valueRole);
                            cellText.text = textValue;

                            if(textValue ===" "){

                                item.color = Theme.textColor
                                item.border.color = Theme.emptyBorderColor
                                cellText.color = Theme.textColor

                            } else {

                                if(Wordle.wordle.includes(textValue)){
                                    if(textValue === Wordle.wordle[col]){

                                        cellText.color = Theme.textColor
                                        item.color = Theme.correctLetterColor
                                        item.border.color = Theme.correctLetterColor

                                    } else {

                                        cellText.color = Theme.textColor
                                        item.color = Theme.wrongLetterColor
                                        item.border.color = Theme.wrongLetterColor

                                    }

                                } else {

                                    cellText.color = Theme.textColor
                                    item.color = Theme.invalidLetterColor
                                    item.border.color = Theme.invalidLetterColor
                                }
                            }
                        }
                    }
                }
            }

            let idx = wordleGrid.model.index(0, 0);
            let firstChar = Wordle.data(idx, Wordle.valueRole);

            if(firstChar !== " "){
                rotation1.target = wordleGrid.itemAtIndex((focusedRow * colCount) + 0).transform[0];
                rotation2.target = wordleGrid.itemAtIndex((focusedRow * colCount) + 1).transform[0];
                rotation3.target = wordleGrid.itemAtIndex((focusedRow * colCount) + 2).transform[0];
                rotation4.target = wordleGrid.itemAtIndex((focusedRow * colCount) + 3).transform[0];
                rotation5.target = wordleGrid.itemAtIndex((focusedRow * colCount) + 4).transform[0];
                rotateSequentially.start();
            }
        }
    }

    SequentialAnimation {
          id: rotateSequentially
          running: false
          // loops: Animation.Infinite
          RotationAnimation {
              id: rotation1
              property: "angle"
              duration: wordleGrid.animationRotationDuration
              from: wordleGrid.animationRotationDegreeFrom
              to: wordleGrid.animationRotationDegreeTo
          }
          PauseAnimation {
              duration: wordleGrid.animationRotationPause
          }
          RotationAnimation {
              id: rotation2
              property: "angle"
              duration: wordleGrid.animationRotationDuration
              from: wordleGrid.animationRotationDegreeFrom
              to: wordleGrid.animationRotationDegreeTo
          }
          PauseAnimation {
              duration: wordleGrid.animationRotationPause
          }
          RotationAnimation {
              id: rotation3
              property: "angle"
              duration: wordleGrid.animationRotationDuration
              from: wordleGrid.animationRotationDegreeFrom
              to: wordleGrid.animationRotationDegreeTo
          }
          PauseAnimation {
              duration: wordleGrid.animationRotationPause
          }
          RotationAnimation {
              id: rotation4
              property: "angle"
              duration: wordleGrid.animationRotationDuration
              from: wordleGrid.animationRotationDegreeFrom
              to: wordleGrid.animationRotationDegreeTo
          }
          PauseAnimation {
              duration: wordleGrid.animationRotationPause
          }
          RotationAnimation {
              id: rotation5
              property: "angle"
              duration: wordleGrid.animationRotationDuration
              from: wordleGrid.animationRotationDegreeFrom
              to: wordleGrid.animationRotationDegreeTo
          }
      }
}
