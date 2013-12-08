//
//  BallButton.h
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BallButton;

@protocol BallButtonDelegate <NSObject>

- (void) ballButton:(BallButton*) ballButton isActive:(BOOL) active;

@end

@interface BallButton : UIButton
@property(nonatomic, weak) id<BallButtonDelegate> delegate;
@property(nonatomic, unsafe_unretained) int x;
@property(nonatomic, unsafe_unretained) int y;
@property(nonatomic, unsafe_unretained) BOOL isActive;
@property(nonatomic, unsafe_unretained) BallType ballType;

- (id) initWithBallType:(BallType) ballType;
@end
