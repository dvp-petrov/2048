//
//  GameBoardDataBase.h
//  2048
//
//  Created by User-15 on 4/7/14.
//  Copyright (c) 2014 IOTrainingCamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kRows 4
#define kColumns 4
#define kCapacity kRows*kColumns

@interface GameBoardDataBase : NSObject

@property (nonatomic, readonly) NSMutableDictionary* gameBoardCells;
@property (nonatomic, readonly) BOOL gameEnd;
@property (nonatomic, readonly) BOOL gameWin;
@property (nonatomic, readonly) BOOL firstTimeWin;
@property (nonatomic, readonly) NSUInteger points;

+ (id)sharedInstance;
-(void) resetData;
-(void) gameWon;
-(void) addNumberInCell;
-(NSString*) cellAtIndexPath:(NSInteger) indexPath;
-(void) moveCellsInDirection:(UISwipeGestureRecognizerDirection) direction;

@end
