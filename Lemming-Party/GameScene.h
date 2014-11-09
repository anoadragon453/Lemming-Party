
//
//  GameScene.h
//  Lemming-Party
//

//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import AVFoundation;
@import CoreMotion;

@interface GameScene : SKScene<SKPhysicsContactDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate>



@end


int treeTouched;
int caveLemmings;

NSString* treeName;
SKSpriteNode *tree;
SKSpriteNode *treeStump;
SKSpriteNode *treeTop;
NSMutableArray *lemmingArray;
NSMutableArray *lemmingLives;
NSMutableArray *trees;
// World node - add every sprite to this
SKNode *world;
AVQueuePlayer *queuePlayer;

int planetTouched;
NSMutableArray *starArray;
NSMutableArray *musicArray;
CMMotionManager *_myMotionManager;