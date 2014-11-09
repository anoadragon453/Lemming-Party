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
static const uint32_t sceneryCategory  = 0x1 << 0;
static const uint32_t objectCategory = 0x1 << 1;
static const uint32_t lemmingCategory = 0x1 << 2;
static const uint32_t cliffCategory = 0x1 << 3;

int lemmingBackwards;
CGFloat rate;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    lemmingArray = [[NSMutableArray alloc] init];
    trees = [[NSMutableArray alloc] init];
    lemmingBackwards = NO;
    rate = .05;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   // self.anchorPoint = CGPointMake(0.5, 0.5);
    SKNode *myWorld = [SKNode node];
    myWorld.name = @"world";
    [self addChild:myWorld];
    SKNode *camera = [SKNode node];
    camera.name = @"camera";
    [myWorld addChild:camera];
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
    [self addChild:planet];
    
    // Create the floor
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"platform.png"];
    floor.name = @"floor";
    floor.position = CGPointMake(0, 80);
    floor.anchorPoint = CGPointMake(0, 0);
    floor.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"platform.png"]];
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(1900, 180)];
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.categoryBitMask = sceneryCategory;
    [myWorld addChild:floor];
    
    // Create the cliff
    SKSpriteNode *cliff = [SKSpriteNode spriteNodeWithImageNamed:@"cliff.png"];
    cliff.name = @"cliff";
    cliff.position = CGPointMake(900, 250);
    cliff.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"cliff.png"]];
    cliff.physicsBody = [SKPhysicsBody bodyWithTexture:cliff.texture size:cliff.texture.size];
    cliff.physicsBody.dynamic = NO;
    cliff.physicsBody.categoryBitMask = cliffCategory;
    cliff.physicsBody.collisionBitMask = objectCategory;
    [myWorld addChild:cliff];
    for(int i = 1; i <6; i++){
    SKSpriteNode *cliffground = [SKSpriteNode spriteNodeWithImageNamed:@"cliff ground.png"];
    cliffground.position = CGPointMake(850+i*(cliff.size.width-50), 250);
    cliffground.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"cliff ground.png"]];
    cliffground.physicsBody = [SKPhysicsBody bodyWithTexture:cliffground.texture size:cliffground.texture.size];
    cliffground.physicsBody.dynamic = NO;
    cliffground.physicsBody.categoryBitMask = cliffCategory;
        cliffground.physicsBody.collisionBitMask = objectCategory;
    [myWorld addChild:cliffground];
    }
    
    // Create the spaceship
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship.png"];
    spaceship.position = CGPointMake(100, 280);
    spaceship.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"spaceship.png"]];
    spaceship.size = CGSizeMake(spaceship.size.width/1.25, spaceship.size.height/1.25);
    
    [myWorld addChild:spaceship];
    //Create the tree
    SKSpriteNode *tree = [SKSpriteNode spriteNodeWithImageNamed:@"tree1"];
    // tree.anchorPoint = CGPointMake(0, 0);
    tree.position = CGPointMake(435, 350);
    tree.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"tree1.png"]];
    // CGSize treeBodySize = CGSizeMake(30, 130);
    tree.physicsBody = [SKPhysicsBody bodyWithTexture:tree.texture size:tree.size];
    [trees addObject:tree];
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
    tree.physicsBody.mass = 9999999999;
    tree.physicsBody.categoryBitMask = objectCategory;
    tree.physicsBody.collisionBitMask = lemmingCategory;
    tree.physicsBody.dynamic = NO;
    tree.name = treeName;
  
    [myWorld addChild:tree];
    
    // SEND IN THE LEMMINGS!!!
    [self createAmountOfLemmings:10: myWorld];
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
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:[self childNodeWithName:@"world"]];
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:location];
    if(body && [body.node.name isEqualToString:@"tree"]){
        
    
    
    treeTouched++;
    if(treeTouched == 1){
        SKSpriteNode *tree = [trees objectAtIndex:0];
        [tree removeFromParent];
        [trees removeAllObjects];
        
  
        
    
        SKSpriteNode *tree2 = [SKSpriteNode spriteNodeWithImageNamed:@"tree2"];
        // tree.anchorPoint = CGPointMake(0, 0);
        tree2.position = CGPointMake(435, 350);
        tree2.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"tree2.png"]];
        // CGSize treeBodySize = CGSizeMake(30, 130);
        tree2.physicsBody = [SKPhysicsBody bodyWithTexture:tree2.texture size:tree2.size];
        tree2.physicsBody.allowsRotation = NO;
        tree2.physicsBody.mass = 9999999999;
        tree2.physicsBody.categoryBitMask = objectCategory;
        tree2.physicsBody.collisionBitMask = lemmingCategory;
        tree2.physicsBody.dynamic = NO;
        tree2.name = treeName;
        [trees addObject:tree2];
        [[self childNodeWithName:@"world"] addChild:tree2];
        return;

    }
        if(treeTouched == 2){
            SKSpriteNode *tree = [trees objectAtIndex:0];
            [tree removeFromParent];
            [trees removeAllObjects];
            
            
            
            
            SKSpriteNode *tree3 = [SKSpriteNode spriteNodeWithImageNamed:@"tree3"];
            // tree.anchorPoint = CGPointMake(0, 0);
            tree3.position = CGPointMake(435, 350);
            tree3.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"tree3.png"]];
            // CGSize treeBodySize = CGSizeMake(30, 130);
            tree3.physicsBody = [SKPhysicsBody bodyWithTexture:tree3.texture size:tree3.size];
            tree3.physicsBody.allowsRotation = NO;
            tree3.physicsBody.mass = 9999999999;
            tree3.physicsBody.categoryBitMask = objectCategory;
            tree3.physicsBody.collisionBitMask = lemmingCategory;
            tree3.physicsBody.dynamic = NO;
            tree3.name = treeName;
            [trees addObject:tree3];
            [[self childNodeWithName:@"world"] addChild:tree3];
            return;
            
        }
        if(treeTouched == 3){
            SKSpriteNode *tree = [trees objectAtIndex:0];
            float height = tree.texture.size.height;
            [tree removeFromParent];
            [trees removeAllObjects];
            
            
            
            
            SKSpriteNode *stump = [SKSpriteNode spriteNodeWithImageNamed:@"treestump"];
  
            stump.position = CGPointMake(435, 370-height/2);
            
            stump.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"treestump.png"]];
            // CGSize treeBodySize = CGSizeMake(30, 130);
            stump.physicsBody = [SKPhysicsBody bodyWithTexture:stump.texture size:stump.size];
           // stump.anchorPoint = CGPointMake(0, 0);
            stump.physicsBody.allowsRotation = NO;
            stump.physicsBody.mass = 9999999999;
            stump.physicsBody.categoryBitMask = objectCategory;
            stump.physicsBody.collisionBitMask = lemmingCategory;
            stump.physicsBody.collisionBitMask = objectCategory;
            stump.physicsBody.dynamic = YES;
            stump.physicsBody.affectedByGravity = NO;
            stump.name = @"stump";
           // [trees addObject:tree3];
            [[self childNodeWithName:@"world"] addChild:stump];
            
            SKSpriteNode *treetop = [SKSpriteNode spriteNodeWithImageNamed:@"treetop"];
         
            treetop.position = CGPointMake(435, (treetop.size.height)/2+(stump.texture.size.height)+(390-height/2));
            
            treetop.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"treetop"]];
            // CGSize treeBodySize = CGSizeMake(30, 130);
            CGSize rectSize = CGSizeMake(treetop.texture.size.width-200, treetop.texture.size.height-150);
            treetop.physicsBody = [SKPhysicsBody bodyWithTexture:treetop.texture size:treetop.texture.size];            //treetop.anchorPoint = CGPointMake(0, 0);
            //treetop.physicsBody.allowsRotation = NO;
            treetop.physicsBody.mass = 15;
            treetop.physicsBody.categoryBitMask = objectCategory;
       
            treetop.physicsBody.collisionBitMask = objectCategory | cliffCategory | lemmingCategory;
            treetop.physicsBody.contactTestBitMask = cliffCategory;
                       [treetop.physicsBody applyTorque:8.0];
            treetop.physicsBody.dynamic = YES;
            treetop.physicsBody.affectedByGravity = YES;
            treetop.name = @"treetop";
            // [trees addObject:tree3];
            [[self childNodeWithName:@"world"] addChild:treetop];
           

            return;
            
        }


    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
//change yo
-(void)createAmountOfLemmings:(int)count: (SKNode *) myWorld {
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
    
    if (firstBody.categoryBitMask == lemmingCategory && secondBody.categoryBitMask == sceneryCategory) {
        rate *= -1;
    }
    if((firstBody.categoryBitMask == objectCategory && secondBody.categoryBitMask == cliffCategory) || (firstBody.categoryBitMask == cliffCategory && secondBody.categoryBitMask == objectCategory)){
        SKSpriteNode* treetop = (SKSpriteNode *)[[self childNodeWithName:@"world"] childNodeWithName:@"treetop"];
    SKSpriteNode* stump = (SKSpriteNode *)[[self childNodeWithName:@"world"] childNodeWithName:@"stump"];
        stump.physicsBody.dynamic = NO;
        
                    CGSize rectSize = CGSizeMake(treetop.texture.size.width-270, treetop.texture.size.height);
  
        treetop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rectSize];
        treetop.physicsBody.affectedByGravity = NO;
              treetop.physicsBody.dynamic = NO;
       
        for(SKSpriteNode* lemming in lemmingArray){
            [lemming.physicsBody applyImpulse:CGVectorMake(5.0 , 5.0)];
            //lemming.physicsBody.affectedByGravity = NO;
            
        
        }
       

    }

}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    CGPoint prevLoc = [touch previousLocationInNode:self];
    CGPoint currentLoc = [touch locationInNode:self];
    CGPoint shift = CGPointMake(currentLoc.x-prevLoc.x, currentLoc.y-prevLoc.y);
  //  NSLog(@"%f , %f", shift.x, shift.y);
    SKNode* camera = [self childNodeWithName:@"world"];
    CGPoint newPos = CGPointMake(camera.position.x+shift.x, camera.position.y);

    SKSpriteNode* floor = (SKSpriteNode*)[camera childNodeWithName:@"floor"];
    CGPoint floorPos = floor.position;
    NSLog(@"%f , %f", floorPos.x, floorPos.y);
    NSLog(@"%f , %f", newPos.x, newPos.y);

    if(newPos.x < floorPos.x )
        camera.position = newPos;
    else
        camera.position = CGPointMake(floorPos.x, newPos.y);

}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    
    for (SKSpriteNode *lemming in lemmingArray) {
        CGVector relativeVelocity = CGVectorMake(200-lemming.physicsBody.velocity.dx, 200-lemming.physicsBody.velocity.dy);
        lemming.physicsBody.velocity=CGVectorMake(lemming.physicsBody.velocity.dx+relativeVelocity.dx*rate, lemming.physicsBody.velocity.dy+relativeVelocity.dy*rate);
    }
}

- (int)getRandomNumberBetween:(int)from to:(int)to{
    return (int)from + arc4random() % (to-from+1);
}

@end