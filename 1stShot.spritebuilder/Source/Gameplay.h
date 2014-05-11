//
//  Gameplay.h
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <CoreMotion/CoreMotion.h>

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

@property (strong, nonatomic)CMMotionManager *motionManager;

@end
