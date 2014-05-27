//
//  MyScene.m
//  KeepUp
//
//  Created by James Corwin on 5/17/14.
//  Copyright (c) 2014 James Is a Baller. All rights reserved.
//

#import "MyScene.h"
#import "GameLogic.h"

@interface MyScene()
@property (nonatomic,strong) SKSpriteNode *player;

@end

static int32_t barCategory = 0x1;
static int32_t playerCategory = 0x1 << 1;

NSTimer *horizontalBarCreateTimer;
NSTimer *verticalBarCreateTimer;


SKAction *scrollDownThenRemove;
SKAction *scrollRightThenRemove;
SKAction *scrollDown;
SKAction *scrollUpTopBar;
SKAction *scrollDownTopBar;
SKAction *scrollUpBottomBar;
SKAction *scrollDownBottomBar;
SKAction *scrollRight;

SKAction *scrollTopToRandom;
SKAction *scrollBottomToRandom;

SKAction *removeFromScene;

SKAction *moveBackground;

SKLabelNode *highScoreLabel;

SKEmitterNode *backgroundParticles;

SKSpriteNode *background;
SKSpriteNode *background2;

int distanceBarsApart;
int distanceVerticalBarsApart;
int scoreValue;
int highScoreValue;

float scrollTime;
float scrollRightTime;
float verticalGapScrollTime;

float topBarRandom;
float bottomBarRandom;

BOOL gameIsRunning;
BOOL topBarUp;

@implementation MyScene



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.backgroundColor = [SKColor blueColor];
        background = [SKSpriteNode spriteNodeWithImageNamed:@"background2"];
        background2 = [SKSpriteNode spriteNodeWithImageNamed:@"background2"];
        background.position = CGPointMake(self.size.width/2, self.size.height/2);
        background2.position = CGPointMake(self.size.width/2, self.size.height+background2.frame.size.height/2 - 2);
        [self addChild:background];
        [self addChild:background2];
        
        backgroundParticles = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"clouds" ofType:@"sks"]];
        backgroundParticles.position = CGPointMake(self.size.width-30, 110);
        backgroundParticles.scale = 3;
        backgroundParticles.zPosition = -1;
        [self addChild:backgroundParticles];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        [self initializeVariables];
    }
    return self;
}
-(void)initializeVariables {
    scrollTime = 6;
    scrollRightTime = 7;
    verticalGapScrollTime = 5;
    scoreValue = 0;
    distanceBarsApart = 100;
    distanceVerticalBarsApart = 130;
    gameIsRunning = NO;
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"blueBall"];
    self.player.scale = .04;
    self.player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.player.frame.size.width/2];
    self.player.physicsBody.categoryBitMask = playerCategory;
    self.player.physicsBody.contactTestBitMask = barCategory;
    
    score = [SKLabelNode labelNodeWithFontNamed:@"Gillsans"];
    score.position = CGPointMake(self.size.width/2, self.size.height/2 + 150);
    score.fontColor = [SKColor whiteColor];
    score.fontSize = 30;
    score.zPosition = 1;
    [self addChild:score];
    
    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Gillsans"];
    highScoreLabel.position = CGPointMake(self.size.width - highScoreLabel.frame.size.width/2 - 20, 50);
    highScoreLabel.fontColor = [SKColor whiteColor];
    highScoreLabel.fontSize = 26;
    highScoreLabel.zPosition = 1;
    highScoreValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    [highScoreLabel setText:[NSString stringWithFormat:@"%d",highScoreValue]];
    [self addChild:highScoreLabel];
    
    removeFromScene = [SKAction removeFromParent];

}
-(void)playMusic{
    [[SoundManager sharedManager] playMusic:@"Caves" looping:YES fadeIn:NO];

}
-(void)stopMusic{
    [[SoundManager sharedManager] stopMusic];
    [SoundManager sharedManager].musicFadeDuration = 0;
}
-(void)createHorizontalBars:(CGSize)size {
    scoreValue++;

    leftBar = [SKSpriteNode spriteNodeWithImageNamed:@"HorizontalBlackBarStone"];
    rightBar = [SKSpriteNode spriteNodeWithImageNamed:@"HorizontalBlackBarStone"];
    
    leftBar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftBar.frame.size];
    rightBar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightBar.frame.size];
    
    leftBar.physicsBody.dynamic = NO;
    rightBar.physicsBody.dynamic = NO;
    
    leftBar.physicsBody.categoryBitMask = barCategory;
    rightBar.physicsBody.categoryBitMask = barCategory;
    
    
    leftBar.physicsBody.collisionBitMask = playerCategory;
    rightBar.physicsBody.collisionBitMask = playerCategory;
    
    
    float leftBarRandom = arc4random_uniform(self.size.width - distanceBarsApart) - leftBar.frame.size.width/2;
    float rightBarRandom = leftBarRandom + distanceBarsApart + leftBar.frame.size.width/2 + rightBar.frame.size.width/2;
    
    NSLog(@"Left bar X: %f",leftBarRandom);
    NSLog(@"Right bar X: %f",rightBarRandom);

    
    leftBar.position = CGPointMake(leftBarRandom, self.size.height+leftBar.frame.size.height/2);
    rightBar.position = CGPointMake(rightBarRandom, self.size.height+rightBar.frame.size.height/2);
    
    [self addChild:leftBar];
    [self addChild:rightBar];
    
    [self moveHorizontalBars:size];
    
    if (gameIsRunning) {
        if (scoreValue > 135) {
            [self performSelector:@selector(createHorizontalBars:) withObject:nil afterDelay:2-135*.005];
        } else {
            [self performSelector:@selector(createHorizontalBars:) withObject:nil afterDelay:2-scoreValue*.005];

        }

    }
}
-(void)createVerticalBars:(CGSize)size {
    if (scoreValue > 135) {
        distanceVerticalBarsApart = 110;
    }
    topBar = [SKSpriteNode spriteNodeWithImageNamed:@"VerticalBlackBarStone"];
    bottomBar = [SKSpriteNode spriteNodeWithImageNamed:@"VerticalBlackBarStone"];
    
    topBar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topBar.frame.size];
    bottomBar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomBar.frame.size];
    
    bottomBar.physicsBody.dynamic = NO;
    topBar.physicsBody.dynamic = NO;
    
    topBar.physicsBody.categoryBitMask = barCategory;
    bottomBar.physicsBody.categoryBitMask = barCategory;
    
    topBar.physicsBody.collisionBitMask = playerCategory;
    bottomBar.physicsBody.collisionBitMask = playerCategory;
    
    topBarRandom = (topBar.frame.size.height/2+distanceVerticalBarsApart) + arc4random() % (int)((self.size.height+topBar.frame.size.height/2) - (topBar.frame.size.height/2+distanceVerticalBarsApart) + 1);
    bottomBarRandom = topBarRandom - bottomBar.frame.size.height - distanceVerticalBarsApart;
    
    topBar.position = CGPointMake(-topBar.frame.size.width/2, topBarRandom);
    bottomBar.position = CGPointMake(-bottomBar.frame.size.width/2, bottomBarRandom);

    [self addChild:topBar];
    [self addChild:bottomBar];
    
    [self moveVerticalBars:size];
    
    if (gameIsRunning) {
        if (scoreValue > 215) {
            [self performSelector:@selector(createVerticalBars:) withObject:nil afterDelay:5-215*.0138];
        } else {
            [self performSelector:@selector(createVerticalBars:) withObject:nil afterDelay:5-scoreValue*.0138];
        }
    }
    
    
}
-(void)runCreateBars {
    if (gameIsRunning == NO) {
        gameIsRunning = YES;
        horizontalBarCreateTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:self selector:@selector(createHorizontalBars:) userInfo:nil repeats:NO];
        verticalBarCreateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(createVerticalBars:) userInfo:nil repeats:NO];
    }
}
-(void)moveHorizontalBars:(CGSize)size{
    scrollDown = [SKAction moveToY:-leftBar.frame.size.height/2 duration:scrollTime-scoreValue*.002];
    scrollDownThenRemove = [SKAction sequence:@[scrollDown, removeFromScene]];
    
    [leftBar runAction:scrollDownThenRemove];
    [rightBar runAction:scrollDownThenRemove];
   
}
-(void)moveVerticalBars:(CGSize)size{
    if (scoreValue > 205) {
        scrollRight = [SKAction moveToX:self.size.width+topBar.frame.size.width/2 duration:scrollRightTime-215*.019333];
    } else {
        scrollRight = [SKAction moveToX:self.size.width+topBar.frame.size.width/2 duration:scrollRightTime-scoreValue*.019333];
    }
    
    float randomPointY = (distanceVerticalBarsApart+topBar.frame.size.height/2) + arc4random() % (int)((self.size.height+topBar.frame.size.height/2) - (distanceVerticalBarsApart + topBar.frame.size.height/2) + 1);

    
    
    scrollTopToRandom = [SKAction moveToY:randomPointY duration:verticalGapScrollTime];
    scrollBottomToRandom = [SKAction moveToY:randomPointY - distanceVerticalBarsApart - bottomBar.frame.size.height duration:verticalGapScrollTime];
    
    /*
    scrollUpTopBar = [SKAction moveToY:self.size.height+topBar.frame.size.height/2 duration:verticalGapScrollTime];
    scrollDownTopBar = [SKAction moveToY:topBar.frame.size.height/2+distanceBarsApart duration:verticalGapScrollTime];
    scrollUpBottomBar = [SKAction moveToY:self.size.height-bottomBar.frame.size.height/2-distanceBarsApart duration:verticalGapScrollTime];
    scrollDownBottomBar = [SKAction moveToY:-bottomBar.frame.size.height/2 duration:verticalGapScrollTime];
     */
    
    scrollRightThenRemove = [SKAction sequence:@[scrollRight, removeFromScene]];

    [topBar runAction:scrollRightThenRemove];
    [bottomBar runAction:scrollRightThenRemove];
    [topBar runAction:scrollTopToRandom];
    [bottomBar runAction:scrollBottomToRandom];

    /*
    if (topBar.position.y > self.size.height/2+topBar.frame.size.height/2) {
        [topBar runAction:scrollUpTopBar];
        topBarUp = YES;
    } else {
        [topBar runAction:scrollDownTopBar];
        topBarUp = NO;
    }
    
    if (topBarUp == YES) {
        [bottomBar runAction:scrollUpBottomBar];
    } else {
        [bottomBar runAction:scrollDownBottomBar];
    }
     */
}
-(void)moveBackground:(CGSize)size {
    if (background.position.y == self.size.height/2 ) {
        [self addChild:background2];
        [background2 runAction:moveBackground];
    }
    moveBackground = [SKAction moveToY:-background.frame.size.height duration:100];
    [background runAction:moveBackground];

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [self resetVariables];
    
    //[self moveBackground:self.size];
    highScoreValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];

    [highScoreLabel setText:[NSString stringWithFormat:@"%d",highScoreValue]];
    NSLog(@"%d",highScoreValue);


    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    
    [self createPlayer:self.size];
    self.player.position = location;
    
    [self playMusic];
    
    [self runCreateBars];
    

}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if (gameIsRunning == YES) {
        self.player.position = location;
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.player removeFromParent];
    [self gameOver:self.size];
    
}
-(void)createPlayer:(CGSize)size {
    NSLog(@"Player Created");
    [self addChild:self.player];

    
}
-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *theBar;
    SKPhysicsBody *notTheBar;

    if (contact.bodyA.categoryBitMask < playerCategory) {
        notTheBar = contact.bodyB;
        theBar = contact.bodyA;
    } else {
        notTheBar = contact.bodyA;
        theBar = contact.bodyB;
    }
    
    if (notTheBar.categoryBitMask == playerCategory) {
        [theBar.node removeAllActions];
        SKSpriteNode *contactedPointImage;
        contactedPointImage = [SKSpriteNode spriteNodeWithImageNamed:@"blueBall"];
        contactedPointImage.scale = .03;
        contactedPointImage.position = contact.contactPoint;
        [self addChild:contactedPointImage];
        [self.player removeFromParent];
        [self gameOver:self.size];
    }
}
-(void)gameOver:(CGSize)size {
    NSLog(@"Game Over");
    gameIsRunning = NO;
    [self stopMusic];
    highScoreValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (highScoreValue < scoreValue) {
        [[NSUserDefaults standardUserDefaults] setInteger:scoreValue forKey:@"HighScore"];
    }
    

}
-(void)resetVariables {
    [self removeAllChildren];
    
    distanceVerticalBarsApart = 130;
    scoreValue = 0;
    [self addChild:backgroundParticles];
    [self addChild:background];
    [self addChild:background2];
    [self addChild:score];
    [self addChild:highScoreLabel];

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [score setText:[NSString stringWithFormat:@"%d",scoreValue]];
    
    if (gameIsRunning) {
        background.position = CGPointMake(background.position.x, background.position.y-.5);
        background2.position = CGPointMake(background2.position.x, background2.position.y-.5);


        if (background.position.y < -background.frame.size.height/2) {
            background.position = CGPointMake(self.size.width/2, self.size.height+background.frame.size.height/2 - 4);
        }
        if (background2.position.y < -background2.frame.size.height/2) {
            background2.position = CGPointMake(self.size.width/2, self.size.height+background2.frame.size.height/2 - 2);
        }
    }
   
}

@end
