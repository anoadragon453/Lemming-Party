//
//  GameScene.m
//  Lemming-Party
//
//  Created by Andrew Morgan on 11/8/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

// Bitmasks
static const uint32_t sceneryCategory  = 0x1 << 0;  // 00000000000000000000000000000001
static const uint32_t objectCategory = 0x1 << 1;
static const uint32_t lemmingCategory = 0x1 << 2;  // 00000000000000000000000000000100

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    // Set up the gravity
    [[self physicsWorld] setGravity:CGVectorMake(0.0, -2.0)];
    
    treeTouched = 0;
    treeName = @"tree";
    // Create a rectangle around the screen borders
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    // Create the background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"sky.png"];
    background.position = CGPointMake(360, 320);
    [self addChild:background];
    
    // Create the floor
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"platform.png"];
    floor.position = CGPointMake(0, 80);
    floor.anchorPoint = CGPointMake(0, 0);
    floor.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"platform.png"]];
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(2400, 200)];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.categoryBitMask = sceneryCategory;
    [self addChild:floor];
    
    // Create the cliff
    SKSpriteNode *cliff = [SKSpriteNode spriteNodeWithImageNamed:@"cliff.png"];
    cliff.position = CGPointMake(900, 300);
    cliff.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"cliff.png"]];
    cliff.physicsBody = [SKPhysicsBody bodyWithTexture:cliff.texture size:cliff.texture.size];
    cliff.physicsBody.dynamic = NO;
    floor.physicsBody.categoryBitMask = sceneryCategory;
    [self addChild:cliff];
    
    // Create the spaceship
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship.png"];
    spaceship.position = CGPointMake(100, 320);
    spaceship.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"spaceship.png"]];
    
    [self addChild:spaceship];
    //Create the tree
   SKSpriteNode *tree = [SKSpriteNode spriteNodeWithImageNamed:@"shit tree"];
   // tree.anchorPoint = CGPointMake(0, 0);
    tree.position = CGPointMake(518, 250);
    tree.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"shit tree.png"]];
   // CGSize treeBodySize = CGSizeMake(30, 130);
    tree.physicsBody = [SKPhysicsBody bodyWithTexture:tree.texture size:tree.size];

   

    tree.physicsBody.allowsRotation = NO;
    tree.physicsBody.categoryBitMask = objectCategory;
    tree.name = treeName;
  
    [self addChild:tree];
    
    
    // SEND IN THE LEMMINGS!!!
    [self createAmountOfLemmings:10];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSLog(@"%f , %f", location.x, location.y);
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:location];
    if(body && [body.node.name isEqualToString:treeName]){
        treeTouched++;
        NSLog(@"%d", treeTouched);
    }
    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        
       // [self createSand:location];
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {

    }
    
}
-(void) didBeginContact:(SKPhysicsContact *)contact{

}
-(void)createAmountOfLemmings:(int)count {
    for (int i = 0; i < count; i++) {
        // Create the lemming sprite node
        SKSpriteNode *lemming = [SKSpriteNode spriteNodeWithImageNamed:@"lemming.png"];
        lemming.position = CGPointMake(200, 300);
        [lemmingArray addObject:lemming];
        
        lemming.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"lemming.png"]];
        lemming.physicsBody = [SKPhysicsBody bodyWithTexture:lemming.texture size:lemming.texture.size];
        lemming.physicsBody.allowsRotation = NO;
        lemming.physicsBody.categoryBitMask = lemmingCategory;
        
        [self addChild:lemming];
        
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
 
    /* Called before each frame is rendered */
}

@end