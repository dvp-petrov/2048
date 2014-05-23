#import "GameBoardDataBase.h"

#define kEmptyCellContect @""
#define kChance 10
#define kTwosMaxValue 8
#define kReturnTwoForEmptyCell 2
#define kReturnFourForEmptyCell 4
#define kWinGameConditionValue 2048

@interface GameBoardDataBase ()

@property (nonatomic, readwrite) NSMutableDictionary* gameBoardCells;
@property (nonatomic) BOOL availableCells;
@property (nonatomic) NSMutableArray* emptyCells;
@property (nonatomic, readwrite) BOOL gameEnd;
@property (nonatomic, readwrite) BOOL gameWin;
@property (nonatomic, readwrite) BOOL firstTimeWin;
@property (nonatomic, readwrite) NSUInteger points;
@property (nonatomic) NSMutableArray* sumedCells;

@end


@implementation GameBoardDataBase

static BOOL isInited = NO;

+ (id)sharedInstance {
    static GameBoardDataBase* instance = nil;
    if(!instance){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [super alloc];
        });
    }
    return instance;
}

+ (id)alloc {
    return [GameBoardDataBase sharedInstance];
}

- (id)init
{
    if (!isInited){
        self = [super init];
        if (self) {
            [self initData];
        }
        isInited = YES;
    }
    
    return self;
}

- (id)copy {
    return self;
}

- (id)mutableCopy {
    return self;
}

- (void)initData
{
    self.gameBoardCells = [[NSMutableDictionary alloc] init];
    self.sumedCells = [NSMutableArray arrayWithCapacity:kCapacity];
    for (int i = 0; i < kCapacity; i++) {
        [self.sumedCells addObject:[NSNumber numberWithInt:0]];
    }
    self.emptyCells = [[NSMutableArray alloc] initWithCapacity:kCapacity];
    for (int i = 0; i < kCapacity; i++) {
        [self.emptyCells addObject:[NSNumber numberWithInt:i]];
    }
    self.points = 0;
    self.gameEnd = NO;
    self.gameWin = NO;
    self.firstTimeWin = YES;
    [self addNumberInCell];
    [self addNumberInCell];
}

-(void) resetData {
    return [self initData];
}

//returning number -> content of cell
-(NSString*) cellAtIndexPath:(NSInteger) index {
    if ([self.emptyCells containsObject:[NSNumber numberWithInt: index]]) {
        return kEmptyCellContect;
    }
    
    return [NSString stringWithFormat:@"%@",[self.gameBoardCells objectForKey:[NSNumber numberWithInt:index]]];
}

//insert 2 or 4(10%) in random cell
-(void) addNumberInCell {
    id index = [self.emptyCells objectAtIndex:arc4random()%([self.emptyCells count])];
    [self.emptyCells removeObject:index];
    [self.gameBoardCells removeObjectForKey:index];
    [self.gameBoardCells setObject:[NSNumber numberWithInt:[self returnTwoOrFourForNewCell]] forKey:index];
}

//inserting random value -> 2(90%) or 4(10%)
-(int) returnTwoOrFourForNewCell {
    int chance = arc4random()%kChance;
    int returnValue = (chance <= kTwosMaxValue) ? kReturnTwoForEmptyCell : kReturnFourForEmptyCell;
    return returnValue;
}

-(void) moveCellsInDirection:(UISwipeGestureRecognizerDirection) direction {
    static BOOL addCell = YES;
    for (int i = 0; i < kCapacity; i++) {
        [self.sumedCells replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
    }
    NSMutableDictionary* boardBeforeSwipe = [NSMutableDictionary dictionaryWithDictionary:self.gameBoardCells];
    
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp:
            for (int col = 0; col < kColumns; col++) {
                for (int row = 0; row < kRows; row++) {
                    if ([self toMoveCellAtIndex: row * kColumns + col andDirection:direction]){
                        BOOL summed = [self moveCellAtIndex:row * kColumns + col inDirection:direction];
                        if (summed)
                            row --;
                        else
                            row -= 2;
                    }
                }
            }
            break;
        case UISwipeGestureRecognizerDirectionDown:
            for (int col = 0; col < kColumns; col++) {
                for (int row = kRows-1; row >= 0; row--) {
                    if ([self toMoveCellAtIndex: row * kColumns + col andDirection:direction]){
                        BOOL summed = [self moveCellAtIndex:row * kColumns + col inDirection:direction];
                        if (summed)
                            row ++;
                        else
                            row += 2;
                    }
                }
            }
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            for (int row = 0; row < kRows; row++) {
                for (int col = 0; col < kColumns; col++) {
                    if ([self toMoveCellAtIndex: row * kColumns + col andDirection:direction]){
                        BOOL summed = [self moveCellAtIndex:row * kColumns + col inDirection:direction];
                        if (summed)
                            col --;
                        else
                            col -= 2;
                    }
                }
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            for (int row = 0; row < kRows; row++) {
                for (int col = kColumns-1; col >= 0; col--) {
                    if ([self toMoveCellAtIndex: row * kColumns + col andDirection:direction]){
                        BOOL summed = [self moveCellAtIndex:row * kColumns + col inDirection:direction];
                        if (summed)
                            col ++;
                        else
                            col += 2;
                    }
                }
            }
            break;
        default:
            break;
    }
    //adding new cell(2 or 4) if a valid swipe
    [self toAddNewCellWithBoardBeforeSwipe:boardBeforeSwipe andAddCellState:&addCell];
    self.gameEnd = [self checkGameEndWithPreCondition:!addCell];
    addCell = YES;
}

-(void) toAddNewCellWithBoardBeforeSwipe:(NSMutableDictionary*) boardBeforeSwipe andAddCellState:(BOOL*) addCell {
    if ([boardBeforeSwipe isEqualToDictionary:self.gameBoardCells]) {
        *addCell = NO;
    }
    if (*addCell) {
        [self addNumberInCell];
    }
}

//check if game ended -> no valid swipe move
-(BOOL) checkGameEndWithPreCondition:(BOOL) condition {
    if (condition && [self.emptyCells count] == 0) {
        for (int i = 0; i < kCapacity; i++) {
            if (i/kColumns < 1) {
                if ([self.gameBoardCells objectForKey:[NSNumber numberWithInt:i]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:i+kColumns]]) {
                    return NO;
                }
            }
            if (2 <= i/kColumns &&
                i/kColumns < 3) {
                if ([self.gameBoardCells objectForKey:[NSNumber numberWithInt:i]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:i-kColumns]] ||
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:i]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:i+kColumns]]) {
                    return NO;
                }
            }
        }
        for (int j = 0; j < kCapacity; j+=2) {
            if (j % kRows == 0) {
                if ([self.gameBoardCells objectForKey:[NSNumber numberWithInt:j]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:j+1]]) {
                    return NO;
                }
            }
            else {
                if ([self.gameBoardCells objectForKey:[NSNumber numberWithInt:j]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:j-1]] ||
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:j]] ==
                    [self.gameBoardCells objectForKey:[NSNumber numberWithInt:j+1]]) {
                    return NO;
                }
            }
        }
        return YES;
    }
    return NO;
}

-(BOOL) moveCellAtIndex:(NSInteger) index inDirection: (UISwipeGestureRecognizerDirection) direction{
    int newIndex;
    
    switch (direction) {
        case UISwipeGestureRecognizerDirectionDown:
            newIndex = index + kColumns;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            newIndex = index - kColumns;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            newIndex = index - 1;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            newIndex = index + 1;
            break;
        default:
            break;
    }
    
    if ([self.emptyCells containsObject:[NSNumber numberWithInt: newIndex]]){
        [self.gameBoardCells setObject:[self.gameBoardCells objectForKey:[NSNumber numberWithInt: index]] forKey:[NSNumber numberWithInt: newIndex]];
        [self.gameBoardCells removeObjectForKey:[NSNumber numberWithInt:index]];
        [self.emptyCells addObject:[NSNumber numberWithInt: index]];
        [self.emptyCells removeObject:[NSNumber numberWithInt: newIndex]];
    }
    
    else{
        NSNumber* numberInCell = [self.gameBoardCells objectForKey:[NSNumber numberWithInt: index]];
        numberInCell = [NSNumber numberWithInt: numberInCell.intValue * 2];
        [self.gameBoardCells setObject: numberInCell forKey:[NSNumber numberWithInt: newIndex]];
        [self.sumedCells replaceObjectAtIndex:newIndex withObject:[NSNumber numberWithInt:1]];
        
        [self.emptyCells addObject:[NSNumber numberWithInt: index]];
        [self.emptyCells removeObject:[NSNumber numberWithInt: newIndex]];
        self.points += [numberInCell integerValue];
        //win condition
        if ([numberInCell integerValue] == kWinGameConditionValue) {
            self.gameWin = YES;
        }
        return YES;
    }
    
    return NO;
}

-(BOOL) toMoveCellAtIndex:(NSInteger) index andDirection:(UISwipeGestureRecognizerDirection) direction{
    if([self.emptyCells containsObject:[NSNumber numberWithInt:index]]){
        return NO;
    }
    
    int vectorRow;
    int vectorCol;
    
    switch (direction) {
        case UISwipeGestureRecognizerDirectionDown:
            vectorRow = 1;
            vectorCol = 0;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            vectorRow = -1;
            vectorCol = 0;
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            vectorRow = 0;
            vectorCol = -1;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            vectorRow = 0;
            vectorCol = 1;
            break;
        default:
        break;
    }
    
    // end cell in row
    if (((int)index/kRows + vectorRow) < 0 || ((int)index/kRows + vectorRow) >= kRows){
        return NO;
    }
    
    // end cell in columns
    if (((int)index%kRows + vectorCol) < 0 || ((int)index%kRows + vectorCol) >= kColumns){
        return NO;
    }
    
    int nextCell = index + vectorCol + vectorRow*kColumns;
    if ([self.emptyCells containsObject: [NSNumber numberWithInt: nextCell]])
        return YES;
    //integer value] to check the relation of two nsnumbers!!
    if ([[self.gameBoardCells objectForKey:[NSNumber numberWithInt: nextCell]]integerValue] !=
        [[self.gameBoardCells objectForKey:[NSNumber numberWithInt: index]]integerValue]){
        return NO;
    }
    else {
        if([[self.sumedCells objectAtIndex:nextCell] intValue] == 1)
            return NO;
    }
    
    return YES;
}

-(void) gameWon {
    self.firstTimeWin = NO;
}

@end
