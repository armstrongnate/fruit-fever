//
//  MenuView.m
//  jungle
//
//  Created by Nate Armstrong on 1/6/14.
//  Copyright (c) 2014 CustomBit. All rights reserved.
//

#import "MenuView.h"

@interface MenuView()
@property (strong, nonatomic) IBOutlet UIButton *goButton;

@end

@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:self options:nil] objectAtIndex:0];
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_bg"]];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
