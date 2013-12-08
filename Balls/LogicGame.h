//
//  LogicGame.h
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BallPrototype;
typedef void (^CompletionBSFFinder)(NSArray* array);

typedef enum BallType {
    BallTypeEmpty = 0,
    BallTypeRed = 1,
    BallTypeGreen = 2,
    BallTypePurple = 3,
    BallTypeOrange = 4,
    BallTypeBlue = 5,
    BallTypeYellow = 6
} BallType;


typedef enum DifficultType {
    DifficultTypeEasy = 0,
    DifficultTypeNormal = 1,
    DifficultTypeHard = 2,
}DifficultType;


@interface Session : NSObject<NSCoding>
{
    
}
@property(nonatomic, strong) NSMutableArray *history;
- (void) clearSession;
- (void) addObject:(id) object;
@end

@interface BallPrototype : NSObject
@property(nonatomic, unsafe_unretained) int x;
@property(nonatomic, unsafe_unretained) int y;
@property(nonatomic, unsafe_unretained) BallType ballType;
- (id)initWithX:(int) x andY:(int) y andBallType:(BallType) ballType;
@end

@interface LogicGame : NSObject
{
}
@property(nonatomic, strong) NSArray *matrixArray;

@property(nonatomic, strong) Session *session;

+ (LogicGame*) sharedInstance;

- (BOOL) canStillPlay;
- (void) createEmptyArrays;
- (void) clearMatrix;
- (void) updateMatrixWithRandomBalls:(NSArray*) randomBalls;
- (void) addBall:(BallType) ballType atPositionX:(int) x andPositionY:(int) y;
- (BOOL) checkIfCanAddBall:(BallType) ballType atPositionX:(int) x andPositionY:(int) y;
-(void)findPath:(int)startX :(int)startY :(int)endX :(int)endY completion:(CompletionBSFFinder) completion;
- (NSArray*) sectionsNeedToBeRemovedAfterAction;
- (NSArray*) randomizeBallsForDifficult:(DifficultType) difficultType;
- (void) updateMatrix:(NSDictionary*) tiles;
@end
