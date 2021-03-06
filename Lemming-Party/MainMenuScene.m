//
//  MainMenuScene.m
//  Lemming-Party
//
//  Created by Andrew Morgan on 11/9/14.
//  Copyright (c) 2014 Andrew Morgan. All rights reserved.
//

#import "MainMenuScene.h"
#import "GameScene.h"

@implementation MainMenuScene

-(void)didMoveToView:(SKView *)view {
    [self initializeAVAudioPlayer:@"menu-theme" fileExtension:@".mp3" Volume:1.0 Rate:1.0];
    [player play];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"menu-image.png"];
    background.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"menu-image.png"]];
    
    background.position = CGPointMake(screenRect.size.width/2 - 370, screenRect.size.height/2 - 112);
    background.anchorPoint = CGPointMake(0, 0);
    background.size = CGSizeMake(screenRect.size.width * 1.4, screenRect.size.height * 1.4);
    [self addChild:background];
    
    [self showPlayButton];
}


- (void)initializeAVAudioPlayer:(NSString*) name fileExtension:(NSString*)fileExtension Volume:(float) volume Rate:(float) rate {
    NSString *stringPath = [[NSBundle mainBundle]pathForResource:name ofType:fileExtension];
    NSURL *url = [NSURL fileURLWithPath:stringPath];
    
    NSError *error;
    
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    [player setDelegate:(id)self];
    player.delegate = self;
    player.numberOfLoops = -1;
    
    [player setVolume:volume];
    if(rate != 1.0f){
        player.enableRate = YES;
        player.rate = rate;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)data successfully:(BOOL)flag{
    NSLog(@"It finished playing!");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"fireButtonNode"]) {
        //do whatever...
        NSLog(@"Button Pushed");
        GameScene *scene = [[GameScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition flipVerticalWithDuration:1.5];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:transition];
    }
}

-(void)showPlayButton {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"play-button.png"];
    fireNode.position = CGPointMake(screenRect.size.width/2 + 150,300);
    fireNode.alpha = 0;
    [self addChild:fireNode];
    
    SKAction *wait = [SKAction waitForDuration:1.75];
    SKAction *fadeIn = [SKAction fadeInWithDuration:1.0];
    
    SKAction *sequence = [SKAction sequence:@[wait, fadeIn]];
    
    [fireNode runAction: sequence];
    
    //[fireNode.physicsBody applyImpulse:CGVectorMake(10, 10)];
    fireNode.name = @"fireButtonNode";//how the node is identified later
    fireNode.zPosition = 1.0;
    
}

@end
