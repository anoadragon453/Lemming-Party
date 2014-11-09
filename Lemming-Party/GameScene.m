//
//  GameScene.m
//  Lemming-Party
//
//  Created by Andrew Morgan on 11/8/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "GameScene.h"
#import "CaveScene.h"
@implementation GameScene

// Bitmasks
static const uint32_t sceneryCategory  = 0x1 << 0;
static const uint32_t objectCategory = 0x1 << 1;
static const uint32_t lemmingCategory = 0x1 << 2;
static const uint32_t cliffCategory = 0x1 << 3;
static const uint32_t caveCategory = 0x1 <<4;
static const uint32_t triangleCategory = 0x1 <<5;

int lemmingBackwards;
CGFloat rate;
AVAudioPlayer *player;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    lemmingArray = [[NSMutableArray alloc] init];
    starArray = [[NSMutableArray alloc] init];
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
    
    // Turn on background music
    NSString *fooVideoPath = [[NSBundle mainBundle] pathForResource:@"Heaven's Night" ofType:@"mp3"];
    NSString *barVideoPath = [[NSBundle mainBundle] pathForResource:@"We Like To Party" ofType:@"mp3"];
    
    AVPlayerItem *fooVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:fooVideoPath]];
    AVPlayerItem *barVideoItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:barVideoPath]];
    
    musicArray = [NSMutableArray arrayWithObjects:fooVideoItem, barVideoItem,nil];
    
    queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObjects:fooVideoItem, barVideoItem,nil]];
    [queuePlayer play];
    
    // Initialize sound for woodcutting
    [self initializeAVAudioPlayer:@"woodcut" fileExtension:@".wav" Volume:1.0 Rate:1.0];
    
    // Music did finish playing notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    treeTouched = 0;
    lemmingLives = [[NSMutableArray alloc] init];
    treeName = @"tree";
    
    // Create a rectangle around the screen borders
    //self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    // Make an invisible wall to the very left.
    SKSpriteNode *leftWall = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(5, 1000)];
    leftWall.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"star.png"]];
    leftWall.position = CGPointMake(0, 0);
    leftWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(5, 3000)];
    leftWall.physicsBody.affectedByGravity = NO;
    leftWall.physicsBody.allowsRotation = NO;
    //[myWorld addChild:leftWall];
    
    self.physicsWorld.contactDelegate = self;
    // Create the background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"sky.png"];
    background.position = CGPointMake(360, 320);
    [self addChild:background];
    
    // Add stars
    [self createStarsWithCount:30];
    
    // Create the planet
    SKSpriteNode *planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet.png"];
    planet.position = CGPointMake(screenRect.size.width/2 + 250, screenRect.size.height + 50);
    planet.alpha = 1;
    planet.name = @"planet";
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
    cliff.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(cliff.texture.size.width - 20, cliff.texture.size.height) ];
    cliff.physicsBody.dynamic = NO;
    cliff.physicsBody.categoryBitMask = cliffCategory;
    cliff.physicsBody.collisionBitMask = objectCategory;
    [myWorld addChild:cliff];
    for(int i = 1; i <6; i++){
        SKSpriteNode *caveEntranceBack;
        SKSpriteNode *caveEntranceFront;
        SKSpriteNode *caveEntranceExtension;
        
        // Add the caveback behind the cliffground
        if (i == 3) {
            caveEntranceBack = [SKSpriteNode spriteNodeWithImageNamed:@"caveback.png"];
            caveEntranceBack.texture = [SKTexture textureWithImageNamed:@"caveback.png"];
            
            caveEntranceBack.position = CGPointMake(850+i*(cliff.size.width-50), 460);
            [myWorld addChild:caveEntranceBack];
        }
        
        SKSpriteNode *cliffground = [SKSpriteNode spriteNodeWithImageNamed:@"cliff ground.png"];
        cliffground.position = CGPointMake(850+i*(cliff.size.width-50), 250);
        cliffground.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"cliff ground.png"]];
        cliffground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cliffground.texture.size];
        cliffground.physicsBody.dynamic = NO;
        cliffground.physicsBody.categoryBitMask = cliffCategory;
        cliffground.physicsBody.collisionBitMask = lemmingCategory | objectCategory;
        cliffground.physicsBody.contactTestBitMask = lemmingCategory | objectCategory;
        
        floor.physicsBody.categoryBitMask = sceneryCategory;
        
        [myWorld addChild:cliffground];
        
        // Add the cave
        if (i == 3) {
            NSLog(@"Adding cave entrance...");
            
            caveEntranceFront = [SKSpriteNode spriteNodeWithImageNamed:@"cavefront.png"];
            caveEntranceFront.texture = [SKTexture textureWithImageNamed:@"cavefront.png"];
            
            caveEntranceFront.position = CGPointMake(caveEntranceBack.position.x + 50, caveEntranceBack.position.y - 10);
            CGSize caveRect = CGSizeMake(caveEntranceFront.texture.size.width-30, caveEntranceFront.texture.size.height);
            caveEntranceFront.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:caveRect];
            caveEntranceFront.physicsBody.categoryBitMask = caveCategory;
            caveEntranceFront.physicsBody.collisionBitMask = lemmingCategory | sceneryCategory;
            caveEntranceFront.name = @"cave";
            [myWorld addChild:caveEntranceFront];
            
            NSLog(@"Add cave entrance extension");
            caveEntranceExtension = [SKSpriteNode spriteNodeWithImageNamed:@"cave extension.png"];
            caveEntranceExtension.texture = [SKTexture textureWithImageNamed:@"cave extension.png"];
            
            caveEntranceExtension.position = CGPointMake(caveEntranceFront.position.x + 200, caveEntranceFront.position.y + 30);
            [myWorld addChild:caveEntranceExtension];
        }
        
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
    
    [self initializeAccelerometerTracking];
    
    // SEND IN THE LEMMINGS!!!
    [self createAmountOfLemmings:10 withWorld:myWorld];
}

-(void)initializeAccelerometerTracking {
    _myMotionManager = [[CMMotionManager alloc] init];
    _myMotionManager.accelerometerUpdateInterval = 0.2; // tweak the sensitivity of intervals
    [_myMotionManager startAccelerometerUpdates];
    
    // do [_myMotionManager stopAccelerometerUpdates]; when we're done
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
-(void) moveLemmingOn{
    SKSpriteNode *deadlemming = [lemmingArray objectAtIndex:lemmingArray.count-1];
    [deadlemming removeFromParent];
    [lemmingArray removeObjectAtIndex:lemmingArray.count-1];
    //[self delete:deadlemming];
   
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKPhysicsBody* body = [self.physicsWorld bodyAtPoint:location];
    SKNode *node = [self nodeAtPoint:location];

  

    if(body && [body.node.name isEqualToString:@"tree"]){
        
        // Play woodcutting sound
        [player play];
        
        treeTouched++;
        if(treeTouched == 1){
            SKSpriteNode *tree = [trees objectAtIndex:0];
            [tree removeFromParent];
            [trees removeAllObjects];
            
            
            
            
            SKSpriteNode *tree2 = [SKSpriteNode spriteNodeWithImageNamed:@"tree2.png"];
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
            
            SKSpriteNode *tree3 = [SKSpriteNode spriteNodeWithImageNamed:@"tree3.png"];
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
            
            SKSpriteNode *stump = [SKSpriteNode spriteNodeWithImageNamed:@"treestump.png"];
            
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
            
            SKSpriteNode *treetop = [SKSpriteNode spriteNodeWithImageNamed:@"treetop.png"];
            
            treetop.position = CGPointMake(440, (treetop.size.height)/2+(stump.texture.size.height)+(390-height/2));
            
            treetop.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"treetop.png"]];
            // CGSize treeBodySize = CGSizeMake(30, 130);
            
            treetop.physicsBody = [SKPhysicsBody bodyWithTexture:treetop.texture size:treetop.size];
            
            //treetop.anchorPoint = CGPointMake(0, 0);
            //treetop.physicsBody.allowsRotation = NO;
            treetop.physicsBody.mass = 15;
            treetop.physicsBody.categoryBitMask = objectCategory;
            
            treetop.physicsBody.collisionBitMask = objectCategory | cliffCategory | lemmingCategory;
            treetop.physicsBody.contactTestBitMask = cliffCategory;
            [treetop.physicsBody applyTorque:8.03];
            treetop.physicsBody.dynamic = YES;
            treetop.physicsBody.affectedByGravity = YES;
            treetop.name = @"treetop";
            // [trees addObject:tree3];
            [[self childNodeWithName:@"world"] addChild:treetop];
            
            return;
            
        }
       

        
    }

    
    NSLog(@"node.name: %@", node.name);
    if([node.name isEqualToString:@"planet"]){
        planetTouched++;
        NSLog(@"Touched planet");
    }
    
    if (planetTouched == 10) {
        [queuePlayer advanceToNextItem];
        NSLog(@"Planet touched: %d", planetTouched);
    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)createAmountOfLemmings:(int)count withWorld:(SKNode *)myWorld {
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
        lemming.physicsBody.collisionBitMask = sceneryCategory | objectCategory | lemmingCategory | caveCategory;
        lemming.physicsBody.velocity = self.physicsBody.velocity;
        lemming.physicsBody.linearDamping = 0;
        lemming.physicsBody.friction = .5;
        
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
        SKPhysicsBody *triangle = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"triangle.png"] size:[SKTexture textureWithImageNamed:@"triangle.png"].size];
        SKSpriteNode* treetop = (SKSpriteNode *)[[self childNodeWithName:@"world"] childNodeWithName:@"treetop"];
        SKSpriteNode* stump = (SKSpriteNode *)[[self childNodeWithName:@"world"] childNodeWithName:@"stump"];
        stump.physicsBody = triangle;
        stump.physicsBody.dynamic = NO;
        stump.physicsBody.mass = 99999;
        stump.physicsBody.affectedByGravity = NO;
        stump.physicsBody = triangle;
        stump.physicsBody.categoryBitMask = triangleCategory;
        stump.physicsBody.collisionBitMask = 0;
        stump.physicsBody.contactTestBitMask = 0;
        stump.physicsBody.allowsRotation = 0;
        
        CGSize rectSize = CGSizeMake(treetop.texture.size.width-270, treetop.texture.size.height+100);
        
        treetop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rectSize];
        treetop.physicsBody.affectedByGravity = NO;
        treetop.physicsBody.dynamic = NO;
       // [SKPhysicsBody body];
        for(SKSpriteNode* lemming in lemmingArray){
            [lemming.physicsBody applyImpulse:CGVectorMake(0,1)];
            //lemming.physicsBody.affectedByGravity = NO;
        }
    }
    if ((firstBody.categoryBitMask == lemmingCategory && secondBody.categoryBitMask == caveCategory)){
        [firstBody.node removeFromParent];
        
    }
    if((firstBody.categoryBitMask == caveCategory && secondBody.categoryBitMask == lemmingCategory)) {
        [secondBody.node removeFromParent];

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
    
    SKSpriteNode* cave = (SKSpriteNode*)[camera childNodeWithName:@"cave"];
    CGPoint cavePos = CGPointMake(cave.position.x - 980, cave.position.y);
    NSLog(@"CAVEPOS: %f, %f", cavePos.x, cavePos.y);
    
    if(newPos.x < floorPos.x && newPos.x > -cavePos.x)
        camera.position = newPos;
    else if (newPos.x < -cavePos.x){
        NSLog(@"IT'S GREATER!!!");
        camera.position = CGPointMake(-cavePos.x, newPos.y);
    }
    else
        camera.position = CGPointMake(floorPos.x, newPos.y);
    
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    
    for (SKSpriteNode *lemming in lemmingArray) {
        CMAccelerometerData* data = _myMotionManager.accelerometerData;
        if (fabs(data.acceleration.y) > 0.1) {
            float yAcceleration = 30.0 * data.acceleration.y;
            float randomAccel = [self getRandomNumberBetween:1 to:100]/100.0;
            [lemming.physicsBody applyForce:CGVectorMake(yAcceleration += randomAccel, 0.0)];
        } else {
            //[lemming.physicsBody applyImpulse:CGVectorMake(lemming.physicsBody.velocity.dx/2, 0.0)];
        }
    }
    
    for (SKSpriteNode *star in starArray) {
        float starOpacity = [self getRandomNumberBetween:10 to:100]/100.0f;
        star.alpha = starOpacity;
    }
}

-(void)createStarsWithCount:(int)count {
    for (int i = 0; i < count; i++) {
        SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star.png"];
        int starX = [self getRandomNumberBetween:5 to:1000];
        int starY = [self getRandomNumberBetween:300 to:650];
        star.position = CGPointMake(starX, starY);
        star.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"star.png"]];
        [self addChild:star];
        [starArray addObject:star];
    }
}

-(int)getRandomNumberBetween:(int)from to:(int)to{
    return (float)from + arc4random() % (to-from+1);
}

- (void)initializeAVAudioPlayer:(NSString*) name fileExtension:(NSString*)fileExtension Volume:(float) volume Rate:(float) rate {
    NSString *stringPath = [[NSBundle mainBundle]pathForResource:name ofType:fileExtension];
    NSURL *url = [NSURL fileURLWithPath:stringPath];
    
    NSError *error;
    
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    [player setDelegate:(id)self];
    player.delegate = self;
    
    [player setVolume:volume];
    if(rate != 1.0f){
        player.enableRate = YES;
        player.rate = rate;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)data successfully:(BOOL)flag{
    NSLog(@"It finished playing!");
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Do stuff here
    [self playAtIndex:0];
}

- (void)playAtIndex:(int)index
{
    [queuePlayer removeAllItems];
    for (int i = index; i <musicArray.count; i ++) {
        AVPlayerItem* obj = [musicArray objectAtIndex:i];
        if ([queuePlayer canInsertItem:obj afterItem:nil]) {
            [obj seekToTime:kCMTimeZero];
            [queuePlayer insertItem:obj afterItem:nil];
        }
    }
}

@end