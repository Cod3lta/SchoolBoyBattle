/*
 * Description : Cette classe dérive de Tile et a pour but de faire
 *               apparaître des bonbons à intervalles réguliers sur le terrain.
 * Version     : 1.0.0
 * Date        : 25.01.2021
 * Auteurs     : Prétat Valentin, Badel Kevin et Margueron Yasmine
*/

#include "tile.h"
#include <QGraphicsObject>

#ifndef TILECANDYPLACEMENT_H
#define TILECANDYPLACEMENT_H

class TileCandyPlacement : public Tile
{
    Q_OBJECT

public:
    TileCandyPlacement(
            int id,                             // Utilisé quand une autre instance broadcast de
            // créer un candy à un certain emplacement
            int respawnDelayMs,
            int indexX,                         // Données nécessaires pour créer un objet Tile
            int indexY,
            DataLoader::TileLayerStruct* layerRessources,
            QString layer,
            int tileType,
            DataLoader *dataLoader,
            QGraphicsItem* parent = nullptr);
    QRectF boundingRect() const override;
    QPainterPath shape() const override;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget) override;

private:
    bool candySpawned;
    int respawnDelayMs;
    int id;
    int min, max;
    static int candyId;
    QTimer *timer;

public slots:
    void spawnCandyTimer();
    void candyPickedUp();

signals:
    void spawnCandy(int candyType, int candySize, int nbPoints, int tilePlacementId, int candyId);
};

#endif // TILECANDYPLACEMENT_H
