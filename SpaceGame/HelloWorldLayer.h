//
//  HelloWorldLayer.h
//  SpaceGame
//
//  Created by Ryan Salton on 23/04/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCSpriteBatchNode *_batchNode;
    CCSpriteBatchNode *_customBatchNode;
    CCSprite *_ship;
    CCSprite *_life;
    CCParallaxNode *_backgroundNode;
    CCSprite *_spacedust1;
    CCSprite *_spacedust2;
    CCSprite *_planetsunrise;
    CCSprite *_galaxy;
    CCSprite *_spacialanomaly;
    CCSprite *_spacialanomaly2;
    CCSprite *bigBen;
    CCSprite *mouth;
    CCArray *_asteroids;
    CCArray *_shipLasers;
    CCArray *_bossLasers;
    CCArray *_lifeArr;
    CCLabelBMFont *score;
    NSTimer *_bossTimer;
    float _shipPointsPerSecY;
    int _nextAsteroid;
    int _nextShipLaser;
    int _lives;
    int _score;
    int _bossInit;
    int _bossHits;
    double _nextAsteroidSpawn;
    double _gameOverTime;
    bool _gameOver;
    UILabel *_debugAccel;
}



// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
