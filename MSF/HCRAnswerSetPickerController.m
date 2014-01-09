//
//  HCRAnswerSetPickerController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAnswerSetPickerController.h"
#import "HCRTableFlowLayout.h"
#import "HCRAnswerSetCell.h"
#import "HCRTableButtonCell.h"
#import "EASoundManager.h"
#import "HCRSurveyController.h"

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

@property NSDateFormatter *dateFormatter;

@property (nonatomic, readonly) NSArray *layoutDataArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAnswerSetPickerController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
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
    
    [self.collectionView registerClass:[HCRAnswerSetCell class]
            forCellWithReuseIdentifier:kAnswerSetPickerTableCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kAnswerSetPickerButtonCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _reloadLayoutData];
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
    HCRSurveyAnswerSet *answerSet;
    
    if (!cellTitle) {
        
        answerSet = [self _answerSetForIndexPath:indexPath];
        
        NSInteger percentNumber = [[HCRDataManager sharedManager] percentCompleteForAnswerSet:answerSet];
        NSString *percentString = [NSString stringWithFormat:@"%d",percentNumber];
        
        NSString *titleString = [NSString stringWithFormat:@"%@ (%@%% complete)",
                                 [self.dateFormatter stringFromDate:answerSet.durationStart],
                                 percentString];
        cellTitle = titleString;
    }
    
    if ([cellTitle isEqualToString:kLayoutCellLabelNewSurvey]) {
        
        HCRTableButtonCell *buttonCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerButtonCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = buttonCell;
        
        buttonCell.tableButtonTitle = cellTitle;
        
    } else {
        
        NSParameterAssert(answerSet);
        
        HCRAnswerSetCell *tableCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerTableCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = tableCell;
        
        tableCell.title = cellTitle;
        
        NSInteger percentComplete = [[HCRDataManager sharedManager] percentCompleteForAnswerSet:answerSet];
        tableCell.percentComplete = percentComplete;
        
        if (percentComplete != 100) {
            tableCell.processingViewPosition = HCRCollectionCellProcessingViewPositionCenter;
            [tableCell.deleteGestureRecognizer addTarget:self action:@selector(_deleteGestureRecognizer:)];
        }
        
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
        [self _openSurveyButtonPressedAtIndexPath:indexPath];
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
    
    // TODO: this is called like a hundred times - should refactor
    NSMutableArray *layoutData = @[].mutableCopy;
    
    NSMutableArray *completedAnswerSets = @[].mutableCopy;
    NSMutableArray *incompleteAnswerSets = @[].mutableCopy;
    
    for (HCRSurveyAnswerSet *answerSet in [[HCRDataManager sharedManager] localAnswerSetsArray]) {
        if ([[HCRDataManager sharedManager] percentCompleteForAnswerSet:answerSet] == 100) {
            [completedAnswerSets addObject:answerSet];
        } else {
            [incompleteAnswerSets addObject:answerSet];
        }
    }
    
    if (incompleteAnswerSets.count > 0) {
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelInProgress,
                                kLayoutCells: incompleteAnswerSets,
                                kLayoutFooterLabel: kLayoutFooterLabelPress}];
    }
    
    if (completedAnswerSets > 0) {
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelCompleted,
                                kLayoutCells: completedAnswerSets}];
    }
    
    [layoutData addObject:@{kLayoutCells: @[
                                    @{kLayoutCellLabel: kLayoutCellLabelNewSurvey}
                                    ]}];
    
    return layoutData;
    
}

#pragma mark - Private Methods (Buttons)

- (void)_openSurveyButtonPressedAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyAnswerSet *answerSet = [self _answerSetForIndexPath:indexPath];
    
    HCRSurveyController *surveyController = [[HCRSurveyController alloc] initWithCollectionViewLayout:[HCRSurveyController preferredLayout]];
    surveyController.answerSetID = answerSet.localID;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:surveyController];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(_closeButtonPressed)];
    
    surveyController.navigationItem.leftBarButtonItem = closeButton;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

- (void)_newSurveyButtonPressed {
    
    [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
    
    [self _reloadLayoutData];
    
}

- (void)_deleteGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    HCRAnswerSetCell *tableCell = (HCRAnswerSetCell *)gestureRecognizer.view;
    NSParameterAssert([tableCell isKindOfClass:[HCRAnswerSetCell class]]);
    
    tableCell.userInteractionEnabled = NO;
    tableCell.processingAction = YES;
    
    NSString *bodyString = [NSString stringWithFormat:@"Are you sure you want to delete the survey created at %@ and remove it completely?",tableCell.title];
    [UIAlertView showConfirmationDialogWithTitle:@"Delete Survey"
                                         message:bodyString
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             tableCell.userInteractionEnabled = YES;
                                             tableCell.processingAction = NO;
                                             
                                             if (buttonIndex == 0) {
                                                 // do nothing
                                             } else {
                                                 NSIndexPath *indexPath = [self.collectionView indexPathForCell:tableCell];
                                                 HCRSurveyAnswerSet *answerSet = [self _answerSetForIndexPath:indexPath];
                                                 [[HCRDataManager sharedManager] removeAnswerSetWithID:answerSet.localID];
                                                 [self _reloadLayoutData];
                                             }
                                             
                                         }];
    
}

- (void)_closeButtonPressed {
    
    [UIAlertView showConfirmationDialogWithTitle:@"Cancel Survey"
                                         message:@"Are you sure you want to cancel the survey? Your progress will be saved and you can return to it at any time."
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             if (buttonIndex == alertView.cancelButtonIndex) {
                                                 // do nothing
                                             } else {
                                                 
                                                 [self _reloadLayoutData];
                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

- (id)_layoutDataForIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellsData = [self _layoutCellsForSection:indexPath.section];
    id object = [cellsData objectAtIndex:indexPath.row];
    return object; // TODO: fix all of this; dangerous and hacky
}

- (NSString *)_layoutLabelForIndexPath:(NSIndexPath *)indexPath {
    
    id object = [self _layoutDataForIndexPath:indexPath];
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *layoutData = (NSDictionary *)object;
        NSString *string = [layoutData objectForKey:kLayoutCellLabel ofClass:@"NSString" mustExist:NO];
        return string;
    } else {
        return nil; // TODO: hacky way to handle this
    }
    
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

- (HCRSurveyAnswerSet *)_answerSetForIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellsData = [self _layoutCellsForSection:indexPath.section];
    HCRSurveyAnswerSet *answerSet = [cellsData objectAtIndex:indexPath.row ofClass:@"HCRSurveyAnswerSet"];
    return answerSet;
}

@end
