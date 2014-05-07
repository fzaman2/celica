//
//  Missile.m
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Missile.h"

@implementation Missile

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"missile";
}

@end
