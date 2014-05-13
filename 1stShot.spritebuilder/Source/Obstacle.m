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
    CCNode *_target;
    int _random;
    int _yPosition;
}
// distance between top and bottom pipe
static const CGFloat pipeDistance = 100.f;

- (void)setupRandomPosition {
    _random = arc4random() % 5;
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
        case 4:
            _yPosition = 430;
            break;
        default:
            break;
    }
    _topPipe.position = ccp(_topPipe.position.x, _yPosition);
    _target.position = ccp(_target.position.x,_topPipe.position.y + pipeDistance/2);
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y + pipeDistance);
//    CCLOG(@"%f",_bottomPipe.position.x);
//    CCLOG(@"%f",_topPipe.position.y);
}

- (void)didLoadFromCCB {
    _topPipe.physicsBody.collisionType = @"level";
    _topPipe.physicsBody.sensor = TRUE;
    _bottomPipe.physicsBody.collisionType = @"level";
    _bottomPipe.physicsBody.sensor = TRUE;
    _target.physicsBody.collisionType = @"target";
    _target.physicsBody.sensor = TRUE;
}

@end