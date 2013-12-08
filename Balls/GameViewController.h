//
//  JGViewController.h
//  Balls
//
//  Created by Jacek Grygiel on 6/12/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProposalBall.h"
#import "BallButton.h"
#import "TileButton.h"

#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define SQUARE (iPad?11:9)
#define SQUARESIZE (iPad?60:30)
#define PADDINGX (iPad?20:5)
#define PADDINGY (iPad?20:5)

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )

#define IS_IPHONE_5 (( IS_IPHONE || IS_IPOD ) && IS_WIDESCREEN )


@interface GameViewController : UIViewController<BallButtonDelegate, TileButtonDelegate, UIAlertViewDelegate>

@property(nonatomic, weak) IBOutlet UIView  *mainView;
@property(nonatomic, weak) IBOutlet UILabel *scorePointLabel;
@property(nonatomic, weak) IBOutlet UILabel *topScoresOne;
@property(nonatomic, weak) IBOutlet UILabel *topScoresTwo;
@property(nonatomic, weak) IBOutlet UILabel *topScoresThree;
@property(nonatomic, weak) IBOutlet UILabel *topScoresFour;
@property(nonatomic, weak) IBOutlet UILabel *topScoresFive;

@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorOne;
@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorTwo;
@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorThree;
@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorFour;
@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorFive;
@property(nonatomic, weak) IBOutlet ProposalBall *proposalColorSix;


@property(nonatomic, weak) IBOutlet UIButton *easyGame;
@property(nonatomic, weak) IBOutlet UIButton *normalGame;
@property(nonatomic, weak) IBOutlet UIButton *hardGame;

@property(nonatomic, strong) BallButton *currentBallButton;


- (IBAction) startEasyGame:(id)sender;
- (IBAction) startNormalGame:(id)sender;
- (IBAction) startHardGame:(id)sender;


@end
