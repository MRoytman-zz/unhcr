//
//  HCRHomeViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHomeViewController.h"
#import "HCRCountryCollectionViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRHomeLoginMenuScrollView.h"
#import "HCRAlertsViewController.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"
#import "HCRCollectionCell.h"
#import "HCRTableButtonCell.h"
#import "HCRTableCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kHomeViewHeaderIdentifier = @"kHomeViewHeaderIdentifier";
NSString *const kHomeViewFooterIdentifier = @"kHomeViewFooterIdentifier";

NSString *const kHomeViewDefaultCellIdentifier = @"kHomeViewDefaultCellIdentifier";
NSString *const kHomeViewSignInFieldCellIdentifier = @"kHomeViewSignInFieldCellIdentifier";
NSString *const kHomeViewSignInButtonCellIdentifier = @"kHomeViewSignInButtonCellIdentifier";
NSString *const kHomeViewBadgeCellIdentifier = @"kHomeViewBadgeCellIdentifier";
NSString *const kHomeViewButtonGraphCellIdentifier = @"kHomeViewButtonGraphCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMasterHeaderHeight = 120.0;

static const CGFloat kKeyboardHeight = 216; // TODO: don't hard code this shit
static const NSTimeInterval kKeyboardAnimationTime = 0.3;
static const UIViewAnimationOptions kKeyboardAnimationOptions = UIViewAnimationCurveEaseOut << 16;

////////////////////////////////////////////////////////////////////////////////

@interface HCRHomeViewController ()

@property BOOL signedIn;

@property (nonatomic, readonly) BOOL signInFieldsComplete;

@property (nonatomic, weak) UITextField *emailField;
@property (nonatomic, weak) UITextField *passwordField;
@property (nonatomic, weak) HCRTableButtonCell *signInButtonCell;

@property UIView *masterHeader;

@property HCRHomeLoginMenuScrollView *scrollView;
@property NSMutableParagraphStyle *baseParagraphStyle;

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
    
    // add static title section
    CGRect headerFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.view.bounds),
                                    kMasterHeaderHeight);
    self.masterHeader = [[UIView alloc] initWithFrame:headerFrame];
    [self.view addSubview:self.masterHeader];
    
    self.masterHeader.backgroundColor = [UIColor whiteColor];
    
    static const CGFloat kTitleLabelHeight = 80.0;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    CGRectGetHeight(self.masterHeader.bounds) - kTitleLabelHeight,
                                                                    CGRectGetWidth(self.masterHeader.bounds),
                                                                    kTitleLabelHeight)];
    [self.masterHeader addSubview:titleLabel];
    
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 3;
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:24],
                                      NSParagraphStyleAttributeName: self.baseParagraphStyle};
    
    NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:@"Refugee\nInformation\nService"
                                                                                attributes:titleAttributes];
    titleLabel.attributedText = attributedTitleString;
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHomeViewHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kHomeViewFooterIdentifier];
    
    [self.collectionView registerClass:[HCRCollectionCell class]
            forCellWithReuseIdentifier:kHomeViewDefaultCellIdentifier];
    
    [self.collectionView registerClass:[HCRSignInFieldCell class]
            forCellWithReuseIdentifier:kHomeViewSignInFieldCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kHomeViewSignInButtonCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier];
    
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
    
    NSInteger numberOfSectionsSignedIn = 3;
    NSInteger numberOfSectionsNotSignedIn = 3;
    
    return (self.signedIn) ? numberOfSectionsSignedIn : numberOfSectionsNotSignedIn;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.signedIn) {
        
        if (section == 1) { // TODO: make dynamic match to bookmarked section
            return 3; // TODO: make dynamic based on # of bookmarks
        } else {
            return 3;
        }
        
    } else {
        
        // TODO: make dynamic match to proper sections, etc
        return (section == 1) ? 2 : 1;
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    if (self.signedIn) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewBadgeCellIdentifier
                                                         forIndexPath:indexPath];
        
    } else {
        
        switch (indexPath.section) {
            case 0:
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewDefaultCellIdentifier
                                                                 forIndexPath:indexPath];
                [cell.contentView addSubview:[self _expandedTextViewForSignInWithFrame:cell.contentView.bounds]];
                break;
                
            case 1:
            {
                HCRSignInFieldCell *signInCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:kHomeViewSignInFieldCellIdentifier
                                                          forIndexPath:indexPath];
                cell = signInCell;
                
                signInCell.signInDelegate = self;
                signInCell.fieldType = indexPath.row;
                
                BOOL isEmailCell = (signInCell.fieldType == HCRSignInFieldTypeEmail);
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
    
    if (self.signedIn == NO &&
        indexPath.section == 2) {
        
        if (self.signInFieldsComplete) {
            [self _startSignInWithCompletion:nil];
        }
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.signedIn) {
        
        return [HCRCollectionCell preferredSizeForCollectionView:collectionView];
        
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
    
    BOOL topSectionNotSignedIn = (self.signedIn == NO && section == 0);
    BOOL tallScreen = [UIDevice isFourInch];
    
    CGSize idealSize = (tallScreen) ? [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithoutTitleSmallForCollectionView:collectionView];
    
    return (topSectionNotSignedIn) ? CGSizeZero : idealSize;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return [HCRFooterView preferredFooterSizeWithTopLineForCollectionView:collectionView];
    
}

#pragma mark - HCRSignInFieldCell Delegate

- (void)signInFieldCellDidBecomeFirstResponder:(HCRSignInFieldCell *)signInCell {
    
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

- (void)signInFieldCellDidPressDone:(HCRSignInFieldCell *)signInCell {
    
    if (signInCell.fieldType == HCRSignInFieldTypeEmail) {
        
        [self.passwordField becomeFirstResponder];
        
    } else if (signInCell.fieldType == HCRSignInFieldTypePassword) {
        
        if (self.signInFieldsComplete) {
            [self _startSignInWithCompletion:nil];
        }
        
        [self.passwordField resignFirstResponder];
        [UIView animateWithDuration:kKeyboardAnimationTime
                              delay:0.0
                            options:kKeyboardAnimationOptions
                         animations:^{
                             
                             self.collectionView.contentOffset = CGPointMake(0, -1 * kMasterHeaderHeight);
                             
                         } completion:nil];
        
    }
    
}

#pragma mark - Getters & Setters

- (BOOL)signInFieldsComplete {
    return(self.emailField.text.length > 0 && self.passwordField.text.length > 0);
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
        [self.collectionView reloadData];
        
        self.collectionView.scrollEnabled = YES;
        self.signInButtonCell.processingAction = NO;
        self.signInButtonCell.tableButton.enabled = YES;
        
        if (completionBlock) {
            completionBlock(YES);
        }
        
    });
    
}

- (void)_alertsButtonPressed {
    HCRAlertsViewController *alertsController = [[HCRAlertsViewController alloc] initWithCollectionViewLayout:[HCRAlertsViewController preferredLayout]];
    
    [self.navigationController pushViewController:alertsController animated:YES];
}

- (void)_conflictsButtonPressed {
    
    HCRCountryCollectionViewController *countryCollection = [[HCRCountryCollectionViewController alloc] initWithCollectionViewLayout:[HCRCountryCollectionViewController preferredLayout]];
    
    [self.navigationController pushViewController:countryCollection animated:YES];
    
}

- (void)_countryButtonPressed {
    
    // TODO: countries view
    
}

- (void)_campsButtonPressed {
    
    // TODO: camps button
    
}

- (void)_loginButtonPressed {
    self.scrollView.loginState = HCRHomeLoginMenuStateSignedIn;
}

- (void)_logoutButtonPressed {
    self.scrollView.loginState = HCRHomeLoginMenuStateNotSignedIn;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.scrollView.loginState = HCRHomeLoginMenuStateSignedIn;
    });
    
}

- (void)_optionsButtonPressed {
    // TODO: options button
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

@end
