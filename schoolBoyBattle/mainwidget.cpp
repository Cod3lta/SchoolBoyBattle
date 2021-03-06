/*
 * Description : Cette  classe est le widget principal qui se trouve
 *               dans l’objet QMainWindow du programme.
 *               Cette classe hérite de QStackedWidget, ce qui lui permet
 *               d’afficher un objet QWidget à la fois, donnant une façon simple
 *               d’implémenter des menus d’interface où l’on passe d’une page à l’autre.
 *               Au lancement du programme, MainWidget met comme widget visible
 *               celui provenant de la classe StartMenu.
 * Version     : 1.0.0
 * Date        : 25.01.2021
 * Auteurs     : Prétat Valentin, Badel Kevin et Margueron Yasmine
*/

#include "gamewidget.h"
#include "mainwidget.h"
#include "startmenu.h"
#include "finishmenu.h"
#include <QMediaPlaylist>
#include <QMessageBox>

MainWidget::MainWidget() :
    tcpClient(new TcpClient(this))
{
    QMediaPlaylist *menuMusicPlaylist = new QMediaPlaylist(this);
    menuMusicPlaylist->addMedia(QUrl("qrc:/Resources/sounds/menuTitle.wav"));
    menuMusicPlaylist->setPlaybackMode(QMediaPlaylist::Loop);
    menuMusicPlayer = new QMediaPlayer(this);
    menuMusicPlayer->setPlaylist(menuMusicPlaylist);
    startMenuMusic();
    gameWidget = new GameWidget(tcpClient, this);
    StartMenu *startMenu = new StartMenu(this);
    FinishMenu *finishMenu = new FinishMenu(this);
    waitingRoom = new WaitingRoom(tcpClient, this);

    QString stylesheet = ""
                         "QPushButton {"
                         "background-color: #1b1c1e;"
                         "color: lightgray;"
                         "font-family: Helvetica;"
                         "font-weight: bold;"
                         "font-size: 12pt;"
                         "padding: 7px;"
                         "border-radius: 5px"
                         "}"
                         "QPushButton:disabled {"
                         "background-color:#686d78;"
                         "}"
                         "QLabel {"
                         "font-family: Helvetica;"
                         "color: #26292d;"
                         "font-size: 12pt;"
                         "}"
                         "QLineEdit {"
                         "padding: 7px;"
                         "border: none;"
                         "border-radius: 5px"
                         "}";

    startMenu->setStyleSheet(stylesheet);
    finishMenu->setStyleSheet(stylesheet);
    waitingRoom->setStyleSheet(stylesheet);

    addWidget(gameWidget);
    addWidget(startMenu);
    addWidget(waitingRoom);
    addWidget(finishMenu);

    setCurrentWidget(startMenu);
    connect(startMenu, &StartMenu::startLocalGame, gameWidget, &GameWidget::startGame);
    connect(startMenu, &StartMenu::setVisibleWidget, this, &QStackedWidget::setCurrentIndex);
    connect(startMenu, &StartMenu::startClient, waitingRoom, &WaitingRoom::startWaitingRoom);
    connect(waitingRoom, &WaitingRoom::setVisibleWidget, this, &QStackedWidget::setCurrentIndex);
    connect(gameWidget, &GameWidget::setVisibleWidget, this, &QStackedWidget::setCurrentIndex);
    connect(gameWidget, &GameWidget::setFinishMenuWinner, finishMenu, &FinishMenu::showWinner);
    connect(gameWidget, &GameWidget::stopMenuMusic, this, &MainWidget::stopMenuMusic);
    connect(finishMenu, &FinishMenu::setVisibleWidget, this, &QStackedWidget::setCurrentIndex);
    connect(finishMenu, &FinishMenu::startMenuMusic, this, &MainWidget::startMenuMusic);
    connect(finishMenu, &FinishMenu::resetGame, gameWidget, &GameWidget::resetGame);
    connect(finishMenu, &FinishMenu::resetGame, tcpClient, &TcpClient::disconnectFromHost);
    connect(tcpClient, &TcpClient::startGame, gameWidget, &GameWidget::startGame);

    connect(tcpClient, &TcpClient::connectionError, this, [=] () {
        setCurrentIndex(1);
        QMessageBox::critical(nullptr, "Erreur", "Déconnecté du serveur");
    });
    connect(tcpClient, &TcpClient::disconnected, this, [=] () {
        gameWidget->resetGame();
        setCurrentIndex(1);
    });
    setFocusPolicy(Qt::StrongFocus);
}

/**
 * Arrêter la musique.
 */
void MainWidget::stopMenuMusic() {
    menuMusicPlayer->stop();
}

/**
 * Démarrer la musique.
 */
void MainWidget::startMenuMusic() {
    menuMusicPlayer->play();
}
