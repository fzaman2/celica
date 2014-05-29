//
//  Gameplay.h
//  1stShot
//
//  Created by Faisal on 4/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <iAd/iAd.h>
#import "GADInterstitial.h"

#ifndef IADHELPER_LOGGING
#define IADHELPER_LOGGING 0
#endif

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate, UIGestureRecognizerDelegate, ADBannerViewDelegate,
GADInterstitialDelegate>
{
}

@property NSInteger highScore;

-(void)screenWasSwipedUp;
-(void)screenWasSwipedDown;
// Interstitials
-(void)cycleInterstitial;
-(void)presentInterlude;

@end
