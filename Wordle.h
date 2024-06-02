#ifndef WORDLE_H
#define WORDLE_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QQmlEngine>
#include <QJSEngine>
#include <QAbstractListModel>
#include <QFile>
#include <QTextStream>
#include <QHash>
#include <QDebug>
#include <QRandomGenerator>
#include <QRegularExpression>

class Wordle : public QAbstractListModel {

    Q_OBJECT
    Q_PROPERTY(QString wordle READ wordle NOTIFY wordleChanged)
    Q_PROPERTY(int valueRole READ getValueRole CONSTANT)

public:
    enum Roles {
        ValueRole = Qt::UserRole + 1,
    };

    static QObject* singletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QHash<int, QByteArray> roleNames() const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE bool isValidWord(QString w) const;

    Q_INVOKABLE void  resetGame();

    void readWordsFromFile(const QString &filePath = "qrc:/resources/words.txt");

    bool searchWord(const QString &word) const;

    QString wordle();

    QString getRandomWord() const;

    static int getValueRole() { return ValueRole; }

protected:
    Wordle(QObject *parent = nullptr);

private:
    static Wordle* m_instance;

    static constexpr int ROW_COUNT = 6;
    static constexpr int WORD_SIZE = 5;

    QHash<QString, QString> wordHash;
    QVector<QString> m_board;
    QString m_wordle;

    void printBoard();

signals:

    void wordleChanged();
    void gameFinished(int status);
};

#endif // WORDLE_H
