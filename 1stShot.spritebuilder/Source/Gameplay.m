//
//  Gameplay.m
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Obstacle.h"

static const CGFloat scrollSpeed = 80.f;
static const CGFloat yAccelSpeed = 10.f;
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

// fixing the drawing order. forcing the ground to be drawn above the pipes.
typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrdeHero
};

@implementation Gameplay
{
    CCPhysicsNode *_physicsNode;
    CCNode *_fastJet;
    CCNode *_levelNode;
    CCNode *_contentNode;
    CCSprite *_hero;
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    CCButton *_restartButton;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    CGFloat _elapsedTime;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_label;
    CGFloat _yAcceleration;
}

// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    _physicsNode.collisionDelegate = self;
    
    _grounds = @[_ground1, _ground2];
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    // fixing the drawing order. forcing the ground to be drawn above the pipes.
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    // set collision txpe
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _scrollSpeed = 80.f;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelerationData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

- (void)update:(CCTime)delta
{
    if(!_gameOver){
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y + _yAcceleration * yAccelSpeed);
    // clamp velocity
//    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
//    _hero.physicsBody.velocity = ccp(0, yVelocity);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y);
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
    // limit the rotation of the fly and start a downward rotation if no touch occured in a while.
//    _sinceTouch += delta;
//    _elapsedTime += delta;
//    _hero.rotation = clampf(_hero.rotation, -30.f, 90.f);
//    if (_hero.physicsBody.allowsRotation) {
//        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
//        _hero.physicsBody.angularVelocity = angularVelocity;
//    }
//    if ((_sinceTouch > 0.5f)) {
//        [_hero.physicsBody applyAngularImpulse:-10000.f*delta];
////        _sinceTouch = 0.f;
//    }
    if (_elapsedTime > 0.5f)
    {
//        [_hero.physicsBody applyImpulse:ccp(0, 450.f)];
//        [_hero.physicsBody applyAngularImpulse:10000.f];
        _elapsedTime = 0.f;
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
}

-(void)outputAccelerationData:(CMAcceleration)acceleration
{
    _label.string = [NSString stringWithFormat:@"%f", acceleration.y];
    _yAcceleration = acceleration.y;
}

// called on every touch in this scene
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self launchMissile];
    
    if (!_gameOver) {
//        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
//        [_hero.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }

}

- (void)launchMissile {
    // loads the Missile.ccb we have set up in Spritebuilder
    CCNode* missile = [CCBReader load:@"Missile"];
    // position the missile at the bowl of the catapult
    missile.position = ccpAdd(_fastJet.position, ccp(-10, -20));
    
    // add the missile to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild:missile];
    
    // manually create & apply a force to launch the missile
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 16000);
    [missile.physicsBody applyForce:force];
    
    // ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:missile worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];}

- (void)retry {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the seal
    if (energy > 2000.f)
    {
        [self sealRemoved:nodeA];
        [self missileRemoved:nodeA];
    }
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair missile:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    // if energy is large enough, remove the missile
    if (energy > 2000.f)
    {
        [self missileRemoved:nodeA];
    }
}

- (void)sealRemoved:(CCNode *)seal {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = seal.position;
    // add the particle effect to the same node the seal is on
    [seal.parent addChild:explosion];
    
    // finally, remove the destroyed seal
    [seal removeFromParent];
}

- (void)missileRemoved:(CCNode *)missile {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the missiles position
    explosion.position = missile.position;
    // add the particle effect to the same node the missile is on
    [missile.parent addChild:explosion];
    
    // finally, remove the missile
    [missile removeFromParent];
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
    [obstacle setupRandomPosition];
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    // fixing drawing order. drawing grounds in front of pipes.
    obstacle.zOrder = DrawingOrderPipes;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
//    CCLOG(@"%d",_points);
    return TRUE;
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}
@end
