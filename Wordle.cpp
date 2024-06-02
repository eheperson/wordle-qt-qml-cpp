#include "Wordle.h"

Wordle* Wordle::m_instance = nullptr;

QObject* Wordle::singletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {

    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    if (!m_instance) {
        m_instance = new Wordle();
    }

    return m_instance;
}

Wordle::Wordle(QObject *parent)
    : QAbstractListModel(parent), m_board(ROW_COUNT*WORD_SIZE, " ") {

    readWordsFromFile(":/resources/words.txt");

    m_wordle =  getRandomWord();

    qDebug() << "Wordle constructor called.";
    qDebug() << "Word is : " << m_wordle;
}

int Wordle::rowCount(const QModelIndex & /* parent */) const {
    return m_board.size();
}


QVariant Wordle::data(const QModelIndex &index, int role) const {

    if (!index.isValid() || index.row() >= m_board.size())
        return QVariant();

    int idx = index.row();

    switch (role) {
    case ValueRole:
        return m_board[idx];

    default:
        return QVariant();
    }
}

bool Wordle::setData(const QModelIndex &index, const QVariant &value, int role) {
    // qDebug() << "Trying to set data at index:" << index.row() << "Value:" << value << "Role:" << role;

    if (role != ValueRole) {
        // qDebug() << "Failed to set data: Incorrect role";
        return false;
    }
    if (!index.isValid()) {
        // qDebug() << "Failed to set data: Invalid index";
        return false;
    }
    if (index.row() >= m_board.size()) {
        // qDebug() << "Failed to set data: Index out of range";
        return false;
    }

    QString newValue = value.toString();

    if (m_board[index.row()] == newValue) {
        // qDebug() << "Failed to set data: No change in value";
        return false;  // No change in the value
    }

    m_board[index.row()] = newValue;

    if((index.row()+1)%5 == 0){
        qDebug() << "Data changed xxxxx";
        emit dataChanged(index, index, {ValueRole});
    }

    printBoard();

    return true;
}


QString Wordle::wordle() {
    return m_wordle;
}

QHash<int, QByteArray> Wordle::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[ValueRole] = "value";
    return roles;
}

bool Wordle::isValidWord(QString w) const{
    return searchWord(w);
}

void Wordle::printBoard(){

    qDebug() << "Printing board.";

    for (int i = 0; i < ROW_COUNT; ++i) {
        QString row;

        for (int j = 0; j < WORD_SIZE; ++j) {

            row += m_board[i * WORD_SIZE + j] + " ";

        }
        qDebug() << row;
    }
    qDebug() << "Board printed.";
}


void Wordle::readWordsFromFile(const QString &filePath) {

    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {

        qWarning() << "Cannot open file for reading:" << file.errorString();
        return;
    }

    QTextStream in(&file);

    while (!in.atEnd()) {

        QString line = in.readLine();

        QStringList words = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

        for (const QString &word : words) {

            wordHash.insert(word.toUpper(), word);
        }
    }
}

bool Wordle::searchWord(const QString &word) const {
    return wordHash.contains(word.toUpper());
}

QString Wordle::getRandomWord() const {

    if (wordHash.isEmpty()) {
        return QString();
    }

    int randomIndex = QRandomGenerator::global()->bounded(wordHash.size());

    auto it = wordHash.constBegin();

    std::advance(it, randomIndex);

    return it.value().toUpper();
}

void Wordle::resetGame(){

    m_wordle = getRandomWord();
    m_board.fill(" ");
    qDebug() << "reset, new word  : " << m_wordle;
}
