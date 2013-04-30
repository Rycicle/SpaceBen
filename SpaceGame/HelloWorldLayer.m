//
//  HelloWorldLayer.m
//  SpaceGame
//
//  Created by Ryan Salton on 23/04/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "CCParallaxNode-Extras.h"
#import "SimpleAudioEngine.h"
#define kNumAsteroids   15
#define kNumLasers      5

#define kFaceRotate 20

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		_bossInit = 0;
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];//1
        _customBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites2.png"];
        [self addChild:_batchNode];
        [self addChild:_customBatchNode];//2
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites2.plist"];//3
        
        _ship = [CCSprite spriteWithSpriteFrameName:@"rocket.png"];//4
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _ship.position = ccp(winSize.width * 0.1, winSize.height * 0.5); //6
        [_customBatchNode addChild:_ship z:1]; //7
        
        _lives = 3;
        _lifeArr = [[CCArray alloc] initWithCapacity:_lives];
        for(int i = 0; i < _lives; i++)
        {
            CCSprite *life = [CCSprite spriteWithSpriteFrameName:@"life.png"];
            life.position = ccp(20 + (i * 30), winSize.height - 20);
            [_customBatchNode addChild:life z:1];
            [_lifeArr addObject:life];
        }
        
        //Create the CCParallax node
        _backgroundNode = [CCParallaxNode node];
        [self addChild:_backgroundNode z:-1];
        //Create the sprites
        _spacedust1 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
        _spacedust2 = [CCSprite spriteWithFile:@"bg_front_spacedust.png"];
        
        _planetsunrise = [CCSprite spriteWithFile:@"bg_planetsunrise.png"];
        _galaxy = [CCSprite spriteWithFile:@"bg_galaxy.png"];
        _spacialanomaly = [CCSprite spriteWithFile:@"bg_spacialanomaly.png"];
        _spacialanomaly2 = [CCSprite spriteWithFile:@"bg_spacialanomaly2.png"];
        //Determine relative movement speeds
        CGPoint dustSpeed = ccp(0.1, 0.1);
        CGPoint bgSpeed = ccp(0.05, 0.05);
        //Add children
        [_backgroundNode addChild:_spacedust1 z:0 parallaxRatio:dustSpeed positionOffset:ccp(0, winSize.height/2)];
        [_backgroundNode addChild:_spacedust2 z:0 parallaxRatio:dustSpeed positionOffset:ccp(_spacedust1.contentSize.width, winSize.height/2)];
        [_backgroundNode addChild:_galaxy z:-1 parallaxRatio:bgSpeed positionOffset:ccp(0, winSize.height * 0.7)];
        [_backgroundNode addChild:_planetsunrise z:-1 parallaxRatio:bgSpeed positionOffset:ccp(600, winSize.height * 0)];
        [_backgroundNode addChild:_spacialanomaly z:-1 parallaxRatio:bgSpeed positionOffset:ccp(900, winSize.height * 0.3)];
        [_backgroundNode addChild:_spacialanomaly2 z:-1 parallaxRatio:bgSpeed positionOffset:ccp(1200, winSize.height * 0.9)];
        
        [self scheduleUpdate];
        
        NSArray *starsArray = [NSArray arrayWithObjects:@"Stars1.plist", @"Stars2.plist", @"Stars3.plist" , nil];
        for(NSString *stars in starsArray)
        {
            CCParticleSystemQuad *starsEffect = [CCParticleSystemQuad particleWithFile:stars];
            [self addChild:starsEffect z:1];
        }
        
        self.isAccelerometerEnabled = YES;
        
        _asteroids = [[CCArray alloc] initWithCapacity:kNumAsteroids];
        for(int i = 0; i < kNumAsteroids; i++)
        {
            CCSprite *asteroid = [CCSprite spriteWithSpriteFrameName:@"face.png"];
            asteroid.visible = NO;
            [_customBatchNode addChild:asteroid];
            [_asteroids addObject:asteroid];
        }
        _bossLasers = [[CCArray alloc] initWithCapacity:1];
        _shipLasers = [[CCArray alloc] initWithCapacity:kNumLasers];
        for(int i = 0; i < kNumLasers; i++)
        {
            CCSprite *shipLaser = [CCSprite spriteWithSpriteFrameName:@"artillery.png"];
            shipLaser.visible = NO;
            [_customBatchNode addChild:shipLaser];
            [_shipLasers addObject:shipLaser];
        }
        
        self.isTouchEnabled = YES;
        
        double curTime = CACurrentMediaTime();
        _gameOverTime = curTime + 30.0;
        
        _score = 0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            score = [CCLabelBMFont labelWithString:@"0" fntFile:@"Arial-hd.fnt"];
        }
        else{
            score = [CCLabelBMFont labelWithString:@"0" fntFile:@"Arial.fnt"];
        }
        //score.scale = 0.1;
        score.position = ccp(winSize.width - 20, winSize.height - 20);
        [self addChild:score];

        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SpaceGame.caf" loop:YES];
        //[[SimpleAudioEngine sharedEngine] preloadEffect:@""];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"splat.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"gulp.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"spurt.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"bowserlaugh.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"burp.caf"];
    }
    
	return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!_gameOver){
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if(_nextShipLaser >= _shipLasers.count) _nextShipLaser = 0;
    
    shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
    shipLaser.visible = YES;
    [shipLaser stopAllActions];
    [shipLaser runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1 position:ccp(winSize.width,0)], [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"spurt.caf"];
    }
}

-(float)randomValueBetween:(float)low andValue:(float)high
{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void)restartTapped:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

-(void)updateScore
{
    NSString *newscore = [NSString stringWithFormat:@"%i", _score];
    
    [score setString:newscore];
}

-(void)endScene:(EndReason)endReason
{
    [_bossTimer invalidate];
    if(_gameOver) return;
    _gameOver = true;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    NSString *message;
    if(endReason == kEndReasonWin)
    {
        message = @"You Win!";
    }
    else if(endReason == kEndReasonLose)
    {
        message = @"You Lose!";
    }
    
    CCLabelBMFont *label;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial-hd.fnt"];
    }
    else{
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial-hd.fnt"];
    }
    else{
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    }
    
    //restartLabel.scale = 100.0;
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
}

-(void)update:(ccTime)dt
{
    CGPoint backgroundScrollVel = ccp(-1000,0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
    NSArray *spaceDusts = [NSArray arrayWithObjects:_spacedust1, _spacedust2, nil];
    for(CCSprite *spaceDust in spaceDusts){
        if([_backgroundNode convertToWorldSpace:spaceDust.position].x < -spaceDust.contentSize.width)
        {
            [_backgroundNode incrementOffset:ccp(2*spaceDust.contentSize.width,0) forChild:spaceDust];
        }
    }
    
    NSArray *backgrounds = [NSArray arrayWithObjects:_planetsunrise, _galaxy, _spacialanomaly, _spacialanomaly2, nil];
    for(CCSprite *background in backgrounds)
    {
        if([_backgroundNode convertToWorldSpace:background.position].x < - background.contentSize.width)
        {
            [_backgroundNode incrementOffset:ccp(2000, 0) forChild:background];
        }
    }
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    _ship.position = ccp(_ship.position.x, newY);
    
    double curTime = CACurrentMediaTime();
    if(_bossInit == 0){
    if(curTime > _nextAsteroidSpawn)
    {
        float randSecs = [self randomValueBetween:0.2 andValue:1.0];
        _nextAsteroidSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
        CCSprite *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
        _nextAsteroid++;
        if(_nextAsteroid >= _asteroids.count) _nextAsteroid = 0;
        
        [asteroid stopAllActions];
        asteroid.position = ccp(winSize.width + asteroid.contentSize.width/2, randY);
        asteroid.visible = YES;
        [asteroid runAction:[CCSequence actions:[CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-asteroid.contentSize.width, 0)], [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
    }
    }
    
    for(CCSprite *asteroid in _asteroids)
    {
        if(!asteroid.visible) continue;
        
        for(CCSprite *shipLaser in _shipLasers)
        {
            if(!shipLaser.visible) continue;
            
            if(CGRectIntersectsRect(shipLaser.boundingBox, asteroid.boundingBox))
            {
                shipLaser.visible = NO;
                [asteroid setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"face2.png"]];
//                asteroid.visible = NO;
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"splat.caf"];
                [asteroid stopAllActions];
                [asteroid runAction:[CCRotateBy actionWithDuration:0.3 angle:kFaceRotate]];
                [asteroid runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1.5 position:ccp(20, (-winSize.height - 30))], [CCCallFuncN actionWithTarget:self selector:@selector(resetAsteroid:)], nil]];
                _score++;
                [self updateScore];
                continue;
            }
        }
        
        if (CGRectIntersectsRect(_ship.boundingBox, asteroid.boundingBox) & !_gameOver) {
            asteroid.visible = NO;
            [_ship runAction:[CCBlink actionWithDuration:1.0 blinks:9]];
            _lives--;
            [self updateLives];
            [[SimpleAudioEngine sharedEngine] playEffect:@"gulp.caf"];
        }

    }
    
    
    
    //Check collision with boss
    if(bigBen){
    for(CCSprite *shipLaser in _shipLasers)
    {
        if(!shipLaser.visible) continue;
        
        if(CGRectIntersectsRect(shipLaser.boundingBox, bigBen.boundingBox))
        {
            shipLaser.visible = NO;
            [[SimpleAudioEngine sharedEngine] playEffect:@"splat.caf"];
            _score++;
            _bossHits++;
            [self updateBoss];
            [self updateScore];
            continue;
        }
    }
        NSLog(@"Checking here - %i", _bossLasers.count);
        for(CCSprite *bossLaser in _bossLasers)
        {
            if(!bossLaser.visible) continue;
            NSLog(@"Checking boss laser");
            if(CGRectIntersectsRect(bossLaser.boundingBox, _ship.boundingBox))
            {
                bossLaser.visible = NO;
                [_ship runAction:[CCBlink actionWithDuration:1.0 blinks:9]];
                _lives--;
                [self updateLives];
            }
        }
        
    
    }
    
    
    if(_lives <= 0)
    {
        [_ship stopAllActions];
        _ship.visible = FALSE;
        [self endScene:kEndReasonLose];
    }
    else if(curTime >= _gameOverTime)
    {
        if(_bossInit == 0)
        [self bossFight];
    }
    
}

-(void)bossFight
{
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    _bossHits = 0;
    //stop all other asteroids
    for(int i = 0; i < kNumAsteroids; i++)
    {
        [self killAsteroid:[_asteroids objectAtIndex:i]];
    }
    _bossInit = 1;
    bigBen = [CCSprite spriteWithSpriteFrameName:@"facebig.png"];
    bigBen.scale = 1.0;
    bigBen.position = ccp(winSize.width + bigBen.contentSize.width + 50,winSize.height/2);
    [_customBatchNode addChild:bigBen z:1];

    mouth = [CCSprite spriteWithSpriteFrameName:@"mouth.png"];
    mouth.position = ccp(winSize.width - 50,winSize.height/2 - 100);
    mouth.visible = NO;
    [_customBatchNode addChild:mouth z:3];
    
    _bossTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(bossInterval) userInfo:nil repeats:YES];
    
    //[self endScene:kEndReasonWin];
}

-(void)bossInterval
{
    mouth.visible = YES;
    [[SimpleAudioEngine sharedEngine] playEffect:@"burp.caf"];
    [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(closeMouth) userInfo:nil repeats:NO];

    CCSprite *bossLaser = [CCSprite spriteWithSpriteFrameName:@"artillery2.png"];
    [_customBatchNode addChild:bossLaser z:2];
    [_bossLasers addObject:bossLaser];
    
    bossLaser.position = ccpAdd(mouth.position, ccp(bossLaser.contentSize.width/2, 0));
    bossLaser.scale = 0.9;
    bossLaser.visible = YES;
    [bossLaser stopAllActions];
    [bossLaser runAction:[CCSequence actions:[CCMoveTo actionWithDuration:1 position:ccp(_ship.position.x, _ship.position.y)], [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
    [bossLaser runAction:[CCSequence actions:[CCRotateBy actionWithDuration:1.0 angle:180], nil]];
}

-(void)closeMouth
{
    mouth.visible = NO;
}

-(void)callBoss
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"bowserlaugh.caf"];
    [bigBen runAction:[CCSequence actions:[CCMoveBy actionWithDuration:2.0 position:ccp(-bigBen.contentSize.width - 100,0)], nil]];
}

-(void)updateBoss
{
    if(_bossHits >= 20){
        bigBen.visible = NO;
        [self endScene:kEndReasonWin];
    }
    if(_bossHits == 2)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig2.png"]];
    if(_bossHits == 5)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig3.png"]];
    if(_bossHits == 8)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig4.png"]];
    if(_bossHits == 12)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig5.png"]];
    if(_bossHits == 15)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig6.png"]];
    if(_bossHits == 18)
        [bigBen setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"facebig7.png"]];
}

-(void)updateLives
{
    [[_lifeArr objectAtIndex:_lives] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"life2.png"]];
    
}

-(void)setInvisible:(CCNode *)node
{
    node.visible = NO;
}

-(void)resetAsteroid:(CCNode *)node
{
    [(CCSprite *)node setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"face.png"]];
    [node setRotation:0];
}

-(void)killAsteroid:(CCNode *)node
{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    [node stopAllActions];
    [node runAction:[CCSequence actions:[CCMoveTo actionWithDuration:1.0 position:ccp(winSize.width + 50,winSize.height/2)], [CCCallFuncN actionWithTarget:self selector:@selector(callBoss)], nil]];
    //[node runAction:[CCSequence actions:[CCMoveTo actionWithDuration:1.5 position:ccp(winSize.width, winSize.height/2)], [CCCallFuncN actionWithTarget:self selector:@selector(resetAsteroid:)], nil]];
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
#define kFilteringFactor 0.1
#define kRestAccelX -0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
    UIAccelerationValue rollingX, rollingY, rollingZ;
    rollingX = (acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.x * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.x * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = acceleration.x - rollingX;
    float accelY = acceleration.y - rollingY;
    float accelZ = acceleration.z - rollingZ;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float accelDiff = accelX - kRestAccelX;
    float accelFraction = accelDiff / kMaxDiffX;
    float pointsPerSec = kShipMaxPointsPerSec * accelFraction;
    
    _shipPointsPerSecY = pointsPerSec;
//    _shipPointsPerSecY = pointsPerSec + 670;
    
}


// on "dealloc" you need to release all your retained objects

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
