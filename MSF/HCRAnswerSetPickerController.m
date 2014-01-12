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
#import "HCRParticipantToolbar.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kAnswerSetPickerHeaderIdentifier = @"kAnswerSetPickerHeaderIdentifier";
NSString *const kAnswerSetPickerFooterIdentifier = @"kAnswerSetPickerFooterIdentifier";

NSString *const kAnswerSetPickerTableCellIdentifier = @"kAnswerSetPickerTableCellIdentifier";
NSString *const kAnswerSetPickerButtonCellIdentifier = @"kSurveyPickerButtonCellIdentifier";

NSString *const kLayoutCellLabelNewSurvey = @"Start New Survey";
NSString *const kLayoutCellLabelRemoveAll = @"Delete All Surveys";

NSString *const kLayoutHeaderLabelInProgress = @"Surveys in Progress";
NSString *const kLayoutHeaderLabelCompleted = @"Completed Surveys";

NSString *const kLayoutFooterLabelPress = @"(swipe left to delete a survey)";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAnswerSetPickerController ()

@property NSDateFormatter *dateFormatter;

@property (nonatomic, readonly) NSArray *answerSetsInProgress;
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
    [self.collectionView reloadData];
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
    
    if ([cellTitle isEqualToString:kLayoutCellLabelNewSurvey] ||
        [cellTitle isEqualToString:kLayoutCellLabelRemoveAll]) {
        
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
    } else if ([cellTitle isEqualToString:kLayoutCellLabelRemoveAll]) {
        [self _removeAllButtonpressed];
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

- (NSArray *)answerSetsInProgress {
    
    // get number of existing answerSets
    for (NSDictionary *layoutData in self.layoutDataArray) {
        if ([[layoutData objectForKey:kLayoutHeaderLabel ofClass:@"NSString" mustExist:NO] isEqualToString:kLayoutHeaderLabelInProgress]) {
            return [layoutData objectForKey:kLayoutCells ofClass:@"NSArray"];
        }
    }
    
    return nil;
    
}

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
    
    if (completedAnswerSets.count > 0) {
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelCompleted,
                                kLayoutCells: completedAnswerSets}];
    }
    
    [layoutData addObject:@{kLayoutCells: @[
                                    @{kLayoutCellLabel: kLayoutCellLabelNewSurvey},
#ifdef DEBUG
                                    @{kLayoutCellLabel: kLayoutCellLabelRemoveAll}
#endif
                                    ]}];
    
    return layoutData;
    
}

#pragma mark - Private Methods (Buttons)

- (void)_openSurveyButtonPressedAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRAnswerSetCell *cell = (HCRAnswerSetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    cell.processingAction = YES;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        // background code
        HCRSurveyAnswerSet *answerSet = [self _answerSetForIndexPath:indexPath];
        
        HCRSurveyController *surveyController = [[HCRSurveyController alloc] initWithCollectionViewLayout:[HCRSurveyController preferredLayout]];
        surveyController.answerSetID = answerSet.localID;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[HCRParticipantToolbar class]];
        
        navController.viewControllers = @[surveyController];
        
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(_closeButtonPressed)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // completion code (update UI, etc)
            navController.toolbarHidden = NO;
            surveyController.navigationItem.leftBarButtonItem = closeButton;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
            
        });
        
    });
    
}

- (void)_newSurveyButtonPressed {
    
    NSUInteger freshCellsSection = 0;
    
    [self.collectionView performBatchUpdates:^{
        
        if (self.answerSetsInProgress.count == 0) {
            [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:freshCellsSection]];
        } else {
            [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.answerSetsInProgress.count - 1
                                                                               inSection:freshCellsSection]]];
        }
        
        
    } completion:^(BOOL finished) {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:freshCellsSection]];
    }];
    
}

- (void)_removeAllButtonpressed {
    
    [[HCRDataManager sharedManager] removeAllAnswerSets];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections - 1)]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    
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
                                                 
                                                 NSIndexSet *dirtySections = [NSIndexSet indexSetWithIndex:0];
                                                 
                                                 [self.collectionView performBatchUpdates:^{
                                                     
                                                     NSIndexPath *indexPath = [self.collectionView indexPathForCell:tableCell];
                                                     HCRSurveyAnswerSet *answerSet = [self _answerSetForIndexPath:indexPath];
                                                     [[HCRDataManager sharedManager] removeAnswerSetWithID:answerSet.localID];
                                                     
                                                     if (self.answerSetsInProgress.count > 0) {
                                                         [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                                     } else {
                                                         [self.collectionView deleteSections:dirtySections];
                                                     }
                                                     
                                                 } completion:^(BOOL finished) {
                                                     [self.collectionView reloadSections:dirtySections];
                                                 }];
                                                 
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
                                                 
                                                 [self.collectionView reloadData];
                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                             }
                                             
                                         }];
    
}

#pragma mark - Private Methods

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
