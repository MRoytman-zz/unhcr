//
//  HCRTallySheetInputViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallySheetDetailInputViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRHeaderTallyView.h"
#import "HCRTableButtonCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallyDetailInputCellIdentifier = @"kTallyDetailInputCellIdentifier";
NSString *const kTallyDetailInputHeaderIdentifier = @"kTallyDetailInputHeaderIdentifier";
NSString *const kTallyDetailInputFooterIdentifier = @"kTallyDetailInputFooterIdentifier";

NSString *const kTallySubmitCellIdentifier = @"kTallySubmitCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

static const NSInteger kTallyInputBaseTag = 123123;

static const CGFloat kKeyboardHeight = 216; // TODO: don't hard code this shit
static const NSTimeInterval kKeyboardAnimationTime = 0.3;
static const UIViewAnimationOptions kKeyboardAnimationOptions = UIViewAnimationCurveEaseOut << 16;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetDetailInputViewController ()

@property (nonatomic, readonly) BOOL allFieldsFilledOut;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallySheetDetailInputViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.resourceName);
    NSParameterAssert(self.questionsArray);
    
    self.highlightCells = YES;
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRTallyEntryFieldCell class]
            forCellWithReuseIdentifier:kTallyDetailInputCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kTallySubmitCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderTallyView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kTallyDetailInputHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kTallyDetailInputFooterIdentifier];
    
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
    
    return (section == 0) ? self.questionsArray.count : 1;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        HCRTallyEntryFieldCell *tallyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallyDetailInputCellIdentifier
                                                                                      forIndexPath:indexPath];
        
        tallyCell.labelTitle = [self _stringForCellAtIndexPath:indexPath];
        tallyCell.inputPlaceholder = @"Enter Data";
        
        tallyCell.inputField.tag = kTallyInputBaseTag + indexPath.row;
        
        tallyCell.dataDelegate = self;
        
        tallyCell.fieldType = HCRDataEntryFieldTypeNumber;
        
        tallyCell.lastFieldInSeries = (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1);
        
        [tallyCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
        
        return tallyCell;
        
    } else if (indexPath.section == 1) {
        
        HCRTableButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallySubmitCellIdentifier
                                                                                   forIndexPath:indexPath];
        
        buttonCell.tableButtonTitle = @"Save Changes";
        
        return buttonCell;
        
    }
    
    NSAssert(NO, @"Unhandled cell requested.");
    return nil;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderTallyView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                        withReuseIdentifier:kTallyDetailInputHeaderIdentifier
                                                                               forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            header.stringArray = [self _headerStringArrayForSection:indexPath.section];
        }
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kTallyDetailInputFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self _saveChangedButtonPressed];
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return (indexPath.section == 0) ? [HCRTallyEntryFieldCell sizeForCellInCollectionView:collectionView withString:[self _stringForCellAtIndexPath:indexPath]] : [HCRTableButtonCell preferredSizeForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return (section == 0) ? [HCRHeaderTallyView sizeForTallyHeaderInCollectionView:collectionView withStringArray:[self _headerStringArrayForSection:section]] : [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return (section == ([collectionView numberOfSections] - 1)) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    
}

#pragma mark - HCRDataEntryFieldCell Delegate

- (void)dataEntryFieldCellDidBecomeFirstResponder:(HCRDataEntryFieldCell *)signInCell {
    
    CGFloat bottomOfHeader = CGRectGetMinY(self.collectionView.frame);
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

- (BOOL)allFieldsFilledOut {
    
    BOOL textFieldsPresent = NO;
    
    for (UIView *subview in self.collectionView.subviews) {
        
        if ([subview isKindOfClass:[UITextField class]]) {
            textFieldsPresent = YES;
            
            if ([(UITextField *)subview text].length == 0) {
                return NO;
            }
            
        }
        
    }
    
    return textFieldsPresent;
    
}

#pragma mark - Private Methods

- (NSArray *)_headerStringArrayForSection:(NSInteger)section {
    return @[self.resourceName,
             [self _inputDateRangeString]];
}

- (NSString *)_inputDateRangeString {
    
    NSTimeInterval secondsPerWeek = 60*60*24*7;
    NSDate *now = [NSDate new];
    NSDate *lastWeek = [now dateByAddingTimeInterval:(-1 * secondsPerWeek)];
    
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:YES];
    
    NSString *nowString = [formatter stringFromDate:now];
    NSString *lastWeekString = [formatter stringFromDate:lastWeek];
    NSString *inputString = [NSString stringWithFormat:@"%@ - %@",lastWeekString,nowString];
    return inputString;
    
}

- (NSString *)_stringForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *questionDictionary = [self.questionsArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    return [questionDictionary objectForKey:@"Text" ofClass:@"NSString"];
    
}

- (void)_resetCollectionContentOffset {
    
    [UIView animateWithDuration:kKeyboardAnimationTime
                          delay:0.0
                        options:kKeyboardAnimationOptions
                     animations:^{
                         
                         NSInteger lastSection = 1;
                         NSInteger lastItem = ([self.collectionView numberOfItemsInSection:lastSection] - 1);
                         [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:lastItem
                                                                                          inSection:lastSection]
                                                     atScrollPosition:UICollectionViewScrollPositionBottom
                                                             animated:YES];
                         
                     } completion:nil];
    
}

- (void)_saveChangedButtonPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
