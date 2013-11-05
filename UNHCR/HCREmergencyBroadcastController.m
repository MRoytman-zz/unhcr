//
//  HCREmergencyBroadcastController.m
//  UNHCR
//
//  Created by Sean Conrad on 11/3/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCREmergencyBroadcastController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableCell.h"
#import "HCRTableButtonCell.h"

#import <Parse/Parse.h>
#import <MBProgressHUD.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kEmergencyBroadcastFieldCellIdentifier = @"kEmergencyBroadcastFieldCellIdentifier";
NSString *const kEmergencyBroadcastButtonCellIdentifier = @"kEmergencyBroadcastButtonCellIdentifier";
NSString *const kEmergencyBroadcastHeaderIdentifier = @"kEmergencyBroadcastHeaderIdentifier";
NSString *const kEmergencyBroadcastFooterIdentifier = @"kEmergencyBroadcastFooterIdentifier";

NSString *const kFieldCategory = @"Category";
NSString *const kFieldCamp = @"Camp";
NSString *const kFieldLocation = @"Location";
NSString *const kFieldDeaths = @"Deaths";
NSString *const kFieldHurt = @"Ill/Hurt";

NSString *const kButtonSendBroadcast = @"Send Broadcast";

static const CGFloat kMasterHeaderHeight = 90.0;

static const NSInteger kInputFieldTagBaseline = 112;

static const CGFloat kKeyboardHeight = 216; // TODO: don't hard code this shit
static const NSTimeInterval kKeyboardAnimationTime = 0.3;
static const UIViewAnimationOptions kKeyboardAnimationOptions = UIViewAnimationCurveEaseOut << 16;

////////////////////////////////////////////////////////////////////////////////

@interface HCREmergencyBroadcastController ()

@property NSArray *fieldLayoutData;
@property NSArray *buttonLayoutData;

@property UIView *masterHeader;

@property (nonatomic, readonly) BOOL dataFieldsComplete;

@property NSNumberFormatter *numberFormatter;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCREmergencyBroadcastController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.fieldLayoutData = @[
                                 kFieldCategory,
                                 kFieldCamp,
                                 kFieldLocation,
                                 kFieldDeaths,
                                 kFieldHurt
                                 ];
        
        self.buttonLayoutData = @[
                                  kButtonSendBroadcast
                                  ];
        
        self.numberFormatter = [NSNumberFormatter numberFormatterWithFormat:HCRNumberFormatThousandsSeparated forceEuropeanFormat:YES];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.highlightCells = YES;
    
    self.collectionView.backgroundColor = [UIColor tableBackgroundColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(kMasterHeaderHeight, 0, 0, 0);
    
    self.collectionView.scrollEnabled = ([UIDevice isFourInch]);
    
    // MASTER HEADER
    if (!self.masterHeader) {
        CGRect headerFrame = CGRectMake(0,
                                        0,
                                        CGRectGetWidth(self.view.bounds),
                                        kMasterHeaderHeight);
        self.masterHeader = [[UIView alloc] initWithFrame:headerFrame];
        [self.view addSubview:self.masterHeader];
        
        self.masterHeader.backgroundColor = [UIColor redColor];
        
        static const CGFloat kLineHeight = 0.5;
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.masterHeader.bounds) - kLineHeight,
                                                                      CGRectGetWidth(self.masterHeader.bounds),
                                                                      kLineHeight)];
        [self.masterHeader addSubview:bottomLine];
        
        bottomLine.backgroundColor = [UIColor tableDividerColor];
        
        static const CGFloat kTitleLabelHeight = 60;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        CGRectGetHeight(self.masterHeader.bounds) - kTitleLabelHeight,
                                                                        CGRectGetWidth(self.masterHeader.bounds),
                                                                        kTitleLabelHeight)];
        [self.masterHeader insertSubview:titleLabel belowSubview:bottomLine];
        
        titleLabel.backgroundColor = self.masterHeader.backgroundColor;
        titleLabel.numberOfLines = 2;
        
        static const CGFloat kXIndentation = 20.0;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 0.8;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.firstLineHeadIndent = kXIndentation;
        paragraphStyle.headIndent = kXIndentation;
        
        NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont helveticaNeueBoldFontOfSize:24.0],
                                          NSForegroundColorAttributeName: [UIColor whiteColor],
                                          NSParagraphStyleAttributeName: paragraphStyle};
        
        NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:@"Emergency\nBroadcast"
                                                                                    attributes:titleAttributes];
        titleLabel.attributedText = attributedTitleString;
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.masterHeader addSubview:cancelButton];
        
        static const CGFloat kButtonTrailing = 10.0;
        static const CGFloat kButtonHeight = 40.0;
        static const CGFloat kButtonWidth = 50.0;
        cancelButton.frame = CGRectMake(CGRectGetWidth(self.masterHeader.bounds) - kButtonTrailing - kButtonWidth,
                                        CGRectGetMaxY(titleLabel.frame) - kButtonHeight,
                                        kButtonWidth,
                                        kButtonHeight);
        
        [cancelButton setTitle:@"Cancel"
                      forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        
        [cancelButton addTarget:self
                         action:@selector(_cancelButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        
//        cancelButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }
    
    // LAYOUT & REUSABLES
    [self.collectionView registerClass:[HCRDataEntryFieldCell class]
            forCellWithReuseIdentifier:kEmergencyBroadcastFieldCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kEmergencyBroadcastButtonCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kEmergencyBroadcastHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kEmergencyBroadcastFooterIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (section == 0) ? self.fieldLayoutData.count : self.buttonLayoutData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // first section is input fields,
    // second section is buttons
    if (indexPath.section == 0) {
        
        HCRDataEntryFieldCell *fieldCell = [collectionView dequeueReusableCellWithReuseIdentifier:kEmergencyBroadcastFieldCellIdentifier forIndexPath:indexPath];
        
        NSString *fieldString = [self.fieldLayoutData objectAtIndex:indexPath.row ofClass:@"NSString"];
        fieldCell.labelTitle = fieldString;
        fieldCell.inputPlaceholder = @"Required";
        fieldCell.inputField.tag = kInputFieldTagBaseline + indexPath.row;
        
        fieldCell.dataDelegate = self;
        
        if ([fieldString isEqualToString:kFieldCamp] || [fieldString isEqualToString:kFieldLocation]) {
            fieldCell.fieldType = HCRDataEntryFieldTypeDefault;
            
            if ([fieldString isEqualToString:kFieldCamp]) {
                fieldCell.inputField.text = @"Domiz, Iraq";
            } else if ([fieldString isEqualToString:kFieldLocation]) {
                fieldCell.inputField.text = @"Phase 4, Row 5";
            }
            
        } else if ([fieldString isEqualToString:kFieldDeaths] || [fieldString isEqualToString:kFieldHurt]) {
            fieldCell.fieldType = HCRDataEntryFieldTypeNumber;
        }
        
        fieldCell.lastFieldInSeries = (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1);
        
        [fieldCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
        
        return fieldCell;
        
    } else {
        
        HCRTableButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:kEmergencyBroadcastButtonCellIdentifier forIndexPath:indexPath];
        
        buttonCell.tableButtonTitle = [self.buttonLayoutData objectAtIndex:indexPath.row ofClass:@"NSString"];
        
        return buttonCell;
        
    }
    
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kEmergencyBroadcastHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kEmergencyBroadcastFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) { // button section
        
        if (indexPath.row == [self.buttonLayoutData indexOfObject:kButtonSendBroadcast]) {
            [self _sendBroadcastButtonPressed];
        }
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return ([UIDevice isFourInch]) ? [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:self.collectionView] : [HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return ([UIDevice isFourInch] && section != ([collectionView numberOfItemsInSection:section] - 1)) ? [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
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
    
    UITextField *nextField = (UITextField *)[self.collectionView viewWithTag:signInCell.inputField.tag + 1];
    
    if (nextField) {
        NSParameterAssert([nextField isKindOfClass:[UITextField class]]);
        [nextField becomeFirstResponder];
    } else {
        
        [signInCell.inputField resignFirstResponder];
        [self _resetCollectionContentOffset];
        
    }
    
}

#pragma mark - Getters & Setters

- (BOOL)dataFieldsComplete {
    
    for (NSInteger i = 0; i < self.fieldLayoutData.count; i++) {
        UITextField *nextField = (UITextField *)[self.collectionView viewWithTag:kInputFieldTagBaseline + i];
        NSParameterAssert([nextField isKindOfClass:[UITextField class]]);
        
        if (nextField.text.length == 0) {
            return NO;
        }
        
    }
    
    return YES;
    
}

#pragma mark - Private Methods - Buttons

- (void)_sendBroadcastButtonPressed {
    
    if (self.dataFieldsComplete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Broadcast"
                                                        message:@"Emergency Broadcasts are sent to many global observers, including everyone in the selected camp.\n\nAre you sure you want to send this Emergency Broadcast?"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes, Send", nil];
        
        [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex != [alert cancelButtonIndex]) {
                self.collectionView.userInteractionEnabled = NO;
                
                // START HUD
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window]
                                                          animated:YES];
                
                hud.labelText = @"Sending..";
                hud.mode = MBProgressHUDModeIndeterminate;
                
                // SEND PUSH
                PFQuery *everyone = [PFInstallation query];
                [everyone whereKey:@"deviceType" equalTo:@"ios"];
                
                PFPush *push = [PFPush new];
                [push setQuery:everyone];
                
                [push setData:@{@"alert": [self _alertForPushWithCompletedFields],
                                @"sound": @"notice.mp3",
                                @"badge": @1}];
                
                // STOP HUD & SEND PUSH & DISMISS
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [push sendPushInBackground];
                    
                    [hud hide:YES];
                    self.collectionView.userInteractionEnabled = YES;
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
            
        }];
    } else {
        [UIAlertView showErrorWithMessage:@"You must complete all Required fields to send an Emergency Broadcast." handler:nil];
    }
    
}

- (void)_cancelButtonPressed {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cancel Broadcast"
                                                    message:@"Are you sure you want to cancel your Emergency Broadcast? The information you have entered will be lost."
                                                   delegate:nil
                                          cancelButtonTitle:@"Nevermind"
                                          otherButtonTitles:@"Yes, Cancel", nil];
    
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex != [alert cancelButtonIndex]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
    
}

#pragma mark - Private Methods

- (void)_resetCollectionContentOffset {
    
    [UIView animateWithDuration:kKeyboardAnimationTime
                          delay:0.0
                        options:kKeyboardAnimationOptions
                     animations:^{
                         
                         self.collectionView.contentOffset = CGPointMake(0, -1 * kMasterHeaderHeight);
                         
                     } completion:nil];
    
}

- (NSString *)_alertForPushWithCompletedFields {
    
    NSInteger tagForCategoryField = kInputFieldTagBaseline + [self.fieldLayoutData indexOfObject:kFieldCategory];
    NSString *category = [[(UITextField *)[self.collectionView viewWithTag:tagForCategoryField] text] capitalizedString];
    
    NSInteger tagForCampField = kInputFieldTagBaseline + [self.fieldLayoutData indexOfObject:kFieldCamp];
    NSString *camp = [(UITextField *)[self.collectionView viewWithTag:tagForCampField] text];
    
    NSInteger tagForLocationField = kInputFieldTagBaseline + [self.fieldLayoutData indexOfObject:kFieldLocation];
    NSString *location = [(UITextField *)[self.collectionView viewWithTag:tagForLocationField] text];
    
    NSInteger tagForDeathsField = kInputFieldTagBaseline + [self.fieldLayoutData indexOfObject:kFieldDeaths];
    NSString *deaths = [(UITextField *)[self.collectionView viewWithTag:tagForDeathsField] text];
    deaths = [self.numberFormatter stringFromNumber:@([deaths integerValue])];
    
    NSInteger tagForHurtField = kInputFieldTagBaseline + [self.fieldLayoutData indexOfObject:kFieldHurt];
    NSString *hurt = [(UITextField *)[self.collectionView viewWithTag:tagForHurtField] text];
    hurt = [self.numberFormatter stringFromNumber:@([hurt integerValue])];
    
    return [NSString stringWithFormat:@"[EMERGENCY] %@ in %@ at %@. %@ dead and %@ more cases or injured persons.",
            category,
            camp,
            location,
            deaths,
            hurt];
    
}

@end
