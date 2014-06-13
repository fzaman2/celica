//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"


@implementation MainScene

- (void)didLoadFromCCB {
   
   // GestureRecognizer Code
   UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   swipeUp.numberOfTouchesRequired = 1;
   swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
   
   UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   swipeDown.numberOfTouchesRequired = 1;
   swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
   
   UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   swipeRight.numberOfTouchesRequired = 1;
   swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
   
   UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   swipeLeft.numberOfTouchesRequired = 1;
   swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
   
   UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
   tapped.numberOfTapsRequired = 1;
   tapped.numberOfTouchesRequired = 1;
   tapped.cancelsTouchesInView = NO;
   
   [[[CCDirector sharedDirector] view] addGestureRecognizer:tapped];
   
}

-(void)screenTapped
{
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

-(void)onExit
{
    [self stopAllActions];
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [super onExit];
}

@end
