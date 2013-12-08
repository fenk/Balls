//
//  JGViewController.m
//  Balls
//
//  Created by Jacek Grygiel on 6/12/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import "GameViewController.h"
@class  Session;

@interface GameViewController ()
- (void) generateTitles;
- (void) hideAllProposalBalls;
@property(nonatomic, strong) NSMutableDictionary *tiles;
@property(nonatomic, strong) NSArray *predictTiles;
@property(nonatomic, strong) NSMutableArray *balls;
@property(nonatomic, unsafe_unretained) BOOL isAnimating;
@property(nonatomic, unsafe_unretained) DifficultType difficultType;
@property(nonatomic, strong) NSArray *nextBalls;
@property(nonatomic, unsafe_unretained) int points;
@end

@implementation GameViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateHistory];
    [self generateTitles];
    [self hideAllProposalBalls];
    
    self.predictTiles = @[self.proposalColorOne, self.proposalColorTwo, self.proposalColorThree, self.proposalColorFour, self.proposalColorFive, self.proposalColorSix];
    
    if (IS_WIDESCREEN && !iPad) {
        [self.mainView setCenter:CGPointMake(450, 155)];
    }else{
        [self.mainView setCenter:CGPointMake(400, 155)];
    }
	// Do any additional setup after loading the view, typically from a nib.
}
// Detect iPad
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)

// Set preferred orientation for initial display
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (IS_IPAD()){
        return UIInterfaceOrientationLandscapeRight;
    }
    else {
        return UIInterfaceOrientationPortrait;
    }
}
// Return list of supported orientations.
- (NSUInteger)supportedInterfaceOrientations{
    if (self.presentedViewController != nil){
        return [self.presentedViewController supportedInterfaceOrientations];
    }
    else {
        if (IS_IPAD()){
            return UIInterfaceOrientationMaskLandscapeRight;
        }
        else {
            return UIInterfaceOrientationMaskAll;
        }
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark START GAME SECTION

- (IBAction) startEasyGame:(id)sender{
    
    [self hideAllProposalBalls];
    
    [[LogicGame sharedInstance] clearMatrix];
    [self generateTitles];
    
    self.difficultType = DifficultTypeEasy;
    [self randomizeBalllForDifficult:DifficultTypeEasy];
    self.easyGame.selected = YES;
    self.normalGame.selected = NO;
    self.hardGame.selected = NO;
}
- (IBAction) startNormalGame:(id)sender{
    
    [self hideAllProposalBalls];

    [[LogicGame sharedInstance] clearMatrix];
    [self generateTitles];
    self.difficultType = DifficultTypeNormal;
    [self randomizeBalllForDifficult:DifficultTypeNormal];
    self.easyGame.selected = NO;
    self.normalGame.selected = YES;
    self.hardGame.selected = NO;
}
- (IBAction) startHardGame:(id)sender{
    
    [self hideAllProposalBalls];

    [[LogicGame sharedInstance] clearMatrix];
    [self generateTitles];
    self.difficultType = DifficultTypeHard;
    [self randomizeBalllForDifficult:DifficultTypeHard];
    self.easyGame.selected = NO;
    self.normalGame.selected = NO;
    self.hardGame.selected = YES;
}


- (void)generateTitles{
    self.tiles = nil;
    self.points = 0;
    [self addPoints:0];
    self.nextBalls = nil;
    self.tiles = [[NSMutableDictionary alloc] init];
    self.balls = [NSMutableArray array];
    self.isAnimating = NO;

    int x = PADDINGX;
    int y = PADDINGY;
    
    for(int i=0; i<SQUARE; i++)
    {
        for (int j=0; j<SQUARE; j++) {
            
            TileButton *tile = [[TileButton alloc] initWithFrame:CGRectMake(x, y, SQUARESIZE, SQUARESIZE)];
            tile.delegate = self;
            
            tile.x = j;
            tile.y = i;
            [self.view addSubview:tile];
            [self.tiles setObject:tile forKey:[NSString stringWithFormat:@"x:%d,y:%d",j,i]];
            //[tile setTitle:[NSString stringWithFormat:@"%d,%d",j,i] forState:UIControlStateNormal];
            x += SQUARESIZE+2;
            
        }
        y += SQUARESIZE+2;
        x = PADDINGX;
    }
    
}

- (void) updateTileForPositionX:(int) x andPositionY:(int) y andBallType:(BallType) ballType{

    if (ballType != BallTypeEmpty) {
        
        BallButton *ballButton = [[BallButton alloc] initWithBallType:ballType];
        ballButton.delegate = self;
        ballButton.x = x;
        ballButton.y = y;
        ballButton.alpha = 0.0;
        ballButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        ballButton.center = [(TileButton*)[self.tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",x,y]] center];
        TileButton *tile = (TileButton*)[self.tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",x,y]];
        tile.ballType = ballType;
        
        [[LogicGame sharedInstance] updateMatrix:self.tiles];
        
        [self.balls addObject:ballButton];
        [self.view addSubview:ballButton];
        
        [UIView animateWithDuration:0.5 animations:^{
            ballButton.alpha = 1.0;
            ballButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                ballButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
        
        
    }
}


- (void) randomizeBalllForDifficult:(DifficultType) difficultType{

    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        if (self.nextBalls == nil) {
            self.nextBalls=  [[LogicGame sharedInstance] randomizeBallsForDifficult:difficultType];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[LogicGame sharedInstance] updateMatrixWithRandomBalls:self.nextBalls];
            for (BallPrototype *ball in self.nextBalls) {
                [self updateTileForPositionX:ball.x andPositionY:ball.y andBallType:ball.ballType];
            }

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                NSArray *needRemove = [[LogicGame sharedInstance] sectionsNeedToBeRemovedAfterAction];
                

                self.nextBalls = [[LogicGame sharedInstance] randomizeBallsForDifficult:difficultType];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (needRemove.count) {
                        [self removeBallsWithAnimation:needRemove];
                    }
                    [self updateNextBallsView];
                    if ([[LogicGame sharedInstance]canStillPlay] == NO) {
                        UIAlertView *nameAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Game over, you got %d points", self.points] message:@"Please type your nickname:" delegate:self cancelButtonTitle:@"Save score" otherButtonTitles:nil];
                        nameAlert.alertViewStyle =UIAlertViewStylePlainTextInput;
                        [nameAlert show];
                        
                    }
                });

            });
        });
    });

    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *name = [[alertView textFieldAtIndex:0] text];
    NSString *points = [NSString stringWithFormat:@"%d", self.points];
    
    NSDictionary*dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", points, @"points", nil];
    
    Session *session = [[LogicGame sharedInstance] session];
    [session addObject:dict];
    
    [self updateHistory];
}

- (void) updateHistory{
    NSMutableArray *history = [[[LogicGame sharedInstance] session].history mutableCopy];
 
    history = [[history sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSDictionary *object1 = (NSDictionary*) obj1;
        NSDictionary *object2 = (NSDictionary*) obj2;
        
        if ([[object1 valueForKey:@"points"] integerValue] < [[object2 valueForKey:@"points"] integerValue]) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }] mutableCopy];
    
    
    NSArray *sc = [NSArray arrayWithObjects:self.topScoresOne, self.topScoresTwo, self.topScoresThree, self.topScoresFour, self.topScoresFive, nil];
    
    for (int i=0; i<history.count; i++){
        if ( i < sc.count) {
            UILabel *label = [sc objectAtIndex:i];
            NSDictionary *dict = [history objectAtIndex:i];
            
            label.text = [NSString stringWithFormat:@"%d. %@ : %@ pkt", i+1, [dict valueForKey:@"name"], [dict valueForKey:@"points"]];

        }
              
    }
    
}

- (void) updateNextBallsView{
    for (int i=0; i<self.nextBalls.count; i++) {
        BallPrototype *prototype = [self.nextBalls objectAtIndex:i];
        ProposalBall *proposalBall = [self.predictTiles objectAtIndex:i];
        [proposalBall setBallType:prototype.ballType];
        [proposalBall show];
    }
}



- (void) tileSelected:(id) sender{
    [self showAllProposalBalls];
}

- (void) hideAllProposalBalls{
    [self.proposalColorOne hide];
    [self.proposalColorTwo hide];
    [self.proposalColorThree hide];
    [self.proposalColorFour hide];
    [self.proposalColorFive hide];
    [self.proposalColorSix hide];
}

- (void) showAllProposalBalls{
    [self.proposalColorOne performSelector:@selector(show) withObject:nil afterDelay:0.0];
    [self.proposalColorTwo performSelector:@selector(show) withObject:nil afterDelay:0.2];
    [self.proposalColorThree performSelector:@selector(show) withObject:nil afterDelay:0.4];
    [self.proposalColorFour performSelector:@selector(show) withObject:nil afterDelay:0.6];
    [self.proposalColorFive performSelector:@selector(show) withObject:nil afterDelay:0.8];
    [self.proposalColorSix performSelector:@selector(show) withObject:nil afterDelay:1.0];
    
    [self performSelector:@selector(hideAllProposalBalls) withObject:nil afterDelay:10];

}


#pragma mark Ball Button Delegate

- (void)ballButton:(BallButton *)ballButton isActive:(BOOL)active{
    if (self.isAnimating == NO){
    if (active){
        self.currentBallButton = ballButton;
    }else{
        self.currentBallButton = nil;
    }
    }
}

#pragma mark Tile Button Delegate

- (void) didPressedTileButton:(TileButton *)tileButton{
    if (self.currentBallButton && self.isAnimating == NO) {
        NSLog(@"Please find path for new place");
        
        
        
        [[LogicGame sharedInstance] findPath:self.currentBallButton.x :self.currentBallButton.y :tileButton.x :tileButton.y completion:^(NSArray *array) {
            self.isAnimating = YES;
            TileButton *curentTile = [self.tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",self.currentBallButton.x,self.currentBallButton.y]];
            curentTile.ballType = BallTypeEmpty;
            TileButton *destinationTile = [self.tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",tileButton.x,tileButton.y]];
            destinationTile.ballType = self.currentBallButton.ballType;
            
            self.currentBallButton.x = tileButton.x;
            self.currentBallButton.y = tileButton.y;
            
            
            NSMutableArray *sequence = [NSMutableArray array];
            for (BallPrototype *ballPrototype in array) {
                for (TileButton *tile in [self.tiles allValues]
                    ) {
                    if (tile.x == ballPrototype.x && tile.y == ballPrototype.y) {
                        [sequence addObject:tile];
                    }
                }
            }
            
            NSArray* reversedArray = [[sequence reverseObjectEnumerator] allObjects];

            int index = 0;
            TileButton *next = [reversedArray objectAtIndex:index];
            [self moveBallToTile:next index:index inArray:reversedArray];
            
        }];
    }
    
    
    
    
    

}

- (void) moveBallToTile:(TileButton*) tile index:(int) index inArray:(NSArray*) sequence{
    [UIView animateWithDuration:0.1 animations:^{
        self.currentBallButton.center = tile.center;
    } completion:^(BOOL finished) {
        int newindex = index+1;
        if (newindex <= sequence.count) {
            TileButton *next = [sequence objectAtIndex:index];
            [self moveBallToTile:next index:newindex inArray:sequence];
        }else{
            self.isAnimating = NO;
            [[LogicGame sharedInstance] updateMatrix:self.tiles];
            self.currentBallButton.isActive = NO;
            self.currentBallButton = nil;
            
            NSArray *needRemove = [[LogicGame sharedInstance] sectionsNeedToBeRemovedAfterAction];
            if (needRemove.count) {
                [self removeBallsWithAnimation:needRemove];
            }else{
                [self randomizeBalllForDifficult:self.difficultType];

            }
        }

    }];
    
    
}


- (void) removeBallsWithAnimation:(NSArray*) array{
    int counter = 0;
    for (NSArray *sequence in array) {
        
        for (BallPrototype *ballPrototype in sequence) {
            
            for (BallButton *ball in self.balls) {
                if (ball.x == ballPrototype.x && ball.y == ballPrototype.y) {
                    if (ball.ballType != BallTypeEmpty) {
                        TileButton *tile = (TileButton*)[self.tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",ball.x,ball.y]];
                        tile.ballType = BallTypeEmpty;
                        counter++;
                        [[LogicGame sharedInstance] updateMatrix:self.tiles];
                        [UIView animateWithDuration:0.5 animations:^{
                            ball.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [ball removeFromSuperview];
                            
                        }];
                    }

                }
            }
            
        }
        
        
    }
    
    [self addPoints:counter];
    
    
    
}


- (void) addPoints:(int)counter{
    
    if (self.difficultType == DifficultTypeNormal) {
        counter = counter*1.5;
    }else if(self.difficultType == DifficultTypeHard){
        counter = counter*2;
    }
    self.points += counter;
    
    self.scorePointLabel.text = [NSString stringWithFormat:@"%d pkt",self.points];
}
@end
