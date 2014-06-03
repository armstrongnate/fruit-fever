//
//  WelcomeScene.m
//  jungle
//
//  Created by Nate Armstrong on 1/8/14.
//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import "WelcomeScene.h"
#import "MyScene.h"
#import "WelcomeOptionLabel.h"

@implementation WelcomeScene
{
    WelcomeOptionLabel *_basketControlSwipeLabel;
    WelcomeOptionLabel *_basketControlTiltLabel;
    SKLabelNode *_gameTypeTimerLabel;
    SKLabelNode *_gameTypeLivesLabel;
    NSArray *_gameOptions;
    kBasketControl _basketControlType;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {

        #define kButtonMarginTop 60
        #define kButtonMarginBottom 80

        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame),
                                  CGRectGetMidY(self.frame));
        [self addChild:bg];

        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
        label.text = @"Jungle Fever";
        label.fontSize = 32;
        label.fontColor = [SKColor colorWithRed:15.0/255 green:119.0/255 blue:22.0/255 alpha:1.0];
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + kButtonMarginTop);
        [self addChild:label];

        SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"play_button"];
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        playButton.name = @"playButtonNode";
        playButton.zPosition = 1.0;
        [self addChild:playButton];


        CGFloat controlOptionsY = CGRectGetMidY(self.frame) - kButtonMarginBottom;
        CGPoint position = CGPointMake(CGRectGetMidX(self.frame), controlOptionsY);

        // control options
        SKLabelNode *controlOptionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
        controlOptionsLabel.text = @"Controls:";
        controlOptionsLabel.fontSize = 24;
        controlOptionsLabel.position = CGPointMake(position.x - 70, position.y);
        [self addChild:controlOptionsLabel];

        _basketControlSwipeLabel = [[WelcomeOptionLabel alloc] initWithPosition:CGPointMake(position.x + 35, position.y) text:@"Swipe"];
        _basketControlSwipeLabel.name = @"basketControlSwipeLabel";
        _basketControlSwipeLabel.selected = YES;
        _basketControlType = kBasketControlSwipe;
        [self addChild:_basketControlSwipeLabel];

        _basketControlTiltLabel = [[WelcomeOptionLabel alloc] initWithPosition:CGPointMake(position.x + 105, position.y) text:@"Tilt"];
        _basketControlTiltLabel.name = @"basketControlTiltLabel";
        _basketControlTiltLabel.selected = NO;
        [self addChild:_basketControlTiltLabel];

        NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        if (highScore > 0)
        {
            SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
            highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", (long)highScore];
            highScoreLabel.fontColor = [SKColor blackColor];
            highScoreLabel.fontSize = 20;
            highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - kButtonMarginBottom - _basketControlSwipeLabel.frame.size.height - 20);
            [self addChild:highScoreLabel];
        }
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];

    if ([node.name isEqualToString:@"playButtonNode"]) {
        [self runAction:[SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipVerticalWithDuration:1];
            SKScene * myScene = [[MyScene alloc] initWithSize:self.size gameType:kgameTypeTimer basketControl:_basketControlType];
            [self.view presentScene:myScene transition: reveal];
        }]];
    }
    else if ([node.name isEqualToString:@"basketControlSwipeLabel"])
    {
        _basketControlSwipeLabel.selected = YES;
        _basketControlTiltLabel.selected = NO;
        _basketControlType = kBasketControlSwipe;
    }
    else if ([node.name isEqualToString:@"basketControlTiltLabel"])
    {
        _basketControlSwipeLabel.selected = NO;
        _basketControlTiltLabel.selected = YES;
        _basketControlType = kBasketControlTilt;
    }
}

@end
