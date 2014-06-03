//
//  GameOverScene.m
//  SpriteKitSimpleGame
//
//  Created by Nate Armstrong on 12/30/13.
//  Copyright (c) 2013 CustomBit. All rights reserved.
//

#import "GameOverScene.h"
#import "WelcomeScene.h"

@implementation GameOverScene
{
    kBasketControl _basketControlType;
}

-(id)initWithSize:(CGSize)size score:(NSNumber *)score basketControl:(kBasketControl)basketControlType
{
    if (self = [super initWithSize:size]) {
        _basketControlType = basketControlType;

#define kButtonMarginTop 60
#define kButtonMarginBottom 80

        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame),
                                  CGRectGetMidY(self.frame));
        [self addChild:bg];

        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
        label.text = [NSString stringWithFormat:@"Score: %@", score];
        label.fontSize = 32;
        label.fontColor = [SKColor colorWithRed:15.0/255 green:119.0/255 blue:22.0/255 alpha:1.0];
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + kButtonMarginTop);
        [self addChild:label];

        SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"again_button"];
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        playButton.name = @"playButtonNode";
        playButton.zPosition = 1.0;
        [self addChild:playButton];

        NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
        if (score.integerValue > highScore)
        {
            [[NSUserDefaults standardUserDefaults] setInteger: score.integerValue forKey: @"highScore"];
            highScore = score.integerValue;
        }
        if (highScore > 0)
        {
            SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
            highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld", (long)highScore];
            highScoreLabel.fontColor = [SKColor blackColor];
            highScoreLabel.fontSize = 20;
            highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - kButtonMarginBottom);
            [self addChild:highScoreLabel];
        }

        SKLabelNode *changeControl = [SKLabelNode labelNodeWithFontNamed:@"Menlo Bold"];
        changeControl.text = @"Change controls";
        changeControl.fontSize = 24;
        changeControl.fontColor = [SKColor colorWithRed:15.0/255 green:119.0/255 blue:22.0/255 alpha:1.0];
        changeControl.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - (kButtonMarginTop*2.25));
        changeControl.name = @"changeControls";
        [self addChild:changeControl];

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
    else if ([node.name isEqualToString:@"changeControls"])
    {
        [self runAction:[SKAction runBlock:^{
            SKTransition *reveal = [SKTransition flipVerticalWithDuration:1];
            WelcomeScene *welcomeScene = [WelcomeScene sceneWithSize:self.view.bounds.size];;
            [self.view presentScene:welcomeScene transition: reveal];
        }]];
    }
}

@end
