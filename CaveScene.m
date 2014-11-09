
//
//  CaveScene.m
//  Lemming-Party
//
//  Created by Abhishyant Khare on 11/9/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "CaveScene.h"

@implementation CaveScene
-(void)didMoveToView:(SKView *)view {
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"cavebgback"];
    background.position = CGPointMake(360, 385);
    background.yScale = 1.05;
    [self addChild:background];
}
@end
