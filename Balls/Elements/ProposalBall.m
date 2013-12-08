//
//  ProposalBall.m
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import "ProposalBall.h"

@implementation ProposalBall

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0;
    }
    return self;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.alpha = 0.0;
    }
    return self;
}

- (id) initWithBallType:(BallType) ballType{
    self = [super init];
    if (self) {
        [self setBallType:ballType];
    }
    return self;
}

- (void)show{
    
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)hide{
    
    self.alpha = 1.0;
    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.1, 0.1);
    }];
}

- (void) setBallType:(BallType) ballType{
    switch (ballType) {
        case BallTypeGreen:
            self.image = [UIImage imageNamed:@"green_on_tile"];
            break;
        case BallTypeBlue:
            self.image = [UIImage imageNamed:@"blue_on_tile"];
            break;
        case BallTypeOrange:
            self.image = [UIImage imageNamed:@"orange_on_tile"];
            break;
        case BallTypePurple:
            self.image = [UIImage imageNamed:@"purple_on_tile"];
            break;
        case BallTypeRed:
            self.image = [UIImage imageNamed:@"red_on_tile"];
            break;
        case BallTypeYellow:
            self.image = [UIImage imageNamed:@"yellow_on_tile"];
            break;
        default:
            break;
    }
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
