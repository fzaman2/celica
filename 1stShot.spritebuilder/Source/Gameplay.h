//
//  Gameplay.h
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate>


-(void)screenWasSwipedUp;
-(void)screenWasSwipedDown;

@end
