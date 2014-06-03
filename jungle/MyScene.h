//
//  MyScene.h
//  jungle
//

//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    kgameTypeTimer,
    kgameTypeLives
} gameType;

typedef enum {
    kBasketControlTilt,
    kBasketControlSwipe
} kBasketControl;

@interface MyScene : SKScene <SKPhysicsContactDelegate>

-(id)initWithSize:(CGSize)size gameType:(gameType)gameType basketControl:(kBasketControl)control;

@end
