//
//  LogicGame.m
//  Balls
//
//  Created by Jacek Grygiel on 6/13/13.
//  Copyright (c) 2013 Jacek Grygiel. All rights reserved.
//

#import "LogicGame.h"
#import "TileButton.h"
#import "GameViewController.h"

@implementation Session
@synthesize history = _history;

- (id)init
{
    self = [super init];
    if (self) {
        [self loadSession];
    }
    return self;
}

- (NSMutableArray *)history{
    return [[[_history reverseObjectEnumerator] allObjects] mutableCopy];
}

- (void) clearSession{
    if (_history != nil && _history.count>0) {
        [_history removeAllObjects];
        [self storeSession];
    }
}

- (void) storeSession{
    
    NSData *history = [NSKeyedArchiver archivedDataWithRootObject:_history];
    [[NSUserDefaults standardUserDefaults] setObject:history forKey:@"history"];
    
}

- (void) loadSession{
    NSData *history = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:history];
    if (array != nil){
        _history = [array mutableCopy];
    }else{
        _history = [NSMutableArray array];
    }
}

- (void) addObject:(id) object{
    [_history addObject:object];
    [self storeSession];
}
- (void) removeObject:(id) object{
    for (NSString *identifier in _history) {
        if ([identifier isEqualToString:(NSString*) object]) {
            [_history removeObject:identifier];
        }
    }
    [self storeSession];
}
@end



@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	int cost;
	PathFindNode *parentNode;
}
+(id)node;
@end
@implementation PathFindNode
+(id)node
{
	return [[PathFindNode alloc] init];
}
@end

@implementation BallPrototype

- (id)initWithX:(int) x andY:(int) y andBallType:(BallType) ballType
{
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.ballType = ballType;
    }
    return self;
}

- (NSString *)description{
    
    return [NSString stringWithFormat:@"%d, %d", self.x, self.y];
    
}
@end

@interface LogicGame ()
@property(nonatomic, strong) NSOperationQueue *operationQueue;
@property(nonatomic, strong)     NSMutableArray *paths ;
@property(nonatomic, copy) CompletionBSFFinder completion;
@property(nonatomic, unsafe_unretained) BOOL quickFinding;
@end

@implementation LogicGame

static LogicGame *sharedInstance = nil;

+ (LogicGame*) sharedInstance{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance createEmptyArrays];
        sharedInstance.operationQueue = [[NSOperationQueue alloc] init];
        sharedInstance.session = [[Session alloc] init];
    }
    return sharedInstance;

}


- (void) createEmptyArrays{
    
    NSMutableArray *matrix = [NSMutableArray array];
    for(int i=0; i<SQUARE; i++)
    {
        NSMutableArray *rowMatrix = [NSMutableArray array];
        for (int j=0; j<SQUARE; j++) {
            [rowMatrix addObject:[[BallPrototype alloc] initWithX:j andY:i andBallType:BallTypeEmpty]];
            
        }
        [matrix addObject:rowMatrix];
    }
    
    self.matrixArray = matrix;
    
}
- (void) addBall:(BallType) ballType atPositionX:(int) x andPositionY:(int) y{
    
    
    BallPrototype *ball = [self prototypeBall:x andY:y];
    if (ball) {
        ball.ballType = ballType;
    }
}



- (NSArray*) randomizeBallsForDifficult:(DifficultType) difficultType{
    NSMutableArray *randomBalls = [NSMutableArray array];
    switch (difficultType) {
        case DifficultTypeEasy:
        {
            for (int i = 0; i<3; i++) {
                NSInteger randomNumber = arc4random() % 3 + 1;
                BallPrototype *ball = [[BallPrototype alloc] initWithX:0 andY:0 andBallType:randomNumber];
                [randomBalls addObject:ball];
            }
            break;
        }
        case DifficultTypeNormal:
        {
            for (int i = 0; i<4; i++) {
                NSInteger randomNumber = arc4random() % 4 + 1;
                BallPrototype *ball = [[BallPrototype alloc] initWithX:0 andY:0 andBallType:randomNumber];
                [randomBalls addObject:ball];
            }
            break;
        }
        case DifficultTypeHard:
        {
            for (int i = 0; i<6; i++) {
                NSInteger randomNumber = arc4random() % 6 + 1;
                BallPrototype *ball = [[BallPrototype alloc] initWithX:0 andY:0 andBallType:randomNumber];
                [randomBalls addObject:ball];
            }
            break;
        }
        default:
            break;
    }
    
    
    return randomBalls;
    
}

- (void) updateMatrixWithRandomBalls:(NSArray*) randomBallsTemp{
    NSMutableArray *randomBalls = [randomBallsTemp mutableCopy];
    
//    if ([self canAddRandomBalls:randomBalls.count]) {
//        
        // prepare matrix for free places
        NSMutableArray *freeMatrix = [NSMutableArray array];
        for (NSArray *rows in self.matrixArray) {
            for (BallPrototype *ball in rows) {
                if (ball.ballType == BallTypeEmpty) {
                    [freeMatrix addObject:ball];
                }
            }
        }
    
    if (freeMatrix.count<randomBalls.count) {
        int dt = randomBalls.count - freeMatrix.count;
        for (int i = 0; i<dt; i++) {
            [randomBalls removeLastObject];
        }
    }
        
        
        for (int i = 0; i<randomBalls.count;i++){
            BallPrototype *ballRandom = [randomBalls objectAtIndex:i];
            NSInteger random = arc4random() % freeMatrix.count;
            BallPrototype *ball = [freeMatrix objectAtIndex:random];
            ball.ballType = ballRandom.ballType;
            ballRandom.x = ball.x;
            ballRandom.y = ball.y;
            [freeMatrix removeObject:ball];
            
        }
        
//    }else{
//        //less than place for all balls
//        NSMutableArray *freeMatrix = [NSMutableArray array];
//        for (NSArray *rows in self.matrixArray) {
//            for (BallPrototype *ball in rows) {
//                if (ball.ballType == BallTypeEmpty) {
//                    [freeMatrix addObject:ball];
//                }
//            }
//        }
//        
//        int dt = randomBalls.count - freeMatrix.count;
//        for (int i=0;i<dt;i++){
//            [randomBalls removeLastObject];
//        }
//        
//        if (freeMatrix.count>0) {
//            for (int i = 0; i<freeMatrix.count;i++){
//                BallPrototype *ballRandom = [randomBalls objectAtIndex:i];
//                NSInteger random = arc4random() % freeMatrix.count;
//                BallPrototype *ball = [freeMatrix objectAtIndex:random];
//                ball.ballType = ballRandom.ballType;
//                ballRandom.x = ball.x;
//                ballRandom.y = ball.y;
//                [freeMatrix removeObject:ball];
//                
//            }
//                        
//        }else{
//        }
//    }
    
    
    for (BallPrototype *needBall in randomBalls) {
        [self addBall:needBall.ballType atPositionX:needBall.x andPositionY:needBall.y];
    }

}

- (BOOL) canStillPlay{
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            if (ball.ballType == BallTypeEmpty) {
                return YES;
            }
        }
    }
    return NO;
}

- (void) clearMatrix{
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            ball.ballType = BallTypeEmpty;
        }
    }
}

- (void) updateMatrix:(NSDictionary*) tiles{
    
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            
            TileButton *tileButton = [tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",ball.x,ball.y]];
            ball.ballType = tileButton.ballType;
        }
    }
    
    //NSLog(@"===========================================");
    for (int i = 0; i<SQUARE; i++) {
        NSString *row = [NSString stringWithFormat:@""];
        for(int j = 0; j<SQUARE; j++){
            TileButton  *tile = (TileButton*)[tiles valueForKey:[NSString stringWithFormat:@"x:%d,y:%d",j,i]];
            row = [row stringByAppendingFormat:@"%d ", tile.ballType];

        }
       //NSLog(@"%@", row);
    }
    //NSLog(@"===========================================");
}


- (BOOL) canAddRandomBalls:(int) count{
    int countFreePosition = 0;
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            if (ball.ballType == BallTypeEmpty) {
                countFreePosition++;
            }
        }
    }
    
    if (countFreePosition >= count) {
        return YES;
    }else{
        return NO;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// A* methods begin//////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)spaceIsBlocked:(int)x :(int)y;
{
	//general-purpose method to return whether a space is blocked
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            if (ball.x == x && ball.y == y){
                if (ball.ballType != BallTypeEmpty) {
                    return YES;
                }else{
                    return NO;
                }
            }
        }
    }
    return NO;
}

-(PathFindNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y
{
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [a objectEnumerator];
	PathFindNode *n;
	
	while((n = [e nextObject]))
	{
		if((n->nodeX == x) && (n->nodeY == y))
		{
			return n;
		}
	}
	
	return nil;
}
-(PathFindNode*)lowestCostNodeInArray:(NSMutableArray*)a
{
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
	NSEnumerator *e = [a objectEnumerator];
	
	while((n = [e nextObject]))
	{
		if(lowest == nil)
		{
			lowest = n;
		}
		else
		{
			if(n->cost < lowest->cost)
			{
				lowest = n;
			}
		}
	}
	return lowest;
}


- (void) prepareArrayForPathsX:(int) x andY:(int) y{
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            if (ball.x == x && ball.y == y) {
                [self.paths addObject:ball];
            }
        }
    }
}

-(void)findPath:(int)startX :(int)startY :(int)endX :(int)endY completion:(CompletionBSFFinder) completion
{
    self.completion = completion;
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	
	int x,y;
	int newX,newY;
	int currentX,currentY;
	NSMutableArray *openList, *closedList;
	
	if((startX == endX) && (startY == endY))
		return; //make sure we're not already there
	
	openList = [NSMutableArray array]; //array to hold open nodes
	
	closedList = [NSMutableArray array]; //array to hold closed nodes
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	//create our initial 'starting node', where we begin our search
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0;
	//add it to the open list to be examined
	[openList addObject: startNode];
	
	while([openList count])
	{
		//while there are nodes to be examined...
		
		//get the lowest cost node so far:
		currentNode = [self lowestCostNodeInArray: openList];
		
		if((currentNode->nodeX == endX) && (currentNode->nodeY == endY))
		{
			//if the lowest cost node is the end node, we've found a path
			
			//********** PATH FOUND ********************
            self.paths = [NSMutableArray array];
			while(currentNode->parentNode != nil)
			{
                [self prepareArrayForPathsX:currentNode->nodeX andY:currentNode->nodeY];
				currentNode = currentNode->parentNode;
			}
            self.completion(self.paths);
			return;

			
            //*****************************************//
		}
		else
		{
			//...otherwise, examine this node.
			//remove it from open list, add it to closed:
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			
			//lets keep track of our coordinates:
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
			
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					if((y || x) && !(abs(x)== 1 && abs(y) == 1)) //avoid 0,0
					{
						//simple bounds check for the demo app's array
						if((newX>=0)&&(newY>=0)&&(newX<=SQUARE-1)&&(newY<=SQUARE-1))
						{
							//if the node isn't in the open list...
							if(![self nodeInArray: openList withX: newX Y:newY])
							{
								//and its not in the closed list...
								if(![self nodeInArray: closedList withX: newX Y:newY])
								{
									//and the space isn't blocked
									if(![self spaceIsBlocked: newX :newY])
									{
										//then add it to our open list and figure out
										//the 'cost':
										aNode = [PathFindNode node];
										aNode->nodeX = newX;
										aNode->nodeY = newY;
										aNode->parentNode = currentNode;
										aNode->cost = currentNode->cost + 1;
										
										//Compute your cost here. This demo app uses a simple manhattan
										//distance, added to the existing cost
										aNode->cost += (abs((newX) - endX) + abs((newY) - endY));
										
										[openList addObject: aNode];

									}
								}
							}
						}
					}
				}
			}
		}
	}

}

////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// End A* code/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

- (BallPrototype*) prototypeBall:(int) x andY:(int) y{
    for (NSArray *rows in self.matrixArray) {
        for (BallPrototype *ball in rows) {
            if (ball.x == x && ball.y == y) {
                return ball;
            }
        }
    }
    return nil;
}

- (NSArray *)sectionsNeedToBeRemovedAfterAction{
    
    
    NSMutableArray *needToRemove = [NSMutableArray array];
    //================================================vertical
    int max = 5;
    for(int y=0;y<SQUARE;y++){
        for(int x=0;x<SQUARE;x++){
            
            //check rows
            if (x <=(SQUARE - max)) {
                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = x;i<x+max;i++) {
                    BallPrototype *node = [self prototypeBall:i andY:y];
                    if (node.ballType != BallTypeEmpty) {
                        if (sequence.count>0 && node.ballType == ballType) {
                            [sequence addObject:node];
                        }else{
                            if (i > x) {
                                break;
                            }
                            ballType = node.ballType;
                            [sequence removeAllObjects];
                            [sequence addObject:node];
                        }
                        
                    }
                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                
                }
            }            
        }
    }
    
    //================================================horizontal
    
    
    for(int x=0;x<SQUARE;x++){
        for(int y=0;y<SQUARE;y++){
            
            //check col
            if (y <=(SQUARE - max)) {
                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = y;i<y+max;i++) {
                    BallPrototype *node = [self prototypeBall:x andY:i];
                    if (node.ballType != BallTypeEmpty) {
                        if (sequence.count>0 && node.ballType == ballType) {
                            [sequence addObject:node];
                        }else{
                            if (i > y) {
                                break;
                            }
                            ballType = node.ballType;
                            [sequence removeAllObjects];
                            [sequence addObject:node];
                        }
                        
                    }
                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                    
                }
            }
        }
    }
    
    //================================================cros 

    
    
    for(int x=0;x<SQUARE;x++){
        for(int y=0;y<SQUARE;y++){
            
            int xd = x+y;
            if (xd <SQUARE) {

                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = 0;i <max; i++) {
                    
                    int kx = xd+i;
                    int ky = y+i;
                    if (kx < SQUARE && ky <SQUARE) {
                        BallPrototype *node = [self prototypeBall:kx andY:ky];
                        if (node.ballType != BallTypeEmpty) {
                            if (sequence.count>0 && node.ballType == ballType) {
                                [sequence addObject:node];
                            }else{
                                ballType = node.ballType;
                                [sequence removeAllObjects];
                                [sequence addObject:node];
                            }
                            
                        }
                    }

                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                }

            }
            
            
        }
    }
    
    
       for(int y=0;y<SQUARE;y++){
           for(int x=0;x<SQUARE;x++){
            int yd = x+y;
            if (yd <SQUARE) {
                
                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = 0;i <max; i++) {
                    
                    int ky = yd+i;
                    int kx = x+i;
                    if (kx < SQUARE && ky <SQUARE) {
                        BallPrototype *node = [self prototypeBall:kx andY:ky];
                        if (node.ballType != BallTypeEmpty) {
                            if (sequence.count>0 && node.ballType == ballType) {
                                [sequence addObject:node];
                            }else{
                                ballType = node.ballType;
                                [sequence removeAllObjects];
                                [sequence addObject:node];
                            }
                            
                        }
                    }
                    
                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                }
                
            }
            
            
        }
       }
    //================================================cros reverse
    for(int y=0;y<SQUARE;y++){
    for(int x=SQUARE-1;x>=0;x--){
            int xd = x-y;
            if (xd <SQUARE && xd>=0) {
                
                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = 0;i <max; i++) {
                    int ky = y+i;
                    int kx = xd-i;

                    if (kx>=0 && kx < SQUARE && ky>=0 && ky <SQUARE) {
                        BallPrototype *node = [self prototypeBall:kx andY:ky];
                        if (node.ballType != BallTypeEmpty) {
                            if (sequence.count>0 && node.ballType == ballType) {
                                [sequence addObject:node];
                            }else{
                                ballType = node.ballType;
                                [sequence removeAllObjects];
                                [sequence addObject:node];
                            }
                            
                        }
                    }
                    
                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                }
                
            }
            
            
        }
    }
    
    for(int y=0;y<SQUARE;y++){
        for(int x=SQUARE-1;x>=0;x--){
            int yd = y+(SQUARE-1-x);
            if (yd <SQUARE && yd>=0) {
                
                NSMutableArray *sequence = [NSMutableArray array];
                int ballType = 0;
                for (int i = 0;i <max; i++) {
                    
                    int ky = yd+i;
                    int kx = x-i;
                    if (kx>=0 && kx < SQUARE && ky>=0 && ky <SQUARE) {
                        BallPrototype *node = [self prototypeBall:kx andY:ky];
                        if (node.ballType != BallTypeEmpty) {
                            if (sequence.count>0 && node.ballType == ballType) {
                                [sequence addObject:node];
                            }else{
                                ballType = node.ballType;
                                [sequence removeAllObjects];
                                [sequence addObject:node];
                            }
                            
                        }
                    }
                    
                }
                if (sequence.count == max) {
                    
                    [needToRemove addObject:sequence];
                }
                
            }
            
            
        }
    }

    
    return needToRemove;
}

@end
