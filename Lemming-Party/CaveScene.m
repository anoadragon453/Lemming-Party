
//
//  CaveScene.m
//  Lemming-Party
//
//  Created by Abhishyant Khare on 11/9/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "CaveScene.h"
// Bitmasks
static const uint32_t sceneryCategory  = 0x1 << 0;
static const uint32_t objectCategory = 0x1 << 1;
static const uint32_t lemmingCategory = 0x1 << 2;
static const uint32_t cliffCategory = 0x1 << 3;
static const uint32_t caveCategory = 0x1 <<4;
static const uint32_t triangleCategory = 0x1 << 5;


@implementation CaveScene
int lemmingBackwards;
CGFloat rate;
-(void)didMoveToView:(SKView *)view {
    myWorld = [SKNode node];
    myWorld.name = @"world";
    lemmingBackwards = NO;
    rate = .05;
    [self initializeAccelerometerTracking];
    [self addChild:myWorld];
    lemmingArray = [[NSMutableArray alloc] init];
       self.physicsWorld.contactDelegate = self;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-5, 0, 5, 10000)];

    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"cavebgback"];
    background.position = CGPointMake(360, 385);
    background.yScale = 1.05;
    background.zPosition = 0;
    [self addChild:background];
    SKSpriteNode *crystals = [SKSpriteNode spriteNodeWithImageNamed:@"cavebg4.PNG"];
    crystals.position = CGPointMake(360, 385);
    crystals.yScale = 1.05;
    crystals.zPosition = 3;
    [self addChild:crystals];
    
    SKSpriteNode *leftFloor = [SKSpriteNode spriteNodeWithImageNamed:@"cave ground left.PNG"];
    leftFloor.texture = [SKTexture textureWithImageNamed:@"cave ground left.PNG"];
    leftFloor.position= CGPointMake(-195, 92);
    leftFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftFloor.size];
    leftFloor.physicsBody.affectedByGravity = NO;
    leftFloor.physicsBody.dynamic = NO;
    leftFloor.physicsBody.categoryBitMask = sceneryCategory;
    leftFloor.physicsBody.collisionBitMask = objectCategory | lemmingCategory;
    leftFloor.physicsBody.contactTestBitMask = objectCategory;
     //   leftFloor.anchorPoint = CGPointMake(0, 0);
    leftFloor.zPosition = 10;
    [self addChild:leftFloor];
    SKSpriteNode *centerFloor = [SKSpriteNode spriteNodeWithImageNamed:@"cave ground center.PNG"];
    centerFloor.texture = [SKTexture textureWithImageNamed:@"cave ground center.PNG"];
    centerFloor.position= CGPointMake(460, 90);
    centerFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:centerFloor.size];
    centerFloor.physicsBody.affectedByGravity = NO;
    centerFloor.physicsBody.dynamic = NO;
    centerFloor.physicsBody.categoryBitMask = sceneryCategory;
    centerFloor.physicsBody.collisionBitMask = lemmingCategory | objectCategory | cliffCategory;
    centerFloor.physicsBody.contactTestBitMask = objectCategory | cliffCategory;
   // centerFloor.anchorPoint = CGPointMake(0, 0);
    centerFloor.zPosition = 10;
    [self addChild:centerFloor];
    SKSpriteNode *rightFloor = [SKSpriteNode spriteNodeWithImageNamed:@"cave ground right.PNG"];
    rightFloor.texture = [SKTexture textureWithImageNamed:@"cave ground right.PNG"];
    rightFloor.position= CGPointMake(1080, 90);
    rightFloor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightFloor.size];
    rightFloor.physicsBody.affectedByGravity = NO;
    rightFloor.physicsBody.dynamic = NO;
    rightFloor.physicsBody.categoryBitMask = sceneryCategory;
    rightFloor.physicsBody.collisionBitMask = lemmingCategory | objectCategory |cliffCategory;
    rightFloor.physicsBody.contactTestBitMask = objectCategory | cliffCategory;
    //rightFloor.anchorPoint = CGPointMake(0, 0);
    rightFloor.zPosition = 10;
    [self addChild:rightFloor];
    SKSpriteNode* stalagmite = [SKSpriteNode spriteNodeWithImageNamed:@"stalagtite.PNG"];
    stalagmite.texture = [SKTexture textureWithImageNamed:@"stalagtite.PNG"];
    stalagmite.position= CGPointMake(180, 590);
    stalagmite.physicsBody = [SKPhysicsBody bodyWithTexture:stalagmite.texture  size: stalagmite.size];
    stalagmite.physicsBody.affectedByGravity = NO;
    stalagmite.physicsBody.dynamic = YES;
    stalagmite.yScale = .8;
    stalagmite.xScale = .7;
    stalagmite.name = @"stalagmite";
    stalagmite.physicsBody.categoryBitMask = objectCategory;
    stalagmite.physicsBody.collisionBitMask = lemmingCategory | sceneryCategory;
    stalagmite.physicsBody.contactTestBitMask = sceneryCategory;
    
    
   // stalagmite.anchorPoint = CGPointMake(0, 0);
    stalagmite.zPosition = 10;
    [self addChild:stalagmite];
    SKSpriteNode* stalagtite = [SKSpriteNode spriteNodeWithImageNamed:@"stalagtite.PNG"];
    stalagtite.texture = [SKTexture textureWithImageNamed:@"stalagtite.PNG"];
    stalagtite.position= CGPointMake(720, 590);
    stalagtite.physicsBody = [SKPhysicsBody bodyWithTexture:stalagtite.texture  size: stalagtite.size];
    stalagtite.physicsBody.affectedByGravity = NO;
    stalagtite.physicsBody.dynamic = YES;
    stalagtite.yScale = .8;
    stalagtite.xScale = .52;
    stalagtite.name = @"stalagtite";
    stalagtite.physicsBody.categoryBitMask = cliffCategory;
    //stalagmite.physicsBody.categoryBitMask = objectCategory;
    stalagtite.physicsBody.collisionBitMask = lemmingCategory | sceneryCategory;
    stalagtite.physicsBody.contactTestBitMask = sceneryCategory;
    
    // stalagtite.anchorPoint = CGPointMake(0, 0);
    stalagtite.zPosition = 10;
    [self addChild:stalagtite];
                                
    [self createAmountOfLemmings:10 withWorld:myWorld];


}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:[self childNodeWithName:@"world"]];
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:location];
    SKNode *node = [self nodeAtPoint:location];
    
    if(body && [body.node.name isEqualToString:@"stalagmite"]){
        SKSpriteNode* stalagmite = (SKSpriteNode *)[self childNodeWithName:@"stalagmite"];
        stalagmite.physicsBody.affectedByGravity = YES;
                                                    
    }
    if(body && [body.node.name isEqualToString:@"stalagtite"]){
        SKSpriteNode* stalagmite = (SKSpriteNode *)[self childNodeWithName:@"stalagtite"];
        stalagmite.physicsBody.affectedByGravity = YES;
        
    }
    
    
   
}
-(int)getRandomNumberBetween:(int)from to:(int)to{
    return (float)from + arc4random() % (to-from+1);
}
-(void)createAmountOfLemmings:(int)count withWorld:(SKNode *)myWorld {
    for (int i = 0; i < count; i++) {
        // Create the lemming sprite node
        SKSpriteNode *lemming = [SKSpriteNode spriteNodeWithImageNamed:@"lemming.png"];
        //lemming.size = CGSizeMake(lemming.size.width/2, lemming.size.width/2);
        
        lemming.position = CGPointMake([self getRandomNumberBetween:0 to:50], 100);
        [lemmingArray addObject:lemming];
        
        lemming.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"lemming.png"]];
        //CGSize resize = CGSizeMake(lemming.texture.size.width/2, lemming.texture.size.height/2);
        lemming.physicsBody = [SKPhysicsBody bodyWithTexture:lemming.texture size:lemming.texture.size];
        lemming.physicsBody.allowsRotation = NO;
        lemming.physicsBody.categoryBitMask = lemmingCategory;
        lemming.physicsBody.contactTestBitMask = sceneryCategory | caveCategory;
        lemming.physicsBody.collisionBitMask = sceneryCategory | objectCategory | lemmingCategory | cliffCategory | caveCategory;
        lemming.physicsBody.velocity = CGVectorMake(0, 0);
        lemming.physicsBody.linearDamping = 0;
        lemming.physicsBody.friction = .5;
        lemming.zPosition = 30;
        [myWorld addChild:lemming];
        
    }
}
-(void)didBeginContact:(SKPhysicsContact *)contact {
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if((firstBody.categoryBitMask == sceneryCategory && secondBody.categoryBitMask == objectCategory) || (firstBody.categoryBitMask == objectCategory && secondBody.categoryBitMask == sceneryCategory)){
        SKSpriteNode* stalagmite = (SKSpriteNode *)[self childNodeWithName:@"stalagmite"];
        CGSize wreckt = CGSizeMake(stalagmite.size.width+20, stalagmite.size.height-121);
       ;
        stalagmite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wreckt];
        //stalagmite.position = CGPointMake(stalagmite.position.x, stalagmite.position.y-100);
        stalagmite.physicsBody.affectedByGravity = NO;
        stalagmite.physicsBody.dynamic = NO;
        NSLog(@"swag");

    }
    if((firstBody.categoryBitMask == sceneryCategory && secondBody.categoryBitMask == cliffCategory) || (firstBody.categoryBitMask == cliffCategory && secondBody.categoryBitMask == sceneryCategory)){
        SKSpriteNode* stalagtite = (SKSpriteNode *)[self childNodeWithName:@"stalagtite"];
        CGSize wreckt = CGSizeMake(stalagtite.size.width+20, stalagtite.size.height-125);
        stalagtite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wreckt];
        stalagtite.physicsBody.affectedByGravity = NO;
        stalagtite.physicsBody.dynamic = NO;
        NSLog(@"swag");
        
    }
    
    
}
-(void)initializeAccelerometerTracking {
    _myMotionManager = [[CMMotionManager alloc] init];
    _myMotionManager.accelerometerUpdateInterval = 0.2; // tweak the sensitivity of intervals
    [_myMotionManager startAccelerometerUpdates];
    
    // do [_myMotionManager stopAccelerometerUpdates]; when we're done
}
-(void)update:(CFTimeInterval)currentTime {
    for (SKSpriteNode *lemming in lemmingArray) {
        CMAccelerometerData* data = _myMotionManager.accelerometerData;
        if (fabs(data.acceleration.y) > 0.1) {
            float yAcceleration = 15.0 * data.acceleration.y;
            float randomAccel = [self getRandomNumberBetween:1 to:15]/100.0;
            [lemming.physicsBody applyForce:CGVectorMake(yAcceleration += randomAccel, 0.0)];
        } else {
            //[lemming.physicsBody applyImpulse:CGVectorMake(lemming.physicsBody.velocity.dx/2, 0.0)];
        }
      
        if (lemming.physicsBody.velocity.dx < 0.1) {
            lemming.xScale = -1.0;
        } else if (lemming.physicsBody.velocity.dx > 0.1){
            lemming.xScale = 1.0;
        }
    }

}


@end
