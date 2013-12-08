//
//  ProposalBall.h
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallButton.h"
@interface ProposalBall : UIImageView
- (id) initWithBallType;
- (void) setBallType:(BallType) ballType;
- (void) show;
- (void) hide;
@end
