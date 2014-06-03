//
//  GameOverScene.h
//  SpriteKitSimpleGame
//
//  Created by Nate Armstrong on 12/30/13.
//  Copyright (c) 2013 CustomBit. All rights reserved.
//

#import "MyScene.h"
#import <SpriteKit/SpriteKit.h>

@interface GameOverScene : SKScene

-(id)initWithSize:(CGSize)size score:(NSNumber *)score basketControl:(kBasketControl)basketControlType;

@end
