import QtQuick 2.15
import Wordle 1.0
ListModel{
    id: wordleModel

    property int rowCount: 6
    property int colCount: 5

    // Define 30 elements in the model
    Component.onCompleted: {
        for (var i = 0; i < rowCount * colCount; i++) {
            append({text: i.toString()})
        }
    }

    // model: Wordle
}
