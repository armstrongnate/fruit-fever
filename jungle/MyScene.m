//
//  MyScene.m
//  jungle
//
//  Created by Nate Armstrong on 1/3/14.
//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import "MyScene.h"
#import "WelcomeScene.h"
#import "GameOverScene.h"
@import CoreMotion;
@import AudioToolbox;

#define kNumFruit 30
#define kNumLives 5
#define kPaddingTop 30
#define kPaddingLeftAndRight 50
#define kBasketOffsetY 10

static BOOL AccelerationIsShaking(CMAcceleration last, CMAcceleration current, double threshold) {
	double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);

	return (deltaZ > threshold) ||
        (deltaX > threshold) ||
        (deltaY > threshold);
}

@interface MyScene()

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) SKLabelNode *gameTypeLabel;
@property (nonatomic, strong) NSNumber *lives;
@property (nonatomic, strong) NSNumber *score;

@end

int secondsLeft;
int seconds;

@implementation MyScene
{
    SKSpriteNode *_treeBack;
    SKSpriteNode *_treeFront;
    SKSpriteNode *_basket;
    CMMotionManager *_motionManager;
    CGFloat _shuffleDuration;
    CGFloat _shuffleDistance;
    NSMutableArray *_fruit;
    int _nextFruit;
    CMAcceleration _lastAcceleration;
    SKLabelNode *_livesLabel;
    SKLabelNode *_scoreLabel;
    SKEmitterNode *_leavesEmitterNode;
    NSTimer *_timer;
    SKLabelNode *_counterLabel;
    kBasketControl _control;
    BOOL basketTouched;
}

-(id)initWithSize:(CGSize)size gameType:(gameType)gameType basketControl:(kBasketControl)control
{
    if (self = [super initWithSize:size])
    {
        _control = control;
        basketTouched = NO;
        /* Setup your scene here */
        self.backgroundColor = [SKColor whiteColor];

        CGRect physicsBody = CGRectMake(0.0, kBasketOffsetY, self.frame.size.width, self.frame.size.height - kBasketOffsetY);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:physicsBody];

        _shuffleDuration = 0.5;
        _shuffleDistance = 10.0;

        // background
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame));
        [self addChild:bg];

        // tree back
        _treeBack = [SKSpriteNode spriteNodeWithImageNamed:@"tree_back"];
        _treeBack.position = CGPointMake(CGRectGetMidX(self.frame), 400.0);
        [_treeBack runAction:[self moveNodeLeftAndRightForever:_treeBack reversed:NO] withKey:@"shuffleTreeBack"];
        [self addChild:_treeBack];

        // leaves
        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"leaves" ofType:@"sks"];
        SKEmitterNode *emitterNode1 = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        emitterNode1.particlePosition = CGPointMake(self.size.width/2.0, self.size.height);
        [self addChild:emitterNode1];

        // tree trunk
        SKSpriteNode *tree = [SKSpriteNode spriteNodeWithImageNamed:@"tree"];
        tree.position = CGPointMake(CGRectGetMidX(self.frame), tree.size.height / 2);
        [self addChild:tree];

        // leaves
//        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"leaves" ofType:@"sks"];
        SKEmitterNode *emitterNode2 = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        emitterNode2.particlePosition = CGPointMake(self.size.width/2.0, self.size.height);
        [self addChild:emitterNode2];

        // tree front
        _treeFront = [SKSpriteNode spriteNodeWithImageNamed:@"tree_front"];
        _treeFront.position = CGPointMake(CGRectGetMidX(self.frame), 425.0);
        _treeFront.zPosition = 10.0;
        [_treeFront runAction:[self moveNodeLeftAndRightForever:_treeFront reversed:YES] withKey:@"shuffleTreeFront"];
        [self addChild:_treeFront];

        // grass
        SKSpriteNode *grass = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
        grass.position = CGPointMake(CGRectGetMidX(self.frame), grass.size.height / 2);
        [self addChild:grass];

        // basket
        _basket = [SKSpriteNode spriteNodeWithImageNamed:@"basket"];
        _basket.position = CGPointMake(self.frame.size.width/2, (_basket.frame.size.height/2) + kBasketOffsetY);
        _basket.name = @"basket";
        _basket.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_basket.frame.size];
        _basket.physicsBody.dynamic = YES;
        _basket.physicsBody.mass = 0.02;
        _basket.physicsBody.friction = 0.5;
        [self addChild:_basket];

        // fruit
        _fruit = [[NSMutableArray alloc] initWithCapacity:kNumFruit];
        NSArray *fruit_names = @[@"banana", @"apple", @"orange", @"pear"];
        for (int i=0; i<kNumFruit; ++i) {
            SKSpriteNode *fruit = [SKSpriteNode spriteNodeWithImageNamed:[fruit_names objectAtIndex: arc4random() % fruit_names.count]];
            fruit.hidden = YES;
            [_fruit addObject:fruit];
            [self addChild:fruit];
        }

        // game type
        _gameTypeLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _gameTypeLabel.text = gameType == kgameTypeLives ? @"Lives:" : @"Time:";
        _gameTypeLabel.fontSize = 14;
        _gameTypeLabel.fontColor = [SKColor blackColor];
        _gameTypeLabel.position = CGPointMake(self.size.width - kPaddingLeftAndRight, self.size.height - kPaddingTop);
        _gameTypeLabel.zPosition = 11.0;
        [self addChild:_gameTypeLabel];

        // timer
        secondsLeft = 30;
        _counterLabel = [self gameLabelNode];
        _counterLabel.hidden = gameType == kgameTypeLives;
        [self addChild:_counterLabel];
        [self countdownTimer];

        // score
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = @"Points:";
        label.fontSize = 14;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(kPaddingLeftAndRight, self.size.height - kPaddingTop);
        label.zPosition = 11.0;
        [self addChild:label];

        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _scoreLabel.fontSize = 30;
        _scoreLabel.fontColor = [SKColor blackColor];
        _scoreLabel.position = CGPointMake(kPaddingLeftAndRight, (self.size.height - kPaddingTop) - label.frame.size.height - 15);
        _scoreLabel.zPosition = 11.0;
        self.score = [NSNumber numberWithInt:0];
        [self addChild:_scoreLabel];

        // lives
        _livesLabel = [self gameLabelNode];
        _livesLabel.hidden = gameType == kgameTypeTimer;
        self.lives = [NSNumber numberWithInt:kNumLives];
        [self addChild:_livesLabel];

        // motion manager
        _motionManager = [[CMMotionManager alloc] init];

        [self startTheGame];

    }
    return self;
}

- (SKLabelNode *)gameLabelNode
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 30;
    label.fontColor = [SKColor blackColor];
    label.position = CGPointMake((self.size.width - kPaddingLeftAndRight), (self.size.height - kPaddingTop) - _gameTypeLabel.frame.size.height - 15);
    label.zPosition = 11.0;

    return label;
}

- (void)setLives:(NSNumber *)lives
{
    _lives = lives;
    _livesLabel.text = [NSString stringWithFormat:@"%@", _lives];
}

- (void)setScore:(NSNumber *)score
{
    _score = score;
    _scoreLabel.text = [NSString stringWithFormat:@"%@", _score];
}

- (void)startTheGame
{
    [self startMonitoringAcceleration];
}

-(SKAction *)moveNodeLeftAndRightForever:(SKSpriteNode *)node reversed:(BOOL)reversed
{
    CGPoint right = CGPointMake(CGRectGetMidX(self.frame) + _shuffleDistance, node.position.y);
    SKAction *moveRight = [SKAction moveTo:right duration:_shuffleDuration];

    CGPoint left = CGPointMake(CGRectGetMidX(self.frame) - _shuffleDistance, node.position.y);
    SKAction *moveLeft = [SKAction moveTo:left duration:_shuffleDuration];

    NSArray *sequence = reversed ? @[moveLeft, moveRight] : @[moveRight, moveLeft];
    SKAction *moveRightAndLeft = [SKAction sequence:sequence];
    return [SKAction repeatActionForever:moveRightAndLeft];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (_control == kBasketControlSwipe)
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        basketTouched = [node.name isEqualToString:@"basket"];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_control == kBasketControlSwipe && basketTouched)
    {
        UITouch *touch = [touches anyObject];
        CGPoint position = [touch locationInNode:self];
        _basket.position = CGPointMake(position.x, _basket.position.y);
    }
}

- (void)updateTreeFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (AccelerationIsShaking(_lastAcceleration, data.acceleration, .5))
    {
        self.lastSpawnTimeInterval += .25;
        _leavesEmitterNode.particleBirthRate *= 10;
    }
    else
    {
        _leavesEmitterNode.particleBirthRate = 1.785;
    }
    _lastAcceleration = data.acceleration;
}

- (void)updateBasketFromMotionManager
{
    NSLog(@"in update basket");
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.15)
    {
        [_basket.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.x, 0.0)];
    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {

    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 2 && !self.paused)
    {
        self.lastSpawnTimeInterval = 0;
        [self addFruit];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self updateTreeFromMotionManager];
    if (_control == kBasketControlTilt)
    {
        [self updateBasketFromMotionManager];
    }
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1)
    { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }

    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    [self checkForCollision];
}

#pragma mark - Core Motion

- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable)
    {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive)
    {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

#pragma mark - Fruit

- (void)addFruit
{
    // Create sprite
    SKSpriteNode *fruit = [_fruit objectAtIndex:_nextFruit];
    [fruit removeAllActions];
    _nextFruit++;
    if (_nextFruit >= _fruit.count) _nextFruit = 0;

    // Determine where to spawn the fruit along the X axis
    int minX = fruit.size.width / 2;
    int maxX = self.frame.size.width - fruit.size.width / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;

    // Create the fruit slightly off-screen along the top edge,
    // and along a random position along the X axis as calculated above
    fruit.position = CGPointMake(actualX, self.frame.size.height + fruit.size.height/2);
    fruit.zPosition = 9.0;
    fruit.hidden = NO;

    // Determine speed of the fruit
    int minDuration = 4.0;
    int maxDuration = 5.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;

    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, -fruit.size.height/2) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction runBlock:(dispatch_block_t)^() {
        fruit.hidden = YES;
        if (!_livesLabel.hidden)
            self.lives = [NSNumber numberWithInt:_lives.intValue - 1];
    }];
    __weak typeof(self) weakSelf = self;
    SKAction * loseAction = [SKAction runBlock:^{
        if (_lives.intValue <= 0) {
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:weakSelf.size score:_score basketControl:_control];
            [weakSelf.view presentScene:gameOverScene transition: reveal];
        }
    }];
    [fruit runAction:[SKAction sequence:@[actionMove, actionMoveDone, loseAction]]];
}

- (void)checkForCollision
{
    for (SKSpriteNode *fruit in _fruit) {
        if (fruit.hidden) {
            continue;
        }
        if ([_basket intersectsNode:fruit] && fruit.position.y - (fruit.size.height / 2) >= _basket.position.y - (_basket.size.height / 2)) {
            self.score = [NSNumber numberWithInt:_score.intValue + 5];
            fruit.hidden = YES;
            [fruit removeAllActions];
        }
    }
}

- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height);

    return emitterNode;
}

- (void)countdownTimer
{

//    secondsLeft = hours = minutes = seconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(secondsLeft > 0 )
    {
        secondsLeft-- ;
        seconds = (secondsLeft %3600) % 60;
        _counterLabel.text = [NSString stringWithFormat:@"%02d", seconds];
    }
    else
    {
        [_timer invalidate];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size score:_score basketControl:_control];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

@end
