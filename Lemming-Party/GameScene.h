
//
//  GameScene.h
//  Lemming-Party
//

//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>



@end


BOOL stillHolding;
NSMutableArray *lemmingArray;

// World node - add every sprite to this
SKNode *world;
