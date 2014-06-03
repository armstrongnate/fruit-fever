//
//  WelcomeOptionLabel.m
//  jungle
//
//  Created by Nate Armstrong on 1/12/14.
//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import "WelcomeOptionLabel.h"

@implementation WelcomeOptionLabel
{
    SKColor *_selectedColor;
    SKColor *_nonSelectedColor;
}

- (id)initWithPosition:(CGPoint)position text:(NSString *)text
{
    self = [super initWithFontNamed:@"Menlo Bold"];
    if (self)
    {
        _selectedColor = [SKColor colorWithRed:15.0/255 green:119.0/255 blue:22.0/255 alpha:1.0];
        _nonSelectedColor = [SKColor colorWithRed:15.0/255 green:119.0/255 blue:22.0/255 alpha:0.5];
        self.position = position;
        self.text = text;
        self.fontSize = 24;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    self.fontColor = selected ? _selectedColor : _nonSelectedColor;
}

@end
