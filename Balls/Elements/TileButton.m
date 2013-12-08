//
//  TileButton.m
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import "TileButton.h"
#import "BallButton.h"
#import "GameViewController.h"


@implementation TileButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"tile"] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(actionOnTap:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}



- (void) actionOnTap:(id) sender{
    if([self.delegate respondsToSelector:@selector(didPressedTileButton:)]){
        [self.delegate didPressedTileButton:self];
    }
}

- (NSString *)description{
    return [NSString stringWithFormat:@"Tile = %d,%d", self.x, self.y];
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
