//
//  GameScene.m
//  Lemming-Party
//
//  Created by Andrew Morgan on 11/8/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [[self physicsWorld] setGravity:CGVectorMake(0.0, -2.0)];
    sandParticles = [[NSMutableArray alloc] init] ;
    stillHolding = true;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
  
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for(int i = 0; i <3; i++){
            
            
            SKSpriteNode *sand = [SKSpriteNode spriteNodeWithImageNamed:@"sand-particle"];
            
            sand.xScale = 2.0;
            sand.yScale = 2.0;
            float x = location.x+ (float)(2i);
            float y = location.y + (float)(i);
            sand.position = CGPointMake(x, y);
            sand.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sand.size];
            
            [sandParticles addObject:sand];
            [self addChild:sand];
    }
        [self performSelector:@selector(longPress:) withObject:[NSValue valueWithCGPoint:location] afterDelay:1.0];
    }
   
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        for(int i = 0; i <3; i++){
            
        
        SKSpriteNode *sand = [SKSpriteNode spriteNodeWithImageNamed:@"sand-particle"];
        
        sand.xScale = 2.0;
        sand.yScale = 2.0;
            float x = location.x+ (float)(2i);
            float y = location.y + (float)(i);
            sand.position = CGPointMake(x, y);
        sand.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sand.size];
        
        [sandParticles addObject:sand];
        [self addChild:sand];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPress:) object:[NSValue valueWithCGPoint:location]];
        
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
        
        [sandParticles addObject:sand];
        [self addChild:sand];
    }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
