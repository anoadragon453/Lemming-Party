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
static const uint32_t lemmingCategory = 0x1 << 2;  // 00000000000000000000000000000100
static const uint32_t objectCategory = 0x1 << 1;
-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    lemmingArray = [[NSMutableArray alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Set up the gravity
    [[self physicsWorld] setGravity:CGVectorMake(0.0, -2.0)];
    
    treeTouched = 0;
    lemmingLives = [[NSMutableArray alloc] init];
    treeName = @"tree";
    // Create a rectangle around the screen borders
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate = self;
    // Create the background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"sky.png"];
    background.position = CGPointMake(360, 320);
    [self addChild:background];
    
    // Create the planet
    SKSpriteNode *planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet.png"];
    planet.position = CGPointMake(screenRect.size.width/2, screenRect.size.height/2);
    planet.alpha = 0.7;
    [background addChild:planet];
    
    // Create the floor
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"platform.png"];
    floor.position = CGPointMake(0, 80);
    floor.anchorPoint = CGPointMake(0, 0);
    floor.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"platform.png"]];
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(2400, 180)];
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
    spaceship.position = CGPointMake(100, 290);
    spaceship.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"spaceship.png"]];
    spaceship.size = CGSizeMake(spaceship.size.width/1.25, spaceship.size.height/1.25);
    
    [self addChild:spaceship];
    //Create the tree
   SKSpriteNode *tree = [SKSpriteNode spriteNodeWithImageNamed:@"shit tree"];
   // tree.anchorPoint = CGPointMake(0, 0);
    tree.position = CGPointMake(518, 350);
    tree.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"shit tree.png"]];
   // CGSize treeBodySize = CGSizeMake(30, 130);
    tree.physicsBody = [SKPhysicsBody bodyWithTexture:tree.texture size:tree.size];
    for(int i = 0; i <10 ; i++){
        SKSpriteNode *lemmingLife = [SKSpriteNode spriteNodeWithImageNamed:@"lemming"];
        lemmingLife.position = CGPointMake(20*(i+1), 650);
        //lemmingLife.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"lemming.png"]];
        lemmingLife.xScale = .85;
        lemmingLife.yScale = .85;
        [lemmingLives addObject:lemmingLife];
        [self addChild:lemmingLife];
        
    }

   

    tree.physicsBody.allowsRotation = NO;
    tree.physicsBody.mass = 9999;
    tree.physicsBody.dynamic = NO;
    tree.physicsBody.categoryBitMask = objectCategory;
    tree.physicsBody.collisionBitMask = lemmingCategory;
    tree.name = treeName;
  
    [self addChild:tree];
    
    
    // SEND IN THE LEMMINGS!!!
    [self createAmountOfLemmings:10];
}


-(void) killLemming{
    SKSpriteNode *deadlemming = [lemmingArray objectAtIndex:lemmingArray.count-1];
    [deadlemming removeFromParent];
    [lemmingArray removeObjectAtIndex:lemmingArray.count-1];
    //[self delete:deadlemming];
    SKSpriteNode *lifeIcon = [lemmingLives objectAtIndex:lemmingLives.count -1];
    [lifeIcon removeFromParent];
    [lemmingLives removeObjectAtIndex:lemmingLives.count-1];
    //[self delete:lifeIcon];
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self killLemming];
    NSLog(@"Array %@", lemmingArray);
}
//change yo
-(void)createAmountOfLemmings:(int)count {
    for (int i = 0; i < count; i++) {
        // Create the lemming sprite node
        SKSpriteNode *lemming = [SKSpriteNode spriteNodeWithImageNamed:@"lemming.png"];
        //lemming.size = CGSizeMake(lemming.size.width/2, lemming.size.width/2);
        
        lemming.position = CGPointMake([self getRandomNumberBetween:200 to:400], 300);
        [lemmingArray addObject:lemming];
        
        lemming.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"lemming.png"]];
        //CGSize resize = CGSizeMake(lemming.texture.size.width/2, lemming.texture.size.height/2);
        lemming.physicsBody = [SKPhysicsBody bodyWithTexture:lemming.texture size:lemming.texture.size];
        lemming.physicsBody.allowsRotation = NO;
        lemming.physicsBody.categoryBitMask = lemmingCategory;
        lemming.physicsBody.contactTestBitMask = sceneryCategory;
        lemming.physicsBody.collisionBitMask = sceneryCategory | objectCategory;
        lemming.physicsBody.velocity = self.physicsBody.velocity;
        lemming.physicsBody.linearDamping = 0;
        
        
        CGFloat radianFactor = 0.0174532925;
        CGFloat rotationInDegrees = lemming.zRotation / radianFactor;
        CGFloat newRotationDegrees = rotationInDegrees;
        CGFloat newRotationRadians = newRotationDegrees * radianFactor;
        
        CGFloat r = 100;
        
        CGFloat dx = r * cos(newRotationRadians);
        CGFloat dy = r * sin(newRotationRadians);
        
        // Apply impulse to physics body
        NSLog(@"Impulse: %f, %f", dx, dy);
        //[lemmingSprite.physicsBody applyImpulse:];
        [lemming.physicsBody setVelocity:CGVectorMake(dx,dy)];
        
        //lemming.texture.size = CGSizeMake(lemming.texture.size.width/2, lemming.texture.size.height/2);
        [self addChild:lemming];
        
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    if (contact.bodyA.categoryBitMask == lemmingCategory && contact.bodyB.categoryBitMask == sceneryCategory) {
        CGVector relativeVelocity = CGVectorMake(200-contact.bodyA.velocity.dx, 200-contact.bodyA.velocity.dy);
        contact.bodyA.velocity=CGVectorMake(contact.bodyA.velocity.dx+relativeVelocity.dx*-.05, contact.bodyA.velocity.dy+relativeVelocity.dy*-.05);
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    for (SKSpriteNode *lemming in lemmingArray) {
        CGFloat rate = .05;
        if (lemming.physicsBody.velocity.dx < 0) { // if the lemming is going backwards
            rate *= -1; // reverse it
        }
        CGVector relativeVelocity = CGVectorMake(200-lemming.physicsBody.velocity.dx, 200-lemming.physicsBody.velocity.dy);
        lemming.physicsBody.velocity=CGVectorMake(lemming.physicsBody.velocity.dx+relativeVelocity.dx*rate, lemming.physicsBody.velocity.dy+relativeVelocity.dy*rate);
    }
}

- (int)getRandomNumberBetween:(int)from to:(int)to{
    return (int)from + arc4random() % (to-from+1);
}

@end