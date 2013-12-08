//
//  BallButton.m
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import "BallButton.h"
#import "GameViewController.h"

@interface BallButton ()
@end

@implementation BallButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    
    }
    return self;
}

- (id) initWithBallType:(BallType) ballType{
    self = [super initWithFrame:CGRectMake(0, 0, SQUARESIZE, SQUARESIZE)];
    self.ballType = ballType;
    self.isActive = NO;
    [self setMultipleTouchEnabled:YES];
    [self setExclusiveTouch:YES];
    [self addTarget:self action:@selector(activateAndDeactivate:) forControlEvents:UIControlEventTouchDown];
    
    if (self) {
        switch (ballType) {
            case BallTypeYellow:
            {
                [self setImage:[UIImage imageNamed:@"yellow_ball"] forState:UIControlStateNormal];
                break;
            }
            case BallTypeOrange:
            {
                [self setImage:[UIImage imageNamed:@"orange_ball"] forState:UIControlStateNormal];
                break;
            }
            case BallTypeGreen:
            {
                [self setImage:[UIImage imageNamed:@"green_ball"] forState:UIControlStateNormal];

                break;
            }
            case BallTypeBlue:
            {
                [self setImage:[UIImage imageNamed:@"blue_ball"] forState:UIControlStateNormal];

                break;
            }
            case BallTypeRed:
            {
                [self setImage:[UIImage imageNamed:@"red_ball"] forState:UIControlStateNormal];

                break;
            }
            case BallTypePurple:
            {
                [self setImage:[UIImage imageNamed:@"purple_ball"] forState:UIControlStateNormal];
                break;
            }
            default:
                break;
        }

    }
    return self;
   }


- (void) activateAndDeactivate:(id) sender{

    if (self.delegate) {
        GameViewController *gameViewController = (GameViewController*) self.delegate;
        if (gameViewController.currentBallButton != self) {
            gameViewController.currentBallButton.isActive = NO;
            gameViewController.currentBallButton = nil;
        }
    }
    
    if (self.isActive) {
        self.isActive = NO;
        
    }else{
        self.isActive = YES;
        [self animate];
    }
    
    if([self.delegate respondsToSelector:@selector(ballButton:isActive:)]){
        [self.delegate ballButton:self isActive:self.isActive];
    }
    
}

- (void) animate{
    [UIView animateWithDuration:0.2 animations:^{
        if (self.isActive)
        self.transform = CGAffineTransformMakeScale(0.7, 0.7);

    } completion:^(BOOL finished) {
        if (self.isActive) {
            [UIView animateWithDuration:0.2 animations:^{
                if (self.isActive)
                    self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
            } completion:^(BOOL finished) {
                if (self.isActive)
                    [self performSelector:@selector(animate) withObject:nil afterDelay:1.0];
            }] ;
        }else{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }

    }];
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
