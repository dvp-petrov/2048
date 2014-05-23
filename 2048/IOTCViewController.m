//A Game made by Dimitar Petrov & Anna Milenkova

#import "IOTCViewController.h"
#import "GameBoardDataBase.h"

#define kCellColorRedFloatValue 35/255.0f
#define kCellColorGreenFloatValue 5/255.0f
#define kCellColorBlueFloatValue 1/255.0f
#define kOffsetPercentage 6/100
#define kFontSizePercentage 20/100
#define kMaxColor 256
#define kColorMultiplier 64

#define kPointsLandscapeSideConstraintConstant 10
#define kRestartButtonLandscapeSideConstraintConstant -5
#define kPointsPortraitSideConstraintConstant 40
#define kRestartButtonPortraitSideConstraintConstant -20

#define kPointsLabelTitle @"Points:"
#define kRestartButtonTitle @"Restart"

#define kGameOverAlertViewTitle @"Game Over"
#define kGameOverAlertViewMessage @"No more valid moves!"
#define kWinGameAlertViewTitle @"You Win!"
#define kWinGameAlertViewMessage @"Congratulations! You Win! 2048!!!"
#define kWinGameAlertViewOtherButtonTitle @"Continue Playing..."
#define kRestartGameString @"Restart Game"
#define kRestartGameAlertViewMessage @"Do you want to restart the game"
#define kRestartGameAlertViewOtherButtonTitle @"Nope"

@interface IOTCViewController ()

@property NSMutableArray* cells;
@property GameBoardDataBase* gameBoard;
@property(nonatomic) UIView* board;

@property (nonatomic) UILabel *gamePoints;
@property (nonatomic) UILabel *pointsLabel;
@property (nonatomic) UIButton *restartButton;

@property (nonatomic) NSLayoutConstraint* restartButtonCenterConstraint;
@property (nonatomic) NSLayoutConstraint* restartButtonSideConstraint;

@property(nonatomic) NSLayoutConstraint* pointsLabelCenterConstraint;
@property(nonatomic) NSLayoutConstraint* pointsLabelSideConstraint;

@property(nonatomic) NSLayoutConstraint* gamePointsCenterConstraint;
@property(nonatomic) NSLayoutConstraint* gamePointsSideConstraint;

@property (nonatomic) CGFloat fontSize;

@end


@implementation IOTCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameBoard = [[GameBoardDataBase alloc] init];
    
	[self.view setBackgroundColor: [UIColor brownColor]];
    
    self.board = [[UIView alloc] init];
    [self.board setBackgroundColor:[UIColor grayColor]];
    
    [self.view removeConstraints: self.view.constraints];
    [self.board setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:self.board];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:(self.view.frame.size.height > self.view.frame.size.width)? self.view.frame.size.width : self.view.frame.size.height]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.board
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:(self.view.frame.size.height > self.view.frame.size.width)? self.view.frame.size.width : self.view.frame.size.height]];
    
    CGFloat cellSide = ((self.view.frame.size.height > self.view.frame.size.width)? self.view.frame.size.width : self.view.frame.size.height) / kRows;
    CGFloat offsetPercentange = cellSide*kOffsetPercentage;
    self.cells = [[NSMutableArray alloc] initWithCapacity: kColumns*kRows];
    
    for(int i = 0; i < kRows; i++)
        for(int j = 0; j < kColumns; j++){
            UILabel* newView = [[UILabel alloc] initWithFrame: CGRectMake(j * cellSide+offsetPercentange, i * cellSide+offsetPercentange, cellSide-2*offsetPercentange, cellSide-2*offsetPercentange)];
            [self.cells addObject:newView];
            [self.board addSubview:newView];
            
            newView.text = [self.gameBoard cellAtIndexPath: i*kRows + j];
            [newView setBackgroundColor:[UIColor colorWithWhite:(int)newView.text alpha:0]];
            newView.textAlignment = NSTextAlignmentCenter;
        }
    
    self.fontSize = cellSide*kFontSizePercentage;
    
    UISwipeGestureRecognizer* swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(responseToSwipeGesture:)];
    swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(responseToSwipeGesture:)];
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer* swipeRecognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(responseToSwipeGesture:)];
    swipeRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer* swipeRecognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(responseToSwipeGesture:)];
    swipeRecognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer: swipeRecognizerLeft];
    [self.view addGestureRecognizer: swipeRecognizerRight];
    [self.view addGestureRecognizer: swipeRecognizerUp];
    [self.view addGestureRecognizer: swipeRecognizerDown];
    
	[self reloadBoard];

    //adding restart button
    self.restartButton = [[UIButton alloc] init];
    [self.view addSubview:self.restartButton];
    [self.restartButton setTitle:kRestartButtonTitle forState:UIControlStateNormal];
    [self.restartButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.restartButton.titleLabel setFont:[UIFont systemFontOfSize:self.fontSize]];
    [self.restartButton addTarget:self action:@selector(restartGameButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.restartButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.restartButtonCenterConstraint = [[NSLayoutConstraint alloc] init];
    self.restartButtonSideConstraint = [[NSLayoutConstraint alloc] init];
    
    //adding points label
    self.pointsLabel = [[UILabel alloc] init];
    [self.view addSubview:self.pointsLabel];
    [self.pointsLabel setText:kPointsLabelTitle];
    [self.pointsLabel setTextColor:[UIColor darkTextColor]];
    [self.pointsLabel setFont:[UIFont systemFontOfSize:self.fontSize]];
    
    [self.pointsLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.pointsLabelCenterConstraint = [[NSLayoutConstraint alloc] init];
    self.pointsLabelSideConstraint = [[NSLayoutConstraint alloc] init];
    
    //adding game points label
    self.gamePoints = [[UILabel alloc] init];
    [self.view addSubview:self.gamePoints];
    [self.gamePoints setText:[NSString stringWithFormat:@"%d",self.gameBoard.points]];
    [self.gamePoints setTextColor:[UIColor darkTextColor]];
    [self.gamePoints setFont:[UIFont systemFontOfSize:self.fontSize]];
    self.gamePoints.textAlignment = NSTextAlignmentRight;
    
    [self.gamePoints setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.gamePointsCenterConstraint = [[NSLayoutConstraint alloc] init];
    self.gamePointsSideConstraint = [[NSLayoutConstraint alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void) responseToSwipeGesture: (UISwipeGestureRecognizer*) sender{
    [self.gameBoard moveCellsInDirection:sender.direction];
    [self reloadBoard];
    if (self.gameBoard.gameEnd) {
        UIAlertView* endGameAlertView = [[UIAlertView alloc] initWithTitle:kGameOverAlertViewTitle message:kGameOverAlertViewMessage delegate:self cancelButtonTitle:kRestartGameString otherButtonTitles: nil];
        [endGameAlertView show];
    }
    if (self.gameBoard.gameWin && self.gameBoard.firstTimeWin) {
        UIAlertView* gameWinAlertView = [[UIAlertView alloc] initWithTitle:kWinGameAlertViewTitle message:kWinGameAlertViewMessage delegate:self cancelButtonTitle:kRestartGameString otherButtonTitles:kWinGameAlertViewOtherButtonTitle, nil];
        [gameWinAlertView show];
        [self.gameBoard gameWon];
    }
}

- (void) reloadBoard{
    for (int i = 0; i < kCapacity; i++) {
        UILabel* temp = [self.cells objectAtIndex:i];
        [temp setFont:[UIFont systemFontOfSize:self.fontSize]];
        temp.text = [self.gameBoard cellAtIndexPath:i];
        
        int intValueForColor = temp.text.integerValue;
        if (intValueForColor >= kMaxColor) {
            intValueForColor /= kColorMultiplier;
        }
        [temp setBackgroundColor:[UIColor colorWithRed:intValueForColor*kCellColorRedFloatValue	 green:intValueForColor*kCellColorGreenFloatValue blue:intValueForColor*kCellColorBlueFloatValue alpha:0.5]];

        [self.cells removeObjectAtIndex:i];
        [self.cells insertObject:temp atIndex:i];
    }
    [self.gamePoints setText:[NSString stringWithFormat:@"%d",self.gameBoard.points]];
}

-(void) restartGame {
    [self.gameBoard resetData];
    [self reloadBoard];
}

//updating Constraints
-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.view removeConstraint:self.restartButtonCenterConstraint];
    [self.view removeConstraint:self.restartButtonSideConstraint];
    [self.view removeConstraint:self.pointsLabelCenterConstraint];
    [self.view removeConstraint:self.pointsLabelSideConstraint];
    [self.view removeConstraint:self.gamePointsCenterConstraint];
    [self.view removeConstraint:self.gamePointsSideConstraint];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        self.pointsLabelCenterConstraint = [NSLayoutConstraint constraintWithItem:self.pointsLabel
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:-(self.view.frame.size.width/4)];
        self.pointsLabelSideConstraint = [NSLayoutConstraint constraintWithItem:self.pointsLabel
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:kPointsLandscapeSideConstraintConstant];
        
        self.gamePointsCenterConstraint = [NSLayoutConstraint constraintWithItem:self.gamePoints
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1
                                                                         constant:(self.view.frame.size.width/4)];
        self.gamePointsSideConstraint = [NSLayoutConstraint constraintWithItem:self.gamePoints
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:kPointsLandscapeSideConstraintConstant];
        
        self.restartButtonCenterConstraint = [NSLayoutConstraint constraintWithItem:self.restartButton
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1
                                                                           constant:0];
        self.restartButtonSideConstraint = [NSLayoutConstraint constraintWithItem:self.restartButton
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1
                                                                         constant:kRestartButtonLandscapeSideConstraintConstant];
    }
    else {
        self.pointsLabelCenterConstraint = [NSLayoutConstraint constraintWithItem:self.pointsLabel
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:-(self.view.frame.size.width/4)];
        self.pointsLabelSideConstraint = [NSLayoutConstraint constraintWithItem:self.pointsLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:kPointsPortraitSideConstraintConstant];
        
        self.gamePointsCenterConstraint = [NSLayoutConstraint constraintWithItem:self.gamePoints
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:(self.view.frame.size.width/4)];
        self.gamePointsSideConstraint = [NSLayoutConstraint constraintWithItem:self.gamePoints
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:kPointsPortraitSideConstraintConstant];

        self.restartButtonCenterConstraint = [NSLayoutConstraint constraintWithItem:self.restartButton
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1
                                                                           constant:0];
        self.restartButtonSideConstraint = [NSLayoutConstraint constraintWithItem:self.restartButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:kRestartButtonPortraitSideConstraintConstant];
        

    }
    [self.view addConstraint:self.restartButtonCenterConstraint];
    [self.view addConstraint:self.restartButtonSideConstraint];
    [self.view addConstraint:self.pointsLabelCenterConstraint];
    [self.view addConstraint:self.pointsLabelSideConstraint];
    [self.view addConstraint:self.gamePointsCenterConstraint];
    [self.view addConstraint:self.gamePointsSideConstraint];
}

-(void)restartGameButton {
    UIAlertView* restartGameAlertView = [[UIAlertView alloc] initWithTitle:kRestartGameString message:kRestartGameAlertViewMessage delegate:self cancelButtonTitle:kRestartGameString otherButtonTitles:kRestartGameAlertViewOtherButtonTitle,nil];
    [restartGameAlertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:kRestartGameString]) {
        [self restartGame];
    }
}

@end
