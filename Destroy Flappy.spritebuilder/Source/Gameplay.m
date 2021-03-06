//
//  Gameplay.m
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Obstacle.h"

static const CGFloat scrollSpeedRate = 150.f;
static const CGFloat yAccelSpeed = 10.f;
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 320.f;

// fixing the drawing order. forcing the ground to be drawn above the pipes.
typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrdeHero
};

@implementation Gameplay
{
    CCPhysicsNode *_physicsNode;
   CCPhysicsNode *_cloudPhysicsNode;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCSprite *_hero;
    CCNode *_ground1;
    CCNode *_ground2;
   CCNode *_cloud1;
   CCNode *_cloud2;
   CCNode *_bush1;
   CCNode *_bush2;
    NSArray *_grounds;
   NSArray *_clouds;
   NSArray *_bushes;
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    CCButton *_restartButton;
   CCButton *_shareButton;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    CGFloat _elapsedTime;
    NSInteger _points,_prevPoint;
   NSInteger _localCounter;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_label;
    CGFloat _swiped;
    CGFloat _newHeroPosition;
    CCNode *_gameOverBox;
    CCLabelTTF *_highScoreValue;
    CCLabelTTF *_scoreValue;
    GADBannerView *_bannerView;
    GADInterstitial *interstitial;
    CCLabelTTF *_missileLabel;
   NSInteger _missileCount;
   AVAudioPlayer *bonusSound;
   AVAudioPlayer *clickSound;
   AVAudioPlayer *errorSound;
   UIImage *_image;

}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
//    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
//    [_levelNode addChild:level];
    
    _physicsNode.collisionDelegate = self;
    
    _grounds = @[_ground1, _ground2];
   _clouds = @[_cloud1, _cloud2];
   _bushes = @[_bush1, _bush2];
   
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
//    [self spawnNewObstacle];
    
    // fixing the drawing order. forcing the ground to be drawn above the pipes.
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    // set collision type
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _scrollSpeed = scrollSpeedRate;
    _prevPoint = 1;
    
    // GestureRecognizer Code
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedUp)];
    swipeUp.numberOfTouchesRequired = 1;
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedDown)];
    swipeDown.numberOfTouchesRequired = 1;
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];

   UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedRight)];
   swipRight.numberOfTouchesRequired = 1;
   swipRight.direction = UISwipeGestureRecognizerDirectionRight;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipRight];

   UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenWasSwipedRight)];
   swipeLeft.numberOfTouchesRequired = 1;
   swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
   
   UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
    tapped.numberOfTapsRequired = 1;
    tapped.numberOfTouchesRequired = 1;
    tapped.cancelsTouchesInView = NO;
    
    [[[CCDirector sharedDirector] view] addGestureRecognizer:tapped];
    
    _newHeroPosition = _hero.position.y;
    
    _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"] ;
   _missileCount = [[NSUserDefaults standardUserDefaults]integerForKey:@"missileCount"];
   _missileLabel.string = [NSString stringWithFormat:@"%ld", (long)_missileCount];

    [self cycleInterstitial]; // Prepare our interstitial for after the game so that we can be certain its ready to present
   
   // Initialize the banner at the bottom of the screen.
   CGPoint origin = CGPointMake(0.0,
                                [CCDirector sharedDirector].view.frame.size.height -
                                CGSizeFromGADAdSize(kGADAdSizeBanner).height);
   _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
   
   // Specify the ad unit ID.
   _bannerView.adUnitID = @"ca-app-pub-3129568560891761/8152886730";
   
   // Let the runtime know which UIViewController to restore after taking
   // the user wherever the ad goes and add it to the view hierarchy.
   _bannerView.rootViewController = [CCDirector sharedDirector];
   [[[CCDirector sharedDirector]view]addSubview:_bannerView];
   // Initiate a generic request to load it with an ad.
   [_bannerView loadRequest:[GADRequest request]];
   _bannerView.delegate = self;
   _bannerView.hidden = YES;
   
   // The AV Audio Player needs a URL to the file that will be played to be specified.
   // So, we're going to set the audio file's path and then convert it to a URL.
   // Bonus Sound
   NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"picked-coin-echo-2" ofType:@"wav"];
   NSURL *pathAsURL = [[NSURL alloc] initFileURLWithPath:audioFilePath];
   
   // Init the audio player.
   NSError *error;
   bonusSound = [[AVAudioPlayer alloc] initWithContentsOfURL:pathAsURL error:&error];
   
   // Check out what's wrong in case that the player doesn't init.
   if (error) {
      NSLog(@"%@", [error localizedDescription]);
   }
   else{
      // In this example we'll pre-load the audio into the buffer. You may avoid it if you want
      // as it's not always possible to pre-load the audio.
      [bonusSound prepareToPlay];
   }
   
   [bonusSound setDelegate:self];
   // click sound
   NSString *audioFilePath2 = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
   NSURL *pathAsURL2 = [[NSURL alloc] initFileURLWithPath:audioFilePath2];
   NSError *error2;
   clickSound = [[AVAudioPlayer alloc] initWithContentsOfURL:pathAsURL2 error:&error2];
   
   // Check out what's wrong in case that the player doesn't init.
   if (error2) {
      NSLog(@"%@", [error2 localizedDescription]);
   }
   else{
      // In this example we'll pre-load the audio into the buffer. You may avoid it if you want
      // as it's not always possible to pre-load the audio.
      [clickSound prepareToPlay];
   }
   
   [clickSound setDelegate:self];
   
   // error sound
   NSString *audioFilePath3 = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"wav"];
   NSURL *pathAsURL3 = [[NSURL alloc] initFileURLWithPath:audioFilePath3];
   NSError *error3;
   errorSound = [[AVAudioPlayer alloc] initWithContentsOfURL:pathAsURL3 error:&error3];
   
   // Check out what's wrong in case that the player doesn't init.
   if (error3) {
      NSLog(@"%@", [error3 localizedDescription]);
   }
   else{
      // In this example we'll pre-load the audio into the buffer. You may avoid it if you want
      // as it's not always possible to pre-load the audio.
      [errorSound prepareToPlay];
   }
   
   [errorSound setDelegate:self];

}

-(void)screenWasSwipedUp
{
    if(_hero.position.y < 420)
    {
    if(_hero.position.y == 100 ||
       _hero.position.y == 180 ||
       _hero.position.y == 260 ||
       _hero.position.y == 340 ||
       _hero.position.y == 420)
    {
    _swiped = 1.0f;
    _newHeroPosition = _hero.position.y;
    }
    }
}

-(void)screenWasSwipedDown
{
    if(_hero.position.y == 100 ||
       _hero.position.y == 180 ||
       _hero.position.y == 260 ||
       _hero.position.y == 340 ||
       _hero.position.y == 420)
    {
        _swiped = -1.0f;
        _newHeroPosition = _hero.position.y;
    }
}

-(void)screenTapped
{
    if (!_gameOver) {
       [self launchBullet];
    }
}

-(void)screenWasSwipedRight
{
   if (!_gameOver) {
      if(_missileCount > 0)
      {
         [self launchMissile];
         _missileCount--;
         _missileLabel.string = [NSString stringWithFormat:@"%ld", (long)_missileCount];
      }
      else{
         [errorSound play];
      }
   }
}


- (void)update:(CCTime)delta
{
   if(!_gameOver){
      if(_points == _prevPoint)
      {
         _scrollSpeed = scrollSpeedRate + _points;
         _prevPoint++;
      }
      if (_hero.position.y - _newHeroPosition >= 80.0)
      {
         _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
      }
      else if(_hero.position.y - _newHeroPosition <= -80.0)
      {
         _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
      }
      else
      {
         _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y + _swiped * yAccelSpeed);
      }
      //        CCLOG(@"%f",_hero.position.y);
      _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
      // loop the ground
      for (CCNode *ground in _grounds) {
         // get the world position of the ground
         CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
         // get the screen position of the ground
         CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
         // if the left corner is one complete width off the screen, move it to the right
         if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
         }
         
      }
      _cloudPhysicsNode.position = ccp(_cloudPhysicsNode.position.x - (_scrollSpeed/8 *delta), _cloudPhysicsNode.position.y);
      // loop the clouds
      for (CCNode *cloud in _clouds) {
         // get the world position of the cloud
         CGPoint cloudWorldPosition = [_cloudPhysicsNode convertToWorldSpace:cloud.position];
         // get the screen position of the cloud
         CGPoint cloudScreenPosition = [self convertToNodeSpace:cloudWorldPosition];
         // if the left corner is one complete width off the screen, move it to the right
         if (cloudScreenPosition.x <= (-0.5 * cloud.contentSize.width)) {
            cloud.position = ccp(cloud.position.x + 2 * cloud.contentSize.width, cloud.position.y);
         }
         
      }
      
      // loop the bushes
      for (CCNode *bush in _bushes) {
         // get the world position of the bush
         CGPoint bushWorldPosition = [_cloudPhysicsNode convertToWorldSpace:bush.position];
         // get the screen position of the bush
         CGPoint bushScreenPosition = [self convertToNodeSpace:bushWorldPosition];
         // if the left corner is one complete width off the screen, move it to the right
         if (bushScreenPosition.x <= (-0.5 * bush.contentSize.width)) {
            bush.position = ccp(bush.position.x + 2 * bush.contentSize.width, bush.position.y);
         }
         
      }
      // Spawning new obstacles when old ones leave the screen
      
      NSMutableArray *offScreenObstacles = nil;
      for (CCNode *obstacle in _obstacles) {
         CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
         CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
         if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
               offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
         }
      }
      for (CCNode *obstacleToRemove in offScreenObstacles) {
         [obstacleToRemove removeFromParent];
         [_obstacles removeObject:obstacleToRemove];
         // for each removed obstacle, add a new one
         [self spawnNewObstacle];
      }
   }
   else
   {
      if(_gameOverBox.position.y < 190)
      {
         _gameOverBox.position = ccp(_gameOverBox.position.x, _gameOverBox.position.y + 5);
      }
      if(_highScoreValue.position.y < 150)
      {
         _highScoreValue.position = ccp(_highScoreValue.position.x, _highScoreValue.position.y + 5);
      }
      if(_scoreValue.position.y < 180)
      {
         _scoreValue.position = ccp(_scoreValue.position.x, _scoreValue.position.y + 5);
      }
      else
      {
         _elapsedTime += delta;
         if(_localCounter <= _points && _elapsedTime > 0.5)
         {
            _restartButton.visible = TRUE;
            _shareButton.visible = TRUE;
            _localCounter++;
            _scoreValue.string = [NSString stringWithFormat:@"%ld", (long)_localCounter-1];
         }
      }
      
   }
}

- (void)launchMissile {
    // loads the Missile.ccb we have set up in Spritebuilder
    CCNode* missile = [CCBReader load:@"Missile"];
    // position the missile at the bottom of hero
    missile.position = ccpAdd(_hero.position, ccp(60, -15));
    
    // add the missile to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:missile];
    
    // manually create & apply a force to launch the missile
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 20000);
    [missile.physicsBody applyForce:force];
    
    // ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:missile worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];}

- (void)missileRemoved:(CCNode *)missile {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the missiles position
    explosion.position = missile.position;
    // add the particle effect to the same node the missile is on
    [missile.parent addChild:explosion];
    
    // finally, remove the missile
    [missile removeFromParent];
}

- (void)launchBullet {
   // loads the Bullet.ccb we have set up in Spritebuilder
   CCNode* bullet = [CCBReader load:@"Bullet"];
   // position the bullet at the bottom of hero
   bullet.position = ccpAdd(_hero.position, ccp(60, -10));
   
   // add the bullet to the physicsNode of this scene (because it has physics enabled)
   [_physicsNode addChild:bullet];
   
   // manually create & apply a force to launch the bullet
   CGPoint launchDirection = ccp(1, 0);
   CGPoint force = ccpMult(launchDirection, 4000);
   [bullet.physicsBody applyForce:force];
   
   // ensure followed object is in visible are when starting
   self.position = ccp(0, 0);
   CCActionFollow *follow = [CCActionFollow actionWithTarget:bullet worldBoundary:self.boundingBox];
   [_contentNode runAction:follow];}

- (void)bulletRemoved:(CCNode *)bullet {
   // load particle effect
   CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"BulletExplosion"];
   // make the particle effect clean itself up, once it is completed
   explosion.autoRemoveOnFinish = TRUE;
   // place the particle effect on the missiles position
   explosion.position = bullet.position;
   // add the particle effect to the same node the missile is on
   [bullet.parent addChild:explosion];
   
   // finally, remove the missile
   [bullet removeFromParent];
}

- (void)heroRemoved:(CCNode *)hero {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the hero position
    explosion.position = hero.position;
    // add the particle effect to the same node the hero is on
    [hero.parent addChild:explosion];
    
    // finally, remove the hero
    [hero removeFromParent];
}

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle getMissileCount:_missileCount];
    [obstacle setupRandomPosition];
    [obstacle setupRandomTarget];
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    // fixing drawing order. drawing grounds in front of pipes.
    obstacle.zOrder = DrawingOrderPipes;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missile:(CCNode *)missile target:(CCNode *)target {
    [target removeFromParent];
    [self missileRemoved:missile];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missile:(CCNode *)missile metalTarget:(CCNode *)metalTarget {
   [metalTarget removeFromParent];
   [self missileRemoved:missile];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair missile:(CCNode *)missile level:(CCNode *)level {
    [self missileRemoved:missile];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet target:(CCNode *)target {
   [target removeFromParent];
   [self bulletRemoved:bullet];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet level:(CCNode *)level {
   [self bulletRemoved:bullet];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair bullet:(CCNode *)bullet metalTarget:(CCNode *)metalTarget {
   [self bulletRemoved:bullet];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero target:(CCNode *)target {
    [target removeFromParent];
    [self heroRemoved:hero];
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero metalTarget:(CCNode *)metalTarget {
   [metalTarget removeFromParent];
   [self heroRemoved:hero];
   [self gameOver];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero bonus:(CCNode *)bonus {
   [bonusSound play];
   [bonus removeFromParent];
   _missileCount = _missileCount + 3;
   _missileLabel.string = [NSString stringWithFormat:@"%ld", (long)_missileCount];
   return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    
    [self heroRemoved:hero];
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
    return TRUE;
}

- (void)restart {
   [clickSound play];
    [self presentInterlude];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [_bannerView removeFromSuperview];
    interstitial.delegate = nil;
    interstitial = nil;
   bonusSound.delegate = nil;
    bonusSound = nil;
   clickSound.delegate = nil;
   clickSound = nil;
   errorSound.delegate = nil;
   errorSound = nil;

    [super onExit];
}



- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _gameOverBox.visible = TRUE;
        _highScoreValue.visible = TRUE;
        _scoreValue.visible = TRUE;
        [_hero stopAllActions];
       
//        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.5f position:ccp(0, 163)];
//        CCActionInterval *reverseMovement = [moveBy reverse];
//        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
//        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
//       [_gameOverBox runAction:bounce];
       
        // save high score
        //To save the score (in this case, 10000 ) to standard defaults:
        
        if(_points > _highScore)
        {
        
            [[NSUserDefaults standardUserDefaults] setInteger: _points forKey: @"highScore"];
        
            // To read it back:
        
        }
        _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"] ;
        _highScoreValue.string = [NSString stringWithFormat:@"%ld", (long)_highScore];
       
       [[NSUserDefaults standardUserDefaults]setInteger:_missileCount forKey:@"missileCount"];
       _missileCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"missileCount"];
       
       // Take Screen Shot
       UIGraphicsBeginImageContextWithOptions([CCDirector sharedDirector].view.bounds.size, NO, [UIScreen mainScreen].scale);
       
       [[CCDirector sharedDirector].view drawViewHierarchyInRect:[CCDirector sharedDirector].view.bounds afterScreenUpdates:NO];
       
       _image = UIGraphicsGetImageFromCurrentImageContext();
       UIGraphicsEndImageContext();
       
        _bannerView.hidden = NO;
//        [self runAction:bounce];
    }
}

-(void)resetHighScore{
    [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey: @"highScore"];
    _highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"] ;
    _highScoreValue.string = [NSString stringWithFormat:@"%ld", (long)_highScore];
}

-(void)shareImage{
   [clickSound play];
   NSString *message = [NSString stringWithFormat:@"OMG!!! I scored %d", _points];
   message = [message stringByAppendingString:@" points in Destroy Flappy."];
   
   UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:message,_image, nil] applicationActivities:nil];
   activityVC.excludedActivityTypes = @[ UIActivityTypeAssignToContact];
   [[CCDirector sharedDirector] presentViewController:activityVC animated:YES completion:nil];

}

#pragma mark GADBannerViewDelegate implementation

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
   NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
   NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

#pragma mark -
#pragma mark Interstitial Management

- (void)cycleInterstitial
{
    // Clean up the old interstitial...
    interstitial.delegate = nil;
    interstitial = nil;   
   // GAD
   interstitial = [[GADInterstitial alloc] init];
   interstitial.adUnitID = @"ca-app-pub-3129568560891761/5903024736";
   [interstitial loadRequest:[GADRequest request]];
   interstitial.delegate = self;
}

- (void)presentInterlude
{
   // If the interstitial managed to load, then we'll present it now.
   if (interstitial.isReady) {
      [interstitial presentFromRootViewController:[CCDirector sharedDirector]];
   }
   CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
   [[CCDirector sharedDirector] replaceScene:scene];
   _bannerView.hidden = YES;
}

#pragma mark ADInterstitialViewDelegate methods

// When this method is invoked, the application should remove the view from the screen and tear it down.
// The content will be unloaded shortly after this method is called and no new content will be loaded in that view.
// This may occur either when the user dismisses the interstitial view via the dismiss button or
// if the content in the view has expired.
//- (void)interstitialAdDidUnload:(GADInterstitial *)interstitialAd
//{
//    [self cycleInterstitial];
//}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
-(void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
   [self cycleInterstitial];
}

-(void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
   [self cycleInterstitial];
}

@end
