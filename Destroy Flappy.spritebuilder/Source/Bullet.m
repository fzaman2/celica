//
//  Bullet.m
//  Destroy Flappy
//
//  Created by Faisal on 5/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (void)didLoadFromCCB {
   self.physicsBody.collisionType = @"bullet";
}

@end
