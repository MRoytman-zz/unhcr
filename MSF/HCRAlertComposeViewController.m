//
//  HCRAlertComposeViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAlertComposeViewController.h"
#import "HCRDataEntryFieldCell.h"
#import "HCRDataEntryViewCell.h"
#import "HCRTableButtonCell.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kMasterHeaderHeight = 90.0;
const NSInteger kCellTagBaseline = 2412;

NSString *const kAlertComposeFieldCellIdentifier = @"kAlertComposeFieldCellIdentifier";
NSString *const kAlertComposeViewCellIdentifier = @"kAlertComposeViewCellIdentifier";
NSString *const kAlertComposeButtonCellIdentifier = @"kAlertComposeButtonCellIdentifier";

NSString *const kAlertComposeHeaderIdentifier = @"kAlertComposeHeaderIdentifier";
NSString *const kAlertComposeFooterIdentifier = @"kAlertComposeFooterIdentifier";

NSString *const kAlertComposeSubmitCellLabel = @"Send Alert";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertComposeViewController ()

@property UIView *masterHeader;
@property NSArray *layoutData;

@property (nonatomic, readonly) BOOL fieldsComplete;

@property (nonatomic, weak) HCRTableButtonCell *submitButtonCell;

@property (nonatomic, weak) UIView *currentResponder;
@property (nonatomic, weak) UITextField *nameField;
@property (nonatomic, weak) UITextView *messageView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertComposeViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        self.layoutData = @[
                            @{kLayoutCells: @[
                                      @{kLayoutCellID: kAlertComposeFieldCellIdentifier},
                                      @{kLayoutCellID: kAlertComposeViewCellIdentifier}
                                      ]},
                            @{kLayoutCells: @[
                                      @{kLayoutCellID: kAlertComposeButtonCellIdentifier,
                                        kLayoutCellLabel: kAlertComposeSubmitCellLabel}
                                      ]}
                            ];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.highlightCells = YES;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(kMasterHeaderHeight, 0, 0, 0);
    
    // MASTER HEADER
    CGRect headerFrame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.view.bounds),
                                    kMasterHeaderHeight);
    self.masterHeader = [[UIView alloc] initWithFrame:headerFrame];
    [self.view addSubview:self.masterHeader];
    
    self.masterHeader.backgroundColor = [UIColor flatBlueColor];
    
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
    
    NSAttributedString *attributedTitleString = [[NSAttributedString alloc] initWithString:@"Alert\nBroadcast"
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
    
    // GESTURE RECOGNIZERS
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [self.collectionView addGestureRecognizer:tapRecognizer];
    
    tapRecognizer.cancelsTouchesInView = NO;
    
    // LAYOUT & REUSABLES
    [self.collectionView registerClass:[HCRDataEntryFieldCell class]
            forCellWithReuseIdentifier:kAlertComposeFieldCellIdentifier];
    
    [self.collectionView registerClass:[HCRDataEntryViewCell class]
            forCellWithReuseIdentifier:kAlertComposeViewCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kAlertComposeButtonCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kAlertComposeHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kAlertComposeFooterIdentifier];
    
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.layoutData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self _cellsForSection:section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    NSString *cellID = [self _cellIDForIndexPath:indexPath];
    
    if ([cellID isEqualToString:kAlertComposeFieldCellIdentifier]) {
        
        HCRDataEntryFieldCell *fieldCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kAlertComposeFieldCellIdentifier forIndexPath:indexPath];
        
        fieldCell.delegate = self;
        
        fieldCell.labelTitle = @"Name:";
        
        NSString *existingName = [HCRUser currentUser].fullName;
        if (existingName) {
            fieldCell.inputTextField.text = existingName;
        } else {
            fieldCell.inputPlaceholder = @"(required)";
        }
        
        fieldCell.inputType = HCRDataEntryTypeDefault;
        
        // customize view
        fieldCell.inputTextField.returnKeyType = UIReturnKeyNext;
        
        self.nameField = fieldCell.inputTextField;
        
        cell = fieldCell;
        
    } else if ([cellID isEqualToString:kAlertComposeViewCellIdentifier]) {
        
        HCRDataEntryViewCell *viewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kAlertComposeViewCellIdentifier forIndexPath:indexPath];
        
        viewCell.delegate = self;
        
        self.messageView = viewCell.inputTextView;
        
        cell = viewCell;
        
    } else if ([cellID isEqualToString:kAlertComposeButtonCellIdentifier]) {
        
        HCRTableButtonCell *buttonCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kAlertComposeButtonCellIdentifier forIndexPath:indexPath];
        
        buttonCell.tableButtonTitle = [self _cellLabelForIndexPath:indexPath];
        
        buttonCell.tableButton.enabled = self.fieldsComplete;
        
        self.submitButtonCell = buttonCell;
        
        cell = buttonCell;
        
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    cell.tag = kCellTagBaseline + indexPath.row;
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kAlertComposeHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kAlertComposeFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HCRTableButtonCell class]]) {
        HCRTableButtonCell *buttonCell = (HCRTableButtonCell *)cell;
        if ([buttonCell.tableButtonTitle isEqualToString:kAlertComposeSubmitCellLabel] &&
            self.submitButtonCell.tableButton.enabled) {
            [self _submitButtonPressed];
        }
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return (section == collectionView.numberOfSections - 1) ? [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return (section == collectionView.numberOfSections - 1) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isTextView = [[self _cellIDForIndexPath:indexPath] isEqualToString:kAlertComposeViewCellIdentifier];
    
    if (isTextView) {
        return [HCRDataEntryViewCell preferredSizeForCollectionView:collectionView];
    } else {
        HCRTableFlowLayout *flowLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
        return flowLayout.itemSize;
    }
    
}

#pragma mark - HCRDataEntryCell Delegate

- (void)dataEntryCellDidEnterText:(HCRDataEntryCell *)dataCell {
    
    self.submitButtonCell.tableButton.enabled = self.fieldsComplete;
    
}

- (void)dataEntryCellDidBecomeFirstResponder:(HCRDataEntryCell *)dataCell {
    
    self.currentResponder = dataCell.inputView;
    
}

- (void)dataEntryCellDidResignFirstResponder:(HCRDataEntryCell *)dataCell {
    
    self.submitButtonCell.tableButton.enabled = self.fieldsComplete;
    
}

- (void)dataEntryCellDidPressDone:(HCRDataEntryCell *)dataCell {
    
    HCRDataEntryCell *nextDataCell = (HCRDataEntryCell *)[self.collectionView viewWithTag:dataCell.tag + 1];
    
    if (nextDataCell) {
        [nextDataCell.inputView becomeFirstResponder];
    } else {
        [self _dismissKeyboard];
    }
    
}

#pragma mark - Getters & Setters

- (BOOL)fieldsComplete {
    return (self.nameField.text.length > 0 && self.messageView.text.length > 0);
}

#pragma mark - Private Methods

- (void)_submitButtonPressed {
    
    // set hud/spinners
    self.submitButtonCell.processingAction = YES;
    self.submitButtonCell.tableButton.enabled = NO;
    self.nameField.userInteractionEnabled = NO;
    self.nameField.textColor = [UIColor grayColor];
    self.messageView.userInteractionEnabled = NO;
    self.messageView.textColor = [UIColor grayColor];
    
    HCRUser *currentUser = [HCRUser currentUser];
    currentUser.fullName = self.nameField.text;
    [currentUser saveEventually];
    
    HCRAlert *newAlert = [HCRAlert newAlertToPush];
    newAlert.authorID = currentUser.objectId;
    newAlert.authorName = self.nameField.text;
    newAlert.message = self.messageView.text;
    newAlert.submittedTime = [NSDate date];
    
    [newAlert saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.submitButtonCell.processingAction = NO;
        self.submitButtonCell.tableButton.enabled = YES;
        self.nameField.userInteractionEnabled = YES;
        self.nameField.textColor = [UIColor darkTextColor];
        self.messageView.userInteractionEnabled = YES;
        self.messageView.textColor = [UIColor darkTextColor];
        
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse withCompletion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
    
}

- (void)_cancelButtonPressed {
    
    if (self.messageView.text.length > 0) {
        [UIAlertView showConfirmationDialogWithTitle:@"Cancel Alert?"
                                             message:@"Are you sure you want to cancel this alert? It will not be sent."
                                             handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                 
                                                 if (buttonIndex != alertView.cancelButtonIndex) {
                                                     [self dismissViewControllerAnimated:YES completion:nil];
                                                 }
                                                 
                                             }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)_dismissKeyboard {
    [self.currentResponder resignFirstResponder];
    self.currentResponder = nil;
}

#pragma mark - Private Methods (Cell Management)

- (NSArray *)_cellsForSection:(NSInteger)section {
    return [[self.layoutData objectAtIndex:section] objectForKey:kLayoutCells ofClass:@"NSArray" mustExist:NO];
}

- (NSDictionary *)_cellDataForIndexPath:(NSIndexPath *)indexPath {
    return [[self _cellsForSection:indexPath.section] objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
}

- (NSString *)_cellIDForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self _cellDataForIndexPath:indexPath];
    return [cellData objectForKey:kLayoutCellID ofClass:@"NSString" mustExist:NO];
}

- (NSString *)_cellLabelForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self _cellDataForIndexPath:indexPath];
    return [cellData objectForKey:kLayoutCellLabel ofClass:@"NSString" mustExist:NO];
}

@end
