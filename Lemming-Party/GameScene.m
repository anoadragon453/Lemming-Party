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
static const uint32_t sandCategory = 0x1 << 1; // 00000000000000000000000000000010
static const uint32_t lemmingCategory = 0x1 << 2;  // 00000000000000000000000000000100

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    // Set up the gravity
    [[self physicsWorld] setGravity:CGVectorMake(0.0, -2.0)];
    sandParticles = [[NSMutableArray alloc] init] ;
    stillHolding = true;
    
    // Create a rectangle around the screen borders
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
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
    
    // SEND IN THE LEMMINGS!!!
    [self createAmountOfLemmings:10];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
       
        [self createSand:location];
            }
    
    
}
-(void) createSand:(CGPoint ) location{
    for(int i = 0; i <3; i++){
        
        
        SKSpriteNode *sand = [SKSpriteNode spriteNodeWithImageNamed:@"sand-particle"];
        
        sand.xScale = 2.0;
        sand.yScale = 2.0;
        float x = location.x+ (float)(2i);
        float y = location.y + (float)(i);
        sand.position = CGPointMake(x, y);
        
        sand.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sand.size];
        sand.physicsBody.allowsRotation = NO;
        
        [sandParticles addObject:sand];
        [self addChild:sand];
    }

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [self createSand:location];
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPress:) object:[NSValue valueWithCGPoint:location]];
    }
    
}
-(void) longPress: (NSValue *) locationVal{
    for(int i = 0; i <3; i++){
        
        
        SKSpriteNode *sand = [SKSpriteNode spriteNodeWithImageNamed:@"sand-particle"];
        CGPoint location = [locationVal CGPointValue];
        sand.xScale = 2.0;
        sand.yScale = 2.0;
        float x = location.x+ (float)(2i);
        float y = location.y + (float)(i);
        sand.position = CGPointMake(x, y);
        sand.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sand.size];
        sand.physicsBody.allowsRotation = NO;
        
        [sandParticles addObject:sand];
        [self addChild:sand];
    }
    
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