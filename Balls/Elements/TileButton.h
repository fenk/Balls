//
//  TileButton.h
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallButton.h"

@class TileButton;

@protocol TileButtonDelegate <NSObject>

- (void) didPressedTileButton:(TileButton*) tileButton;

@end

@interface TileButton : UIButton
@property(nonatomic, unsafe_unretained) int x;
@property(nonatomic, unsafe_unretained) int y;
@property(nonatomic, unsafe_unretained) BOOL includeBall;
@property(nonatomic, unsafe_unretained) BallType ballType;
@property(nonatomic, weak) id<TileButtonDelegate> delegate;
@end
