//
//  Obstacle.m
//  1stShot
//
//  Created by Faisal on 5/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"
@implementation Obstacle {
    CCNode *_topPipe;
    CCNode *_bottomPipe;
    CCNode *_target, *_target2, *_target3;
    int _random,_random2;
    int _yPosition;
    BOOL _goTime;
    CGFloat _elapsedTime;
}
// distance between top and bottom pipe
static const CGFloat pipeDistance = 100.f;
static const CGFloat scrollSpeed = 1.f;

- (void)setupRandomPosition {
    _random = arc4random() % 4;
    switch(_random)
    {
        case 0:
            _yPosition = 110;
            break;
        case 1:
            _yPosition = 190;
            break;
        case 2:
            _yPosition = 270;
            break;
        case 3:
            _yPosition = 350;
            break;
        default:
            break;
    }
    _topPipe.position = ccp(_topPipe.position.x, _yPosition);
    _target.position = ccp(_target.position.x,_topPipe.position.y + pipeDistance/2);
    _target2.position = ccp(_target2.position.x,_topPipe.position.y + pipeDistance/1.25);
    _target3.position = ccp(_target3.position.x,_topPipe.position.y + pipeDistance/2.85);
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + pipeDistance);
//    CCLOG(@"%f",_bottomPipe.position.x);
//    CCLOG(@"%f",_topPipe.position.y);
    _goTime = true;
}

- (void)didLoadFromCCB {
    _topPipe.physicsBody.collisionType = @"level";
    _topPipe.physicsBody.sensor = TRUE;
    _bottomPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.sensor = TRUE;
    _target.physicsBody.collisionType = @"target";
    _target.physicsBody.sensor = TRUE;
    _target2.physicsBody.collisionType = @"target";
    _target2.physicsBody.sensor = TRUE;
   _target3.physicsBody.collisionType = @"target";
   _target3.physicsBody.sensor = TRUE;
}

-(void)update:(CCTime)delta
{
    if(_goTime)
    {
        _elapsedTime += delta;
        if(_elapsedTime > 2.5)
        {
            _target.position = ccp(_target.position.x + delta/2, _target.position.y + delta/2);
//            CCLOG(@"%f",_target.position.y);
        }
    }
}

-(void)setupRandomTarget
{
    _random2 = arc4random() % 5;
    switch(_random2)
    {
        case 0:
            [_target2 removeFromParent];
            [_target3 removeFromParent];
//          [_target removeFromParent];
            break;
        case 1:
            [_target2 removeFromParent];
          [_target3 removeFromParent];
//          [_target removeFromParent];
            break;
        case 2:
            [_target2 removeFromParent];
          [_target3 removeFromParent];
//          [_target removeFromParent];
            break;
        case 3:
            [_target2 removeFromParent];
          [_target3 removeFromParent];
//          [_target removeFromParent];
            break;
        case 4:
            [_target removeFromParent];
            break;
        default:
            break;
    }
}

@end