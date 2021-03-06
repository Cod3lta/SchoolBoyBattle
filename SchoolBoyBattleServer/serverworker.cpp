/*
 * Description : Cette classe représente chaque client connecté au serveur.
 *               C’est ici que l’objet QTcpSocket se trouve et également ici
 *               qu'on envoie les paquets au client qui lui sont assignés.
 * Version     : 1.0.0
 * Date        : 25.01.2021
 * Auteurs     : Prétat Valentin, Badel Kevin et Margueron Yasmine
*/

#include "serverworker.h"
#include <QDataStream>
#include <QJsonDocument>
#include <QJsonObject>

ServerWorker::ServerWorker(QObject *parent) :
    QObject(parent),
    socket(new QTcpSocket(this)),
    ready(false)
{
    connect(socket, &QTcpSocket::readyRead, this, &ServerWorker::receiveJson);
    connect(socket, &QTcpSocket::disconnected, this, &ServerWorker::disconnectedFromClient);
    connect(socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::error), this, &ServerWorker::error);
}

void ServerWorker::sendJson(const QJsonObject &json) {
    const QByteArray jsonData = QJsonDocument(json).toJson(QJsonDocument::Compact);
    emit logMessage("Envoi à " + QString::number(socket->socketDescriptor()) + " - " + QString::fromUtf8(jsonData));
    QDataStream socketStream(socket);
    socketStream.setVersion(QDataStream::Qt_5_9);
    socketStream << jsonData;
}

void ServerWorker::disconnectFromClient() {
    socket->disconnectFromHost();
}

void ServerWorker::setUsername(const QString &username) {
    usernameLock.lockForWrite();
    this->username = username;
    usernameLock.unlock();
}

void ServerWorker::receiveJson() {
    QByteArray jsonData;
    QDataStream socketStream(socket);

    socketStream.setVersion(QDataStream::Qt_5_9);

    while(true) {
        socketStream.startTransaction();
        socketStream >> jsonData;

        if(socketStream.commitTransaction()) {
            QJsonParseError parseError;
            const QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData, &parseError);
            if(parseError.error == QJsonParseError::NoError) {
                if(jsonDoc.isObject())
                    emit jsonRecieved(jsonDoc.object());
                else
                    emit logMessage("Message invalide : " + QString::fromUtf8(jsonData));
            } else {
                emit logMessage("Message invalide : " + QString::fromUtf8(jsonData));
            }
        } else {
            break;
        }
    }
}

// SETTERS / GETTERS --------------------------------

bool ServerWorker::setSocketDescriptor(qintptr socketDescriptor) {
    // Retourne un bool pou
    return socket->setSocketDescriptor(socketDescriptor);
}

qintptr ServerWorker::getSocketDescriptor() {
    return socket->socketDescriptor();
}

QString ServerWorker::getUsername() const {
    usernameLock.lockForRead();
    const QString result = username;
    usernameLock.unlock();
    return result;
}

bool ServerWorker::getReady() const {
    readyLock.lockForRead();
    const bool result = ready;
    readyLock.unlock();
    return result;
}

void ServerWorker::setReady(const bool ready) {
    readyLock.lockForWrite();
    this->ready = ready;
    readyLock.unlock();
}

int ServerWorker::getGender() {
    genderLock.lockForRead();
    const int result = gender;
    genderLock.unlock();
    return result;
}

void ServerWorker::setGender(int gender) {
    genderLock.lockForWrite();
    this->gender = gender;
    genderLock.unlock();
}

int ServerWorker::getTeam() {
    teamLock.lockForRead();
    const int result = team;
    teamLock.unlock();
    return result;
}

void ServerWorker::setTeam(int team) {
    teamLock.lockForWrite();
    this->team = team;
    teamLock.unlock();
}
