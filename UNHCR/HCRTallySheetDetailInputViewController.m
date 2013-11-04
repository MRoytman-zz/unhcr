//
//  HCRTallySheetInputViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallySheetDetailInputViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableTallyCell.h"
#import "HCRHeaderTallyView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallyDetailInputCellIdentifier = @"kTallyDetailInputCellIdentifier";
NSString *const kTallyDetailInputHeaderIdentifier = @"kTallyDetailInputHeaderIdentifier";
NSString *const kTallyDetailInputFooterIdentifier = @"kTallyDetailInputFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetDetailInputViewController ()

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
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRTableTallyCell class]
            forCellWithReuseIdentifier:kTallyDetailInputCellIdentifier];
    
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.questionsArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableTallyCell *tallyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallyDetailInputCellIdentifier
                                                                             forIndexPath:indexPath];
    
    tallyCell.title = [self _stringForCellAtIndexPath:indexPath];
    
    [tallyCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return tallyCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderTallyView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                        withReuseIdentifier:kTallyDetailInputHeaderIdentifier
                                                                               forIndexPath:indexPath];
        
        header.stringArray = [self _headerStringArrayForSection:indexPath.section];
        
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
    
    //
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [HCRTableTallyCell sizeForCellInCollectionView:collectionView withString:[self _stringForCellAtIndexPath:indexPath]];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return [HCRHeaderTallyView sizeForTallyHeaderInCollectionView:collectionView withStringArray:[self _headerStringArrayForSection:section]];
    
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

@end
