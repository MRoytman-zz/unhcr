//
//  HCRAnswerSetPickerController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAnswerSetPickerController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableCell.h"
#import "HCRTableButtonCell.h"
#import "EASoundManager.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kAnswerSetPickerHeaderIdentifier = @"kAnswerSetPickerHeaderIdentifier";
NSString *const kAnswerSetPickerFooterIdentifier = @"kAnswerSetPickerFooterIdentifier";

NSString *const kAnswerSetPickerTableCellIdentifier = @"kAnswerSetPickerTableCellIdentifier";
NSString *const kAnswerSetPickerButtonCellIdentifier = @"kSurveyPickerButtonCellIdentifier";

NSString *const kLayoutCellLabelNewSurvey = @"Start New Survey";

NSString *const kLayoutHeaderLabelInProgress = @"Surveys in Progress";
NSString *const kLayoutHeaderLabelCompleted = @"Completed Surveys";

NSString *const kLayoutFooterLabelPress = @"(swipe left to delete a survey)";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAnswerSetPickerController ()

@property (nonatomic, readonly) NSArray *layoutDataArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAnswerSetPickerController

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
    
    self.title = @"Answer Sets";
    
    self.highlightCells = YES;
    
    // LAYOUT AND REUSABLES
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kAnswerSetPickerHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kAnswerSetPickerFooterIdentifier];
    
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kAnswerSetPickerTableCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kAnswerSetPickerButtonCellIdentifier];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.layoutDataArray.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self _layoutDataForSection:section];
    NSArray *cellsArray = [sectionData objectForKey:kLayoutCells ofClass:@"NSArray"];
    return cellsArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    if (!cellTitle) {
        cellTitle = [[HCRDataManager sharedManager] answerSetIDForAnswerSet:[self _layoutDataForIndexPath:indexPath]];
    }
    
    if ([cellTitle isEqualToString:kLayoutCellLabelNewSurvey]) {
        
        HCRTableButtonCell *buttonCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerButtonCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = buttonCell;
        
        buttonCell.tableButtonTitle = cellTitle;
        
    } else {
        
        HCRTableCell *tableCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerTableCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = tableCell;
        
        tableCell.title = cellTitle;
        
        tableCell.processingViewPosition = HCRCollectionCellProcessingViewPositionCenter;
        [tableCell.deleteGestureRecognizer addTarget:self action:@selector(_deleteGestureRecognizer:)];
        
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kAnswerSetPickerHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = [self _layoutHeaderStringForSection:indexPath.section];
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kAnswerSetPickerFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        footer.titleString = [self _layoutFooterStringForSection:indexPath.section];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    if ([cellTitle isEqualToString:kLayoutCellLabelNewSurvey]) {
        [self _newSurveyButtonPressed];
    } else {
        [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDNotice];
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return ([self _layoutFooterStringForSection:section]) ? [HCRFooterView preferredFooterSizeWithTitleForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return (section == 0) ? [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
    
}

#pragma mark - Getters & Setters

- (NSArray *)layoutDataArray {
    
    NSMutableArray *layoutData = @[].mutableCopy;
    
    NSArray *localAnswerSets = [[HCRDataManager sharedManager] surveyAnswerSetsArray];
    
    if (localAnswerSets) {
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelInProgress,
                                kLayoutCells: localAnswerSets,
                                kLayoutFooterLabel: kLayoutFooterLabelPress}];
    }
    
    [layoutData addObject:@{kLayoutCells: @[
                                    @{kLayoutCellLabel: kLayoutCellLabelNewSurvey}
                                    ]}];
    
    return layoutData;
    
}

#pragma mark - Private Methods (Buttons)

- (void)_newSurveyButtonPressed {
    
    [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
    
    [self _reloadLayoutData];
    
}

- (void)_deleteGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    HCRTableCell *tableCell = (HCRTableCell *)gestureRecognizer.view;
    NSParameterAssert([tableCell isKindOfClass:[HCRTableCell class]]);
    
    tableCell.userInteractionEnabled = NO;
    tableCell.processingAction = YES;
    
    NSString *cellID = tableCell.title;
    
    NSString *bodyString = [NSString stringWithFormat:@"Are you sure you want to delete survey ID %@ and remove it completely?",cellID];
    [UIAlertView showConfirmationDialogWithTitle:@"Delete Survey"
                                         message:bodyString
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             tableCell.userInteractionEnabled = YES;
                                             tableCell.processingAction = NO;
                                             
                                             if (buttonIndex == 0) {
                                                 // do nothing
                                             } else {
                                                 [[HCRDataManager sharedManager] removeAnswerSetWithID:cellID];
                                                 [self _reloadLayoutData];
                                             }
                                             
                                         }];
    
}

#pragma mark - Private Methods

- (void)_reloadLayoutData {
    
    BOOL safelyAnimate = (self.collectionView.numberOfSections == self.layoutDataArray.count);
    
    if (safelyAnimate) {
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        } completion:nil];
    } else {
        [self.collectionView reloadData];
    }
    
}

- (NSDictionary *)_layoutDataForSection:(NSInteger)section {
    NSDictionary *sectionData = [self.layoutDataArray objectAtIndex:section ofClass:@"NSDictionary"];
    return sectionData;
}

- (NSArray *)_layoutCellsForSection:(NSInteger)section {
    NSDictionary *sectionData = [self _layoutDataForSection:section];
    NSArray *cellsData = [sectionData objectForKey:kLayoutCells ofClass:@"NSArray"];
    return cellsData;
}

- (NSDictionary *)_layoutDataForIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellsData = [self _layoutCellsForSection:indexPath.section];
    NSDictionary *layoutData = [cellsData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    return layoutData;
}

- (NSString *)_layoutLabelForIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dataForIndexPath = [self _layoutDataForIndexPath:indexPath];
    NSString *string = [dataForIndexPath objectForKey:kLayoutCellLabel ofClass:@"NSString" mustExist:NO];
    return string;
}

- (NSString *)_layoutHeaderStringForSection:(NSInteger)section {
    NSDictionary *layoutData = [self _layoutDataForSection:section];
    NSString *headerString = [layoutData objectForKey:kLayoutHeaderLabel ofClass:@"NSString" mustExist:NO];
    return headerString;
}

- (NSString *)_layoutFooterStringForSection:(NSInteger)section {
    NSDictionary *layoutData = [self _layoutDataForSection:section];
    NSString *footerString = [layoutData objectForKey:kLayoutFooterLabel ofClass:@"NSString" mustExist:NO];
    return footerString;
}

@end
