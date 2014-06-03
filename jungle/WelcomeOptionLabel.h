//
//  WelcomeOptionLabel.h
//  jungle
//
//  Created by Nate Armstrong on 1/12/14.
//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface WelcomeOptionLabel : SKLabelNode

- (id)initWithPosition:(CGPoint)position text:(NSString *)text;
@property(nonatomic)BOOL selected;

@end
