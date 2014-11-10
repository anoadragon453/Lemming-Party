//
//  CaveScene.h
//  Lemming-Party
//
//  Created by Abhishyant Khare on 11/9/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import AVFoundation;

@import CoreMotion;
@interface CaveScene : SKScene <SKPhysicsContactDelegate, AVAudioPlayerDelegate,UIGestureRecognizerDelegate>

@end
NSMutableArray *lemmingArray;
SKNode *myWorld;
CMMotionManager *_myMotionManager;