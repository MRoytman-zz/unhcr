//
//  HCRHomeViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHomeViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCREmergencyListViewController.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"
#import "HCRCollectionCell.h"
#import "HCRTableButtonCell.h"
#import "HCRTableCell.h"
#import "HCRClusterPickerController.h"
#import "HCRCampCollectionViewController.h"
#import "HCRMessagesViewController.h"
#import "HCRBulletinViewController.h"
#import "HCRCampOverviewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kHomeViewHeaderIdentifier = @"kHomeViewHeaderIdentifier";
NSString *const kHomeViewFooterIdentifier = @"kHomeViewFooterIdentifier";

NSString *const kHomeViewDefaultCellIdentifier = @"kHomeViewDefaultCellIdentifier";
NSString *const kHomeViewSignInFieldCellIdentifier = @"kHomeViewSignInFieldCellIdentifier";
NSString *const kHomeViewSignInButtonCellIdentifier = @"kHomeViewSignInButtonCellIdentifier";
NSString *const kHomeViewBadgeCellIdentifier = @"kHomeViewBadgeCellIdentifier";
NSString *const kHomeViewGraphCellIdentifier = @"kHomeViewGraphCellIdentifier";

NSString *const kGraphCellPlaceholderLabel = @"kGraphCellPlaceholderLabel";

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMasterHeaderHeight = 120.0;

static const CGFloat kKeyboardHeight = 216; // TODO: don't hard code this shit
static const NSTimeInterval kKeyboardAnimationTime = 0.3;
static const UIViewAnimationOptions kKeyboardAnimationOptions = UIViewAnimationCurveEaseOut << 16;

////////////////////////////////////////////////////////////////////////////////

@interface HCRHomeViewController ()

@property (nonatomic) BOOL signedIn;

@property (nonatomic, readonly) BOOL signInFieldsComplete;

@property (nonatomic, weak) UITextField *emailField;
@property (nonatomic, weak) UITextField *passwordField;
@property (nonatomic, weak) HCRTableButtonCell *signInButtonCell;

@property UIView *masterHeader;
@property UIView *masterHeaderBottomLine;

@property NSMutableParagraphStyle *baseParagraphStyle;

@property NSArray *signedInLabelsArray;
@property NSArray *signedInIconsArray;

@property NSDateFormatter *dateFormatterPlain;
@property NSDateFormatter *dateFormatterTimeStamp;

@property NSArray *bookmarkedCamps;

// DEBUG ONLY //
@property (nonatomic) NSArray *messagesReceivedArray;
// DEBUG ONLY //

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHomeViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        static const CGFloat kXIndentation = 20.0;
        self.baseParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        self.baseParagraphStyle.lineHeightMultiple = 0.8;
        self.baseParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        self.baseParagraphStyle.firstLineHeadIndent = kXIndentation;
        self.baseParagraphStyle.headIndent = kXIndentation;
        
        self.signedIn = YES;
        
        self.dateFormatterPlain = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:YES];
        self.dateFormatterTimeStamp = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        
        self.signedInIconsArray = @[
                                    @[@"evilapples-icon",
                                      @"mixture-icon",
                                      @"ris-icon"],
                                    @[@"evilapples-icon",
                                      @"mixture-icon",
                                      @"ris-icon"],
                                    @[@"evilapples-icon",
                                      @"mixture-icon",
                                      @"ris-icon"]
                                    ];
        
        self.signedInLabelsArray = @[
                                     @[@"Emergencies",
                                       @"Direct Messages",
                                       @"Refugee Camps"],
                                     @[@"Domiz, Iraq",
                                       kGraphCellPlaceholderLabel,
                                       @"Bulletin Board"],
                                     @[@"Sign Out"]
                                     ];
        
        NSDictionary *countryDictionary = [[HCRDataSource globalCampDataArray] objectAtIndex:0 ofClass:@"NSDictionary"];
        NSArray *camps = [countryDictionary objectForKey:@"Camps" ofClass:@"NSArray"];
        NSDictionary *campDictionary = [camps objectAtIndex:0 ofClass:@"NSDictionary"];
        
        self.bookmarkedCamps = @[campDictionary];
                                       
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Home";
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.highlightCells = YES;
    
    self.collectionView.backgroundColor = [UIColor tableBackgroundColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(kMasterHeaderHeight, 0, 0, 0);
    
    // MASTER HEADER
    CGRect headerFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.view.bounds),
                                    kMasterHeaderHeight);
    self.masterHeader = [[UIView alloc] initWithFrame:headerFrame];
    [self.view addSubview:self.masterHeader];
    
    self.masterHeader.backgroundColor = [UIColor whiteColor];
    
    static const CGFloat kLineHeight = 0.5;
    self.masterHeaderBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.masterHeader.bounds) - kLineHeight,
                                                                      CGRectGetWidth(self.masterHeader.bounds),
                                                                      kLineHeight)];
    [self.masterHeader addSubview:self.masterHeaderBottomLine];
    
    self.masterHeaderBottomLine.backgroundColor = [UIColor tableDividerColor];
    
    static const CGFloat kTitleLabelHeight = 80.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    CGRectGetHeight(self.masterHeader.bounds) - kTitleLabelHeight,
                                                                    CGRectGetWidth(self.masterHeader.bounds),
                                                                    kTitleLabelHeight)];
    [self.masterHeader insertSubview:titleLabel belowSubview:self.masterHeaderBottomLine];
    
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 3;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:24],
                                      NSParagraphStyleAttributeName: self.baseParagraphStyle};
    
    NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:@"Refugee\nInformation\nService"
                                                                                attributes:titleAttributes];
    titleLabel.attributedText = attributedTitleString;
    
    // LAYOUT AND REUSABLES
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHomeViewHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kHomeViewFooterIdentifier];
    
    [self.collectionView registerClass:[HCRCollectionCell class]
            forCellWithReuseIdentifier:kHomeViewDefaultCellIdentifier];
    
    [self.collectionView registerClass:[HCRDataEntryFieldCell class]
            forCellWithReuseIdentifier:kHomeViewSignInFieldCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier];
    
    [self.collectionView registerClass:[HCRGraphCell class]
            forCellWithReuseIdentifier:kHomeViewGraphCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger numberOfSectionsSignedIn = self.signedInLabelsArray.count;
    NSInteger numberOfSectionsNotSignedIn = 3;
    
    return (self.signedIn) ? numberOfSectionsSignedIn : numberOfSectionsNotSignedIn;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.signedIn) {
        
        NSArray *labelsForSection = [self.signedInLabelsArray objectAtIndex:section];
        return labelsForSection.count;
        
    } else {
        
        // TODO: make dynamic match to proper sections, etc
        return (section == 1) ? 2 : 1;
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    if (self.signedIn) {
        
        NSArray *labelsForSection = [self.signedInLabelsArray objectAtIndex:indexPath.section ofClass:@"NSArray"];
        NSArray *iconsForSection = [self.signedInIconsArray objectAtIndex:indexPath.section ofClass:@"NSArray"];
        
        switch (indexPath.section) {
            case 0:
            {
                // TODO: some duplicate code below
                HCRTableCell *tableCell =
                (HCRTableCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier
                                                                          forIndexPath:indexPath];
                
                tableCell.badgeImage = [UIImage imageNamed:[iconsForSection objectAtIndex:indexPath.row ofClass:@"NSString"]];
                tableCell.title = [labelsForSection objectAtIndex:indexPath.row ofClass:@"NSString"];
                
                if (indexPath.row == 0) {
                    tableCell.highlightDetail = YES;
                    tableCell.detailNumber = @([HCRDataSource globalEmergenciesData].count);
                } else if (indexPath.row == 1) {
                    tableCell.detailNumber = @([HCRDataSource globalMessagesData].count);
                }
                
                cell = tableCell;
                break;
            }
                
            case 1:
            {
                
                switch (indexPath.row) {
                    case 0:
                    case 2:
                    {
                        // TODO: some duplicate code above
                        HCRTableCell *tableCell =
                        (HCRTableCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier
                                                                                  forIndexPath:indexPath];
                        
                        tableCell.badgeImage = [UIImage imageNamed:[iconsForSection objectAtIndex:indexPath.row ofClass:@"NSString"]];
                        tableCell.title = [labelsForSection objectAtIndex:indexPath.row ofClass:@"NSString"];
                        
                        if (indexPath.row == 0) {
                            tableCell.detailString = @"Overview";
                        }
                        
                        cell = tableCell;
                        break;
                    }
                        
                    case 1:
                    {
                        HCRGraphCell *graphCell =
                        (HCRGraphCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewGraphCellIdentifier
                                                                                  forIndexPath:indexPath];
                        
                        graphCell.graphDataSource = self;
                        graphCell.graphDelegate = self;
                        
                        graphCell.indentForContent = [HCRTableCell preferredIndentForContentWithBadgeImage];
                        
                        static const CGFloat manualAdjustment = 6.0;
                        graphCell.xGraphTrailingSpace = [HCRTableCell preferredTrailingSpaceForContent] + manualAdjustment;
                        
                        graphCell.dataLabel = @"Refugee Requests";
                        
                        cell = graphCell;
                        break;
                    }
                        
                    default:
                        NSAssert(NO, @"Unhandled collection cell row.");
                        break;
                }
                
                cell.bottomLineView.hidden = YES;
                break;
            }
                
            case 2:
            {
                HCRTableButtonCell *buttonCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier
                                                          forIndexPath:indexPath];
                
                buttonCell.tableButtonTitle = [labelsForSection objectAtIndex:indexPath.row ofClass:@"NSString"];
                
                buttonCell.processingViewPosition = HCRCollectionCellProcessingViewPositionLeft;
                
                cell = buttonCell;
                
                break;
            }
                
            default:
                NSAssert(NO, @"Unhandled collection cell section.");
                break;
        }
        
    } else {
        
        switch (indexPath.section) {
            case 0:
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewDefaultCellIdentifier
                                                                 forIndexPath:indexPath];
                [cell.contentView addSubview:[self _expandedTextViewForSignInWithFrame:cell.contentView.bounds]];
                break;
                
            case 1:
            {
                HCRDataEntryFieldCell *signInCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInFieldCellIdentifier
                                                          forIndexPath:indexPath];
                cell = signInCell;
                
                signInCell.dataDelegate = self;
                
                if (indexPath.row == ([collectionView numberOfItemsInSection:indexPath.section] - 1)) {
                    signInCell.fieldType = HCRDataEntryFieldTypePassword;
                    signInCell.lastFieldInSeries = YES;
                } else {
                    signInCell.fieldType = HCRDataEntryFieldTypeEmail;
                }
                
                
                BOOL isEmailCell = (signInCell.fieldType == HCRDataEntryFieldTypeEmail);
                signInCell.labelTitle = (isEmailCell) ? @"Email" : @"Password";
                signInCell.inputPlaceholder = (isEmailCell) ? @"name@example.com" : @"Required";
                
                if (isEmailCell) {
                    self.emailField = signInCell.inputField;
                } else {
                    self.passwordField = signInCell.inputField;
                }
                
                break;
            }
                
            case 2:
            {
                HCRTableButtonCell *buttonCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier
                                                          forIndexPath:indexPath];
                cell = buttonCell;
                
                buttonCell.tableButtonTitle = @"Sign In";
                
                buttonCell.processingViewPosition = HCRCollectionCellProcessingViewPositionLeft;
                
                self.signInButtonCell = buttonCell;
                
                break;
            }
                
            default:
                NSAssert(NO, @"Unhandled section!");
                break;
        }
        
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kHomeViewHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        if (self.signedIn && indexPath.section == 1) {
            header.titleString = @"Bookmarked Camps";
        }
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kHomeViewFooterIdentifier
                                                                          forIndexPath:indexPath];
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.signedIn) {
        
        switch (indexPath.section) {
            case 0:
            {
                
                switch (indexPath.row) {
                    case 0:
                    {
                        [self _emergenciesButtonPressed];
                        break;
                    }
                        
                    case 1:
                    {
                        [self _directMessagesButtonPressed];
                        break;
                    }
                        
                    case 2:
                    {
                        [self _campsButtonPressed];
                        break;
                    }
                        
                    default:
                        NSAssert(NO, @"Unhandled collection view row.");
                        break;
                }
                
                break;
            }
                
            case 1:
            {
                
                switch (indexPath.row) {
                    case 0:
                    {
                        [self _bookmarkedCampButtonPressed];
                        break;
                    }
                        
                    case 1:
                        // do nothing
                        break;
                        
                    case 2:
                    {
                        [self _bookmarkedBulletinBoardButtonPressed];
                        break;
                    }
                        
                    default:
                        NSAssert(NO, @"Unhandled collection view row.");
                        break;
                }
                
                break;
            }
                
            case 2:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        [self _signoutButtonPressed];
                        break;
                    }
                        
                    default:
                        NSAssert(NO, @"Unhandled collection view row.");
                        break;
                }
                
                break;
            }
                
            default:
                NSAssert(NO, @"Unhandled collection view section.");
                break;
        }
        
    } else {
        
        [self.emailField resignFirstResponder];
        [self.passwordField resignFirstResponder];
        [self _resetCollectionContentOffset];
        
        if (self.signedIn == NO &&
            indexPath.section == 2) {
            
            if (self.signInFieldsComplete) {
                [self _startSignInWithCompletion:nil];
            }
            
        }
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.signedIn) {
        
        NSArray *labelsForSection = [self.signedInLabelsArray objectAtIndex:indexPath.section ofClass:@"NSArray"];
        NSString *itemLabel = [labelsForSection objectAtIndex:indexPath.row ofClass:@"NSString"];
        BOOL isGraphCell = ([itemLabel isEqualToString:kGraphCellPlaceholderLabel]);
        
        return (isGraphCell) ? [HCRGraphCell preferredSizeForCollectionView:collectionView] : [HCRCollectionCell preferredSizeForCollectionView:collectionView];
        
    } else {
        
        if (indexPath.section == 0) {
            return [HCRCollectionCell preferredSizeForAppDescriptionCollectionCellForCollectionView:collectionView];
        } else {
            return [HCRCollectionCell preferredSizeForCollectionView:collectionView];
        }
        
    }
    
    return CGSizeZero;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize idealSizeForNotSignedInView = ([UIDevice isFourInch]) ? [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithoutTitleSmallForCollectionView:collectionView];
    
    if (self.signedIn) {
        
        if (section == 1) {
            return [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
        } else {
            return [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
        }
        
    } else {
        if (section == 0) {
            return CGSizeZero;
        } else {
            return idealSizeForNotSignedInView;
        }
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (self.signedIn) {
        BOOL lastSection = (section == self.collectionView.numberOfSections - 1);
        
        return (lastSection) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    } else {
        return [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    }
    
}

#pragma mark - SCGraphView Delegate

- (void)graphViewBeganTouchingData:(SCGraphView *)graphView withTouches:(NSSet *)touches {
    self.collectionView.scrollEnabled = NO;
}

- (void)graphViewStoppedTouchingData:(SCGraphView *)graphView {
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - SCGraphView Data Source

- (NSInteger)numberOfDataPointsInGraphView:(SCGraphView *)graphView {
    return self.messagesReceivedArray.count;
}

- (CGFloat)graphViewMinYValue:(SCGraphView *)graphView {
    return 0;
}

- (CGFloat)graphViewMaxYValue:(SCGraphView *)graphView {
    
    // http://stackoverflow.com/questions/3080540/finding-maximum-numeric-value-in-nsarray
    NSNumber *largestNumber = [self.messagesReceivedArray valueForKeyPath:@"@max.intValue"];
    CGFloat maxNumberWithPadding = largestNumber.floatValue * 1.1;
    
    return maxNumberWithPadding;
}

- (NSNumber *)graphView:(SCGraphView *)graphView dataPointForIndex:(NSInteger)index {
    
    return [self.messagesReceivedArray objectAtIndex:index];
    
}

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index withTimeStamp:(BOOL)showTimeStamp {
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((self.messagesReceivedArray.count - (index + 1)) * 60 * 60 * 24) / 4.0;
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];
    
    NSDateFormatter *formatter = (showTimeStamp) ? self.dateFormatterTimeStamp : self.dateFormatterPlain;
    NSString *dateString = [formatter stringFromDate:targetDate];
    
    return dateString;
}

#pragma mark - HCRDataEntryFieldCell Delegate

- (void)dataEntryFieldCellDidBecomeFirstResponder:(HCRDataEntryFieldCell *)signInCell {
    
    CGFloat bottomOfHeader = CGRectGetMaxY(self.masterHeader.frame);
    CGFloat contentSpace = CGRectGetHeight(self.view.bounds) - kKeyboardHeight - bottomOfHeader;
    CGFloat contentOffset = 0.5 * contentSpace;
    CGFloat targetCenter = bottomOfHeader + contentOffset;
    
    CGFloat targetSlide = signInCell.center.y - targetCenter;
    
    [UIView animateWithDuration:kKeyboardAnimationTime
                          delay:0.0
                        options:kKeyboardAnimationOptions
                     animations:^{
                         
                         self.collectionView.contentOffset = CGPointMake(0, targetSlide);
                         
                     } completion:nil];
    
}

- (void)dataEntryFieldCellDidPressDone:(HCRDataEntryFieldCell *)signInCell {
    
    if (signInCell.fieldType == HCRDataEntryFieldTypeEmail) {
        
        [self.passwordField becomeFirstResponder];
        
    } else if (signInCell.fieldType == HCRDataEntryFieldTypePassword) {
        
        if (self.signInFieldsComplete) {
            [self _startSignInWithCompletion:nil];
        }
        
        [self.passwordField resignFirstResponder];
        
        [self _resetCollectionContentOffset];
    }
    
}

#pragma mark - Getters & Setters

- (void)setSignedIn:(BOOL)signedIn {
    _signedIn = signedIn;
    
    self.masterHeaderBottomLine.hidden = !signedIn;
    
}

- (NSArray *)messagesReceivedArray {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDaysToShow = 7;
    static const NSInteger kNumberOfDataPoints = kNumberOfDaysToShow * 4.0;
    static const CGFloat kDataPointBaseline = 50.0;
    static const CGFloat kDataPointRange = 50.0;
    static const CGFloat kDataPointIncrement = 6.0;
    
    if ( ! _messagesReceivedArray ) {
        
        NSMutableArray *randomMessagesArray = @[].mutableCopy;
        
        for (NSInteger i = 0; i < kNumberOfDataPoints; i++) {
            CGFloat nextValue = kDataPointBaseline + (i * kDataPointIncrement) + arc4random_uniform(kDataPointRange);
            [randomMessagesArray addObject:@(nextValue)];
        }
        
        _messagesReceivedArray = randomMessagesArray;
    }
    
    return _messagesReceivedArray;
    
}

- (BOOL)signInFieldsComplete {
    return(self.emailField.text.length > 0 && self.passwordField.text.length > 0);
}

#pragma mark - Private Methods (Buttons)

- (void)_emergenciesButtonPressed {
    HCREmergencyListViewController *alertsController = [[HCREmergencyListViewController alloc] initWithCollectionViewLayout:[HCREmergencyListViewController preferredLayout]];
    
    [self _pushViewController:alertsController];
}

- (void)_directMessagesButtonPressed {
    
    HCRMessagesViewController *messagesController = [[HCRMessagesViewController alloc] initWithCollectionViewLayout:[HCRMessagesViewController preferredLayout]];
    
    [self _pushViewController:messagesController];
}

- (void)_campsButtonPressed {
    
    HCRCampCollectionViewController *campPicker = [[HCRCampCollectionViewController alloc] initWithCollectionViewLayout:[HCRCampCollectionViewController preferredLayout]];
    
    [self _pushViewController:campPicker];
}

- (void)_bookmarkedCampButtonPressed {
    
//    HCRClusterCollectionController *campDetail = [[HCRClusterCollectionController alloc] initWithCollectionViewLayout:[HCRClusterCollectionController preferredLayout]];
//    
//    campDetail.countryName = @"Iraq";
//    campDetail.campDictionary = [self.bookmarkedCamps objectAtIndex:0 ofClass:@"NSDictionary"];
//
//    [self _pushViewController:campDetail];
    
    HCRCampOverviewController *campOverview = [[HCRCampOverviewController alloc] initWithCollectionViewLayout:[HCRCampOverviewController preferredLayout]];
    
    NSDictionary *campDictionary = [self.bookmarkedCamps objectAtIndex:0 ofClass:@"NSDictionary"];
    campOverview.campName = [campDictionary objectForKey:@"Name" ofClass:@"NSString"];
    
    [self _pushViewController:campOverview];
    
}

- (void)_bookmarkedBulletinBoardButtonPressed {
    HCRBulletinViewController *bulletinController = [[HCRBulletinViewController alloc] initWithCollectionViewLayout:[HCRBulletinViewController preferredLayout]];
    
    [self _pushViewController:bulletinController];
}

//- (void)_aboutButtonPressed {
//    // TODO: about button
//}
//
//- (void)_settingsButtonPressed {
//    // TODO: options button
//}

- (void)_signoutButtonPressed {
    
    self.signedIn = NO;
    
    [self _reloadSectionsAnimated];
    
}

#pragma mark - Private Methods

- (void)_startSignInWithCompletion:(void (^)(BOOL success))completionBlock {
    
    self.collectionView.scrollEnabled = NO;
    self.signInButtonCell.processingAction = YES;
    self.signInButtonCell.tableButton.enabled = NO;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        self.signedIn = YES;
        
        [self _reloadSectionsAnimated];
        
        self.collectionView.scrollEnabled = YES;
        self.signInButtonCell.processingAction = NO;
        self.signInButtonCell.tableButton.enabled = YES;
        
        if (completionBlock) {
            completionBlock(YES);
        }
        
    });
    
}

- (UIView *)_expandedTextViewForSignInWithFrame:(CGRect)frame {
    
    UIView *expandedTextView = [[UIView alloc] initWithFrame:frame];
    expandedTextView.backgroundColor = [UIColor whiteColor];
    
    // subtitle label
    CGRect subtitleLabelFrame = CGRectMake(CGRectGetMinX(expandedTextView.bounds),
                                           CGRectGetMinY(expandedTextView.bounds),
                                           CGRectGetWidth(expandedTextView.bounds),
                                           44); // looks good
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:subtitleLabelFrame];
    [expandedTextView addSubview:subtitleLabel];
    
    subtitleLabel.backgroundColor = [UIColor whiteColor];
    subtitleLabel.numberOfLines = 2;
    
    NSDictionary *subtitleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18],
                                         NSParagraphStyleAttributeName: self.baseParagraphStyle};
    
    NSAttributedString *attributedSubtitleString = [[NSAttributedString alloc] initWithString:@"Camp Services App\nfor Humanitarian Aid Providers"
                                                                                   attributes:subtitleAttributes];
    
    subtitleLabel.attributedText = attributedSubtitleString;
    
    // body label
    static const CGFloat kFakeIndent = 20.0;
    CGRect bodyLabelFrame = CGRectMake(CGRectGetMinX(expandedTextView.bounds) + kFakeIndent,
                                       CGRectGetMaxY(subtitleLabel.frame) + 4,
                                       CGRectGetWidth(expandedTextView.bounds) - 2 * kFakeIndent,
                                       154); // looks good
    UILabel *bodyLabel = [[UILabel alloc] initWithFrame:bodyLabelFrame];
    [expandedTextView addSubview:bodyLabel];
    
    bodyLabel.backgroundColor = [UIColor whiteColor];
    
    bodyLabel.numberOfLines = 0;
    
    NSMutableParagraphStyle *bodyParagraph = self.baseParagraphStyle.mutableCopy;
    bodyParagraph.lineHeightMultiple = 1.05;
    bodyParagraph.firstLineHeadIndent = 0.0;
    bodyParagraph.headIndent = 0.0;
    
    NSDictionary *bodyAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12],
                                     NSParagraphStyleAttributeName: bodyParagraph};
    
    NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]};
    
    NSMutableAttributedString *attributedBodyString = [[NSMutableAttributedString alloc] initWithString:@"The Camp Services App system allows Humanitarian Aid Providers to view realtime and aggregated Refugee request information directly on their mobile phones, as well as view contact information for all camp-affiliated NGO and UN actors working in the camp to better coordinate and maximize the impact of any intervention. Centralizing this information opens up a new level of cross-Cluster collaboration and maximizes the effect of all interventions throughout the camp."
                                                                                             attributes:bodyAttributes];
    
    [attributedBodyString setAttributes:boldAttributes range:NSMakeRange(3, 18)];
    
    bodyLabel.attributedText = attributedBodyString;
    
    return expandedTextView;
    
}

- (void)_resetCollectionContentOffset {
    
    [UIView animateWithDuration:kKeyboardAnimationTime
                          delay:0.0
                        options:kKeyboardAnimationOptions
                     animations:^{
                         
                         self.collectionView.contentOffset = CGPointMake(0, -1 * kMasterHeaderHeight);
                         
                     } completion:nil];
    
}

- (void)_reloadSectionsAnimated {
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
    } completion:^(BOOL finished) {
        //
    }];
    
}

- (void)_pushViewController:(UIViewController *)controller {
    
    [self.navigationController pushViewController:controller animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

@end
