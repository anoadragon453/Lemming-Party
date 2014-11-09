
//
//  GameScene.h
//  Lemming-Party
//

//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>



@end


int treeTouched;
NSString* treeName;
NSMutableArray *lemmingArray;
NSMutableArray *lemmingLives;
NSMutableArray *trees;
// World node - add every sprite to this
SKNode *world;
