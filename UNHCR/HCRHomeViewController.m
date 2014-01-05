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
#import "EASoundManager.h"

#import <Parse/Parse.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kHomeViewHeaderIdentifier = @"kHomeViewHeaderIdentifier";
NSString *const kHomeViewFooterIdentifier = @"kHomeViewFooterIdentifier";

NSString *const kHomeViewDefaultCellIdentifier = @"kHomeViewDefaultCellIdentifier";
NSString *const kHomeViewSignInFieldCellIdentifier = @"kHomeViewSignInFieldCellIdentifier";
NSString *const kHomeViewSignInButtonCellIdentifier = @"kHomeViewSignInButtonCellIdentifier";
NSString *const kHomeViewBadgeCellIdentifier = @"kHomeViewBadgeCellIdentifier";
NSString *const kHomeViewGraphCellIdentifier = @"kHomeViewGraphCellIdentifier";

NSString *const kLayoutCellLabelKey = @"kLayoutCellLabelKey";
NSString *const kLayoutCellIconKey = @"kLayoutCellIconKey";

NSString *const kLayoutCellLabelEmergencies = @"Emergencies";
NSString *const kLayoutCellLabelAlerts = @"Alerts";
NSString *const kLayoutCellLabelMessages = @"Messages";
NSString *const kLayoutCellLabelCamps = @"Refugee Camps";
NSString *const kLayoutCellLabelDomiz = @"Domiz, Iraq";
NSString *const kLayoutCellLabelBulletin = @"Bulletin Board";
NSString *const kLayoutCellLabelSignOut = @"Sign Out";
NSString *const kLayoutCellLabelSurveys = @"Surveys";
NSString *const kLayoutCellLabelDirectory = @"Directory";
NSString *const kLayoutCellLabelGraph = @"kLayoutCellLabelGraph";

NSString *const kLayoutSignedOutCellBody = @"kLayoutSignedOutCellBody";
NSString *const kLayoutSignedOutCellEmail = @"Email";
NSString *const kLayoutSignedOutCellPassword = @"Password";
NSString *const kLayoutSignedOutCellLogIn = @"Log In";
NSString *const kLayoutSignedOutCellSignUp = @"Create New Account";
NSString *const kLayoutSignedOutCellForgot = @"Forgot Password";

NSString *const kLayoutCellIconNone = @"kLayoutCellIconNone";

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMasterHeaderHeight = 120.0;

static const CGFloat kKeyboardHeight = 216; // TODO: don't hard code this shit
static const NSTimeInterval kKeyboardAnimationTime = 0.3;
static const UIViewAnimationOptions kKeyboardAnimationOptions = UIViewAnimationCurveEaseOut << 16;

////////////////////////////////////////////////////////////////////////////////

@interface HCRHomeViewController ()

@property (nonatomic, readonly) BOOL signedIn;

@property (nonatomic, readonly) BOOL signInFieldsComplete;

@property (nonatomic, weak) HCRDataEntryFieldCell *emailCell;
@property (nonatomic, weak) HCRDataEntryFieldCell *passwordCell;
@property (nonatomic, weak) HCRTableButtonCell *signInButtonCell;
@property (nonatomic, weak) HCRTableButtonCell *createNewUserButtonCell;
@property (nonatomic, weak) HCRTableButtonCell *forgotPasswordButtonCell;

@property UIView *masterHeader;
@property UIView *masterHeaderBottomLine;

@property NSMutableParagraphStyle *baseParagraphStyle;

@property NSArray *layoutDataArray;
@property NSArray *layoutDataArraySignedOut;

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
        
        self.dateFormatterPlain = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:YES];
        self.dateFormatterTimeStamp = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        
#ifdef TARGET_RIS
        self.layoutDataArray = @[
                                     @[
                                         @{kLayoutCellLabelKey: kLayoutCellLabelEmergencies,
                                           kLayoutCellIconKey: @"emergency"},
                                         @{kLayoutCellLabelKey: kLayoutCellLabelMessages,
                                           kLayoutCellIconKey: @"message"},
                                         @{kLayoutCellLabelKey: kLayoutCellLabelCamps,
                                           kLayoutCellIconKey: @"camp"}

                                         ],
                                     @[
                                         @{kLayoutCellLabelKey: kLayoutCellLabelDomiz,
                                           kLayoutCellIconKey: @"bookmark"},
                                         @{kLayoutCellLabelKey: kLayoutCellLabelGraph,
                                           kLayoutCellIconKey: kLayoutCellIconNone},
                                         @{kLayoutCellLabelKey: kLayoutCellLabelBulletin,
                                           kLayoutCellIconKey: @"bulletin"}
                                         ],
                                     @[
                                         @{kLayoutCellLabelKey: kLayoutCellLabelSignOut,
                                           kLayoutCellIconKey: kLayoutCellIconNone}
                                         ]
                                     ];
        
#elif defined(TARGET_MSF)
        self.layoutDataArray = @[
                                 @[
                                     @{kLayoutCellLabelKey: kLayoutCellLabelSurveys,
                                       kLayoutCellIconKey: @"bulletin"}
                                     ],
                                 @[
                                     @{kLayoutCellLabelKey: kLayoutCellLabelAlerts,
                                       kLayoutCellIconKey: @"emergency"},
                                     @{kLayoutCellLabelKey: kLayoutCellLabelMessages,
                                       kLayoutCellIconKey: @"message"},
                                     @{kLayoutCellLabelKey: kLayoutCellLabelDirectory,
                                       kLayoutCellIconKey: @"camp"},
                                     ],
                                 @[
                                     @{kLayoutCellLabelKey: kLayoutCellLabelSignOut,
                                       kLayoutCellIconKey: kLayoutCellIconNone}
                                     ]
                                 ];
#endif
        
        // applies to all targets
        self.layoutDataArraySignedOut = @[
                                          @[
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellBody}
                                              ],
                                          @[
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellEmail},
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellPassword},
                                              ],
                                          @[
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellLogIn}
                                              ],
                                          @[
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellSignUp},
                                              @{kLayoutCellLabelKey: kLayoutSignedOutCellForgot}
                                              ]
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
    self.masterHeaderBottomLine.hidden = !self.signedIn;
    
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
    
    NSString *titleString;
#ifdef TARGET_RIS
    titleString = @"Refugee\nInformation\nService";
#elif defined(TARGET_MSF)
    titleString = @"Médecins\nSans Frontières\nField Survey Tool";
#endif
    
    NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:titleString
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
    
    return (self.signedIn) ? self.layoutDataArray.count : self.layoutDataArraySignedOut.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *sectionDataArrays = [[self _layoutArray] objectAtIndex:section ofClass:@"NSArray"];
    return sectionDataArrays.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    UIImage *cellIcon = [self _layoutIconForIndexPath:indexPath];
    cellIcon = [cellIcon colorImage:[UIColor whiteColor]
                      withBlendMode:kCGBlendModeNormal
                   withTransparency:YES];
    
    if (self.signedIn) {
        
        if ([cellTitle isEqualToString:kLayoutCellLabelSurveys] ||
            [cellTitle isEqualToString:kLayoutCellLabelMessages] ||
            [cellTitle isEqualToString:kLayoutCellLabelEmergencies] ||
            [cellTitle isEqualToString:kLayoutCellLabelAlerts] ||
            [cellTitle isEqualToString:kLayoutCellLabelCamps] ||
            [cellTitle isEqualToString:kLayoutCellLabelDirectory] ||
            [cellTitle isEqualToString:kLayoutCellLabelDomiz] ||
            [cellTitle isEqualToString:kLayoutCellLabelBulletin]) {
            
            // TODO: some duplicate code below
            HCRTableCell *tableCell =
            (HCRTableCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier
                                                                      forIndexPath:indexPath];
            
            tableCell.badgeImage = cellIcon;
            tableCell.title = cellTitle;
            
            if ([cellTitle isEqualToString:kLayoutCellLabelSurveys] ||
                [cellTitle isEqualToString:kLayoutCellLabelBulletin]) {
                
                tableCell.badgeImageView.backgroundColor = [UIColor colorWithRed:193 / 255.0
                                                                           green:145 / 255.0
                                                                            blue:74 / 255.0
                                                                           alpha:1.0];
                
            } else if ([cellTitle isEqualToString:kLayoutCellLabelEmergencies] ||
                       [cellTitle isEqualToString:kLayoutCellLabelAlerts]) {
                tableCell.highlightDetail = YES;
                tableCell.detailNumber = @([HCRDataSource globalEmergenciesData].count);
                tableCell.badgeImageView.backgroundColor = [UIColor colorWithRed:79 / 255.0
                                                                           green:79 / 255.0
                                                                            blue:79 / 255.0
                                                                           alpha:1.0];
            } else if ([cellTitle isEqualToString:kLayoutCellLabelDomiz]) {
                // TODO: prototype only - in prod need to read this dynamically
                tableCell.detailString = @"Overview";
                tableCell.badgeImageView.backgroundColor = [UIColor UNHCRBlue];
            } else if ([cellTitle isEqualToString:kLayoutCellLabelMessages]) {
                tableCell.detailNumber = @([HCRDataSource globalMessagesData].count);
                tableCell.badgeImageView.backgroundColor = [UIColor colorWithRed:104 / 255.0
                                                                           green:188 / 255.0
                                                                            blue:29 / 255.0
                                                                           alpha:1.0];
            } else if ([cellTitle isEqualToString:kLayoutCellLabelCamps] ||
                       [cellTitle isEqualToString:kLayoutCellLabelDirectory]) {
                tableCell.badgeImageView.backgroundColor = [UIColor UNHCRBlue];
            }
            
            cell = tableCell;
            
        } else if ([cellTitle isEqualToString:kLayoutCellLabelSignOut]) {
            
            HCRTableButtonCell *buttonCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier
                                                      forIndexPath:indexPath];
            
            buttonCell.tableButtonTitle = cellTitle;
            
            buttonCell.processingViewPosition = HCRCollectionCellProcessingViewPositionLeft;
            
            cell = buttonCell;
            
        } else if ([cellTitle isEqualToString:kLayoutCellLabelGraph]) {
            
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
            
            cell.bottomLineView.hidden = YES;
            
        } else {
            NSAssert(NO, @"Unhandled collection cell section.");
        }
        
    } else {
        
        // NOT SIGNED IN
        
        if ([cellTitle isEqualToString:kLayoutSignedOutCellBody]) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewDefaultCellIdentifier
                                                             forIndexPath:indexPath];
            [cell.contentView addSubview:[self _expandedTextViewForSignInWithFrame:cell.contentView.bounds]];
        } else if ([cellTitle isEqualToString:kLayoutSignedOutCellEmail] ||
                   [cellTitle isEqualToString:kLayoutSignedOutCellPassword]) {
            
            HCRDataEntryFieldCell *signInCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInFieldCellIdentifier
                                                      forIndexPath:indexPath];
            cell = signInCell;
            
            signInCell.dataDelegate = self;
            
            if (indexPath.row == ([collectionView numberOfItemsInSection:indexPath.section] - 1)) {
                signInCell.lastFieldInSeries = YES;
            }
            
            if ([cellTitle isEqualToString:kLayoutSignedOutCellPassword]) {
                signInCell.fieldType = HCRDataEntryFieldTypePassword;
            } else if ([cellTitle isEqualToString:kLayoutSignedOutCellEmail]) {
                signInCell.fieldType = HCRDataEntryFieldTypeEmail;
            }
            
            signInCell.labelTitle = cellTitle;
            
            BOOL isEmailCell = (signInCell.fieldType == HCRDataEntryFieldTypeEmail);
            signInCell.inputPlaceholder = (isEmailCell) ? @"name@example.com" : @"Required";
            
            if (isEmailCell) {
                self.emailCell = signInCell;
            } else {
                self.passwordCell = signInCell;
            }
            
        } else if ([cellTitle isEqualToString:kLayoutSignedOutCellLogIn] ||
                   [cellTitle isEqualToString:kLayoutSignedOutCellSignUp] ||
                   [cellTitle isEqualToString:kLayoutSignedOutCellForgot]) {
            
            HCRTableButtonCell *buttonCell =
            [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier
                                                      forIndexPath:indexPath];
            cell = buttonCell;
            
            buttonCell.tableButtonTitle = cellTitle;
            buttonCell.processingViewPosition = HCRCollectionCellProcessingViewPositionLeft;
            
            if ([cellTitle isEqualToString:kLayoutSignedOutCellLogIn]) {
                self.signInButtonCell = buttonCell;
            } else if ([cellTitle isEqualToString:kLayoutSignedOutCellSignUp]) {
                self.createNewUserButtonCell = buttonCell;
            } else if ([cellTitle isEqualToString:kLayoutSignedOutCellForgot]) {
                self.forgotPasswordButtonCell = buttonCell;
            }
            
        } else {
            NSAssert(NO, @"Unhandled section!");
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
#ifdef TARGET_RIS
        if (self.signedIn && indexPath.section == 1) {
            header.titleString = @"Bookmarked Camps";
        }
#endif
        
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
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    if (self.signedIn) {
        
        if ([cellTitle isEqualToString:kLayoutCellLabelEmergencies] ||
            [cellTitle isEqualToString:kLayoutCellLabelAlerts]) {
            [self _emergenciesButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelMessages]) {
            [self _directMessagesButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelCamps]) {
            [self _campsButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelDomiz]) {
            [self _bookmarkedCampButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelBulletin]) {
            [self _bookmarkedBulletinBoardButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelSignOut]) {
            [self _signoutButtonPressed];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelDirectory]) {
            [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDNotice];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelSurveys]) {
            [self _surveyButtonPressed];
        }
        
    } else {
        
        [self.emailCell.inputField resignFirstResponder];
        [self.passwordCell.inputField resignFirstResponder];
//        [self _resetCollectionContentOffset];
        
        void (^shakeCellTitle)(HCRDataEntryFieldCell *) = ^(HCRDataEntryFieldCell *cell){
            
            UIColor *backgroundColor = cell.titleLabel.backgroundColor;
            cell.titleLabel.backgroundColor = [UIColor clearColor];
            [cell.titleLabel shakeWithCompletion:^(BOOL finished) {
                cell.titleLabel.backgroundColor = backgroundColor;
            }];
        };
        
        if ([cellTitle isEqualToString:kLayoutSignedOutCellLogIn] ||
            [cellTitle isEqualToString:kLayoutSignedOutCellSignUp]) {
            
            if (self.signInFieldsComplete) {
                
                if ([cellTitle isEqualToString:kLayoutSignedOutCellLogIn]) {
                    [self _simpleSignIn];
                } else if ([cellTitle isEqualToString:kLayoutSignedOutCellSignUp]) {
                    [self _simpleSignUp];
                }
                
            } else {
                
                if ([self _emailFieldComplete] == NO) {
                    shakeCellTitle(self.emailCell);
                }
                
                if ([self _passwordFieldComplete] == NO) {
                    shakeCellTitle(self.passwordCell);
                }
                
            }
            
        } else if ([cellTitle isEqualToString:kLayoutSignedOutCellForgot]) {
            
            if ([self _emailFieldComplete]) {
                shakeCellTitle(self.emailCell);
            } else {
                // TODO: query for user, if exists, handle, if not, handle that
            }
            
        }
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.signedIn) {
        
        NSString *itemLabel = [self _layoutLabelForIndexPath:indexPath];
        BOOL isGraphCell = ([itemLabel isEqualToString:kLayoutCellLabelGraph]);
        
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
        
#ifdef TARGET_RIS
        if (section == 1) {
            return [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
        } else {
            return [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
        }
#elif defined(TARGET_MSF)
        return [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
#endif
        
    } else {
        if (section == 0) {
            return CGSizeZero;
        } else {
            return idealSizeForNotSignedInView;
        }
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    BOOL lastSection = (section == self.collectionView.numberOfSections - 1);
    return (lastSection) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    
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
        
        [self.passwordCell.inputField becomeFirstResponder];
        
    } else if (signInCell.fieldType == HCRDataEntryFieldTypePassword) {
        
        [self.passwordCell.inputField resignFirstResponder];
        
        [self _resetCollectionContentOffset];
    }
    
}

#pragma mark - Getters & Setters

- (BOOL)signedIn {
    return ([PFUser currentUser] != nil);
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
    return ([self _emailFieldComplete] &&
            [self _passwordFieldComplete]);
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

- (void)_signoutButtonPressed {
    
    [PFUser logOut];

    [self _reloadSectionsAnimated];
    
}

- (void)_surveyButtonPressed {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Question"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDNotice];
        
        if (objects) {
            
            HCRDebug(@"Question objects found: %d",objects.count);
            
        } else {
            
            if (error) {
                
                HCRError(@"Error retrieving objects! %@",error.description);
                
            } else {
                
                HCRDebug(@"No objects found.");
                
            }
            
        }
        
    }];
    
}

#pragma mark - Private Methods

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
    
    NSString *subtitleString;
#ifdef TARGET_RIS
    subtitleString = @"Camp Services App\nfor Humanitarian Aid Providers";
#elif defined(TARGET_MSF)
    subtitleString = @"Mobile Data Collection\nby Humanitarian Mobile Solutions";
#endif
    
    NSAttributedString *attributedSubtitleString = [[NSAttributedString alloc] initWithString:subtitleString
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
    
    NSString *bodyString;
#ifdef TARGET_RIS
    bodyString = @"The Camp Services App system allows Humanitarian Aid Providers to view realtime and aggregated Refugee request information directly on their mobile phones, as well as view contact information for all camp-affiliated NGO and UN actors working in the camp to better coordinate and maximize the impact of any intervention. Centralizing this information opens up a new level of cross-Cluster collaboration and maximizes the effect of all interventions throughout the camp.";
#elif defined(TARGET_MSF)
    bodyString = @"The Field Survey Tool enables field staff to record survey results directly in digital form on their mobile device. Entered results are uploaded to a central database - either immedaitely or as soon as a data connection is available. Authorized users may then review the data in real-time as it enters the system.\n\nFor more information, or to request survey data access, contact Humanitarian Mobile Solutions at: help@hms.io";
#endif
    
    NSMutableAttributedString *attributedBodyString = [[NSMutableAttributedString alloc] initWithString:bodyString
                                                                                             attributes:bodyAttributes];
    
#ifdef TARGET_RIS
    [attributedBodyString setAttributes:boldAttributes range:[bodyString rangeOfString:@"Camp Services App"]];
#elif defined(TARGET_MSF)
    [attributedBodyString setAttributes:boldAttributes range:[bodyString rangeOfString:@"Field Survey Tool"]];
    [attributedBodyString setAttributes:boldAttributes range:[bodyString rangeOfString:@"help@hms.io"]];
#endif
    
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
    
    self.masterHeaderBottomLine.hidden = !self.signedIn;
    
    [self.collectionView reloadData];
    
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

- (NSArray *)_layoutArray {
    return (self.signedIn) ? self.layoutDataArray : self.layoutDataArraySignedOut;
}

- (NSArray *)_layoutDataForSection:(NSInteger)section {
    NSArray *sectionData = [[self _layoutArray] objectAtIndex:section ofClass:@"NSArray"];
    return sectionData;
}

- (NSString *)_layoutLabelForIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = [self _layoutDataForSection:indexPath.section];
    NSDictionary *dataForIndexPath = [sectionData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    NSString *string = [dataForIndexPath objectForKey:kLayoutCellLabelKey ofClass:@"NSString"];
    return string;
}

- (UIImage *)_layoutIconForIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = [self _layoutDataForSection:indexPath.section];
    NSDictionary *dataForIndexPath = [sectionData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    NSString *imagePath = [dataForIndexPath objectForKey:kLayoutCellIconKey ofClass:@"NSString" mustExist:NO];
    
    if (imagePath) {
        UIImage *image = [UIImage imageNamed:imagePath];
        return image;
    } else {
        return nil;
    }
}

- (void)_startSignInWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL success))completionBlock {
    
    self.collectionView.scrollEnabled = NO;
    self.signInButtonCell.processingAction = YES;
    
    [self _setLoginButtonsEnabled:NO];
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        
        self.collectionView.scrollEnabled = YES;
        self.signInButtonCell.processingAction = NO;
        
        [self _setLoginButtonsEnabled:YES];
        
        if (error) {
            
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse];
            
        }
        
        if (completionBlock) {
            completionBlock(!error);
        }
    }];
    
}


- (void)_createNewUserWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL success))completionBlock {
    
    self.collectionView.scrollEnabled = NO;
    
    self.createNewUserButtonCell.processingAction = YES;
    
    [self _setLoginButtonsEnabled:NO];
    
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = username;
    
    newUser[@"authorized"] = @NO;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.collectionView.scrollEnabled = YES;
        self.createNewUserButtonCell.processingAction = NO;
        
        [self _setLoginButtonsEnabled:YES];
        
        if (error) {
            HCRError(@"Error creating user! %@",error.description);
            if (error.code == 202) {
                [UIAlertView showWithTitle:@"Account Already Exists"
                                   message:@"The email address you entered already exists. Please try again with a different email address, or, if you've forgotten your password, scroll down and tap \"Forgot Password\"."
                                   handler:nil];
            }
        }
        
        if (completionBlock) {
            completionBlock(succeeded);
        }
    }];
    
}

- (void)_setLoginButtonsEnabled:(BOOL)enabled {
    self.signInButtonCell.tableButton.enabled = enabled;
    self.createNewUserButtonCell.tableButton.enabled = enabled;
    self.forgotPasswordButtonCell.tableButton.enabled = enabled;
}

- (void)_simpleSignIn {
    
    [self _startSignInWithUsername:self.emailCell.inputField.text
                      withPassword:self.passwordCell.inputField.text
                    withCompletion:^(BOOL success) {
                        if (success) {
                            [self _reloadSectionsAnimated];
                            self.emailCell.inputField.text = nil;
                            self.passwordCell.inputField.text = nil;
                        }
                    }];
    
}

- (void)_simpleSignUp {
    
    [self _createNewUserWithUsername:self.emailCell.inputField.text
                        withPassword:self.passwordCell.inputField.text
                      withCompletion:^(BOOL success) {
                          
                          if (success) {
                              [self _reloadSectionsAnimated];
                              self.emailCell.inputField.text = nil;
                              self.passwordCell.inputField.text = nil;
                          }
                          
                          // TODO: handle this - create the user but set a flag at "not authorized"
                          // some where: check for 'authorized' flag - if exists, OK, if not, don't let 'em in
                          // also handle whether user is already created with that email address - if so, just invoke 'forgot password' and email it to them
                      }];
    
}

- (BOOL)_emailFieldComplete {
    // cell must have text and it must contain a period and an @
    return ([self.emailCell.inputField.text rangeOfString:@"."].location != NSNotFound &&
            [self.emailCell.inputField.text rangeOfString:@"@"].location != NSNotFound);
}

- (BOOL)_passwordFieldComplete {
    return (self.passwordCell.inputField.text.length > 0);
}

@end
