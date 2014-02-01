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

#import <Reachability/Reachability.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kAnswerSetPickerHeaderIdentifier = @"kAnswerSetPickerHeaderIdentifier";
NSString *const kAnswerSetPickerFooterIdentifier = @"kAnswerSetPickerFooterIdentifier";

NSString *const kAnswerSetPickerTableCellIdentifier = @"kAnswerSetPickerTableCellIdentifier";
NSString *const kAnswerSetPickerButtonCellIdentifier = @"kSurveyPickerButtonCellIdentifier";

NSString *const kLayoutCellLabelNewSurvey = @"Start New Survey";
NSString *const kLayoutCellLabelRemoveAll = @"Delete All Surveys";
NSString *const kLayoutCellLabelSubmit = @"Submit All Surveys";

NSString *const kLayoutHeaderLabelInProgress = @"Surveys in Progress";
NSString *const kLayoutHeaderLabelUnsubmitted = @"Unsubmitted Surveys";
NSString *const kLayoutHeaderLabelSubmitted = @"Completed Surveys";

NSString *const kLayoutFooterLabelPress = @"(swipe left to delete)";
NSString *const kLayoutFooterLabelUnsubmitted = @"(tap to submit)";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAnswerSetPickerController ()

@property NSDateFormatter *dateFormatter;

@property NSMutableSet *answerSetIDsBeingSubmitted;

@property (nonatomic, readonly) NSArray *answerSetsSubmitted;
@property (nonatomic, readonly) NSArray *answerSetsUnsubmitted;
@property (nonatomic, readonly) NSArray *answerSetsInProgress;
@property (nonatomic, readonly) NSArray *layoutDataArray;

@property (nonatomic, weak) HCRTableButtonCell *submitButtonCell;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAnswerSetPickerController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.answerSetIDsBeingSubmitted = [NSMutableSet new];
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    HCRSurvey *survey = [[[HCRDataManager sharedManager] localSurveys] lastObject];
    self.title = survey.title;
    
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
    
    [self _reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // determine reachability status
    [self _submitAllCompletedAnswerSetsWithCompletion:nil];
    
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
        [cellTitle isEqualToString:kLayoutCellLabelRemoveAll] ||
        [cellTitle isEqualToString:kLayoutCellLabelSubmit]) {
        
        HCRTableButtonCell *buttonCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerButtonCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = buttonCell;
        
        buttonCell.tableButtonTitle = cellTitle;
        
        if ([cellTitle isEqualToString:kLayoutCellLabelSubmit]) {
            self.submitButtonCell = buttonCell;
            
            if (self.answerSetIDsBeingSubmitted.count > 0) {
                buttonCell.processingAction = YES;
                buttonCell.tableButton.enabled = NO;
            }
            
        }
        
    } else {
        
        NSParameterAssert(answerSet);
        
        HCRAnswerSetCell *tableCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kAnswerSetPickerTableCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = tableCell;
        
        tableCell.title = cellTitle;
        tableCell.processingViewPosition = HCRCollectionCellProcessingViewPositionCenter;
        
        NSInteger percentComplete = [[HCRDataManager sharedManager] percentCompleteForAnswerSet:answerSet];
        tableCell.percentComplete = percentComplete;
        
        tableCell.answerSetID = answerSet.localID;
        
        if (percentComplete != 100) {
            tableCell.processingViewPosition = HCRCollectionCellProcessingViewPositionCenter;
            [tableCell.deleteGestureRecognizer addTarget:self action:@selector(_deleteGestureRecognizer:)];
        } else {
            
            BOOL answerSetBeingUploaded = [self.answerSetIDsBeingSubmitted containsObject:answerSet.localID];
            
            tableCell.processingAction = answerSetBeingUploaded;
            tableCell.submitted = (answerSet.householdID != nil);
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
    } else if ([cellTitle isEqualToString:kLayoutCellLabelSubmit]) {
        [self _submitCompletedSurveysButtonPressed];
    } else {
        [self _openSurveyButtonPressedAtIndexPath:indexPath];
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return ([self _layoutFooterStringForSection:section]) ? [HCRFooterView preferredFooterSizeWithTitleForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    BOOL hasHeaderString = ([self _layoutHeaderStringForSection:section] != nil);
    
    return (hasHeaderString) ? [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
    
}

#pragma mark - Getters & Setters

- (NSArray *)answerSetsSubmitted {
    
    // get number of existing answerSets
    for (NSDictionary *layoutData in self.layoutDataArray) {
        if ([[layoutData objectForKey:kLayoutHeaderLabel ofClass:@"NSString" mustExist:NO] isEqualToString:kLayoutHeaderLabelSubmitted]) {
            return [layoutData objectForKey:kLayoutCells ofClass:@"NSArray"];
        }
    }
    
    return nil;
    
}

- (NSArray *)answerSetsUnsubmitted {
    
    // get number of existing answerSets
    for (NSDictionary *layoutData in self.layoutDataArray) {
        if ([[layoutData objectForKey:kLayoutHeaderLabel ofClass:@"NSString" mustExist:NO] isEqualToString:kLayoutHeaderLabelUnsubmitted]) {
            return [layoutData objectForKey:kLayoutCells ofClass:@"NSArray"];
        }
    }
    
    return nil;
    
}

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
    
    NSMutableArray *submittedAnswerSets = @[].mutableCopy;
    NSMutableArray *completedAnswerSets = @[].mutableCopy;
    NSMutableArray *incompleteAnswerSets = @[].mutableCopy;
    
    for (HCRSurveyAnswerSet *answerSet in [[HCRDataManager sharedManager] localAnswerSetsArray]) {
        if ([[HCRDataManager sharedManager] percentCompleteForAnswerSet:answerSet] == 100) {
            
            if (answerSet.householdID) {
                [submittedAnswerSets addObject:answerSet];
            } else {
                [completedAnswerSets addObject:answerSet];
            }
            
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
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelUnsubmitted,
                                kLayoutCells: completedAnswerSets,
                                kLayoutFooterLabel: kLayoutFooterLabelUnsubmitted}];
    }
    
    if (submittedAnswerSets.count > 0) {
        [layoutData addObject:@{kLayoutHeaderLabel: kLayoutHeaderLabelSubmitted,
                                kLayoutCells: submittedAnswerSets}];
    }
    
    if (completedAnswerSets.count > 0) {
        [layoutData addObject:@{kLayoutCells: @[
                                        @{kLayoutCellLabel: kLayoutCellLabelSubmit}
                                        ]
                                }];
    }
    
    [layoutData addObject:@{kLayoutCells: @[
                                    @{kLayoutCellLabel: kLayoutCellLabelNewSurvey},
                                    @{kLayoutCellLabel: kLayoutCellLabelRemoveAll}
                                    ]
                            }];
    
    return layoutData;
    
}

#pragma mark - Private Methods (Buttons)

- (void)_submitCompletedSurveysButtonPressed {
    
    [self _submitAllCompletedAnswerSetsWithCompletion:^(NSError *error) {
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error
                                              withErrorSource:SCErrorSourceParse
                                               withCompletion:nil];
        }
    }];
    
}

- (void)_openSurveyButtonPressedAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRAnswerSetCell *cell = (HCRAnswerSetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    HCRSurveyAnswerSet *answerSet = [self _answerSetForIndexPath:indexPath];
    
    if ([self.answerSetsInProgress containsObject:answerSet]) {
        
        cell.processingAction = YES;
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(queue, ^{
            
            // background code
            HCRSurveyController *surveyController = [[HCRSurveyController alloc] initWithCollectionViewLayout:[HCRSurveyController preferredLayout]];
            surveyController.answerSetID = answerSet.localID;
            
            UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[UINavigationBar class] toolbarClass:[HCRParticipantToolbar class]];
            
            navController.viewControllers = @[surveyController];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // completion code (update UI, etc)
                navController.toolbarHidden = NO;
                [self.navigationController presentViewController:navController animated:YES completion:nil];
                
            });
            
        });
        
    } else {
        
        cell.processingAction = YES;
        
        [self _submitAnswerSet:answerSet withCompletion:^(NSError *error) {
            cell.processingAction = NO;
            [self _reloadData];
        }];
        
    }
    
}

- (void)_newSurveyButtonPressed {
    
    NSUInteger freshCellsSection = 0;
    
    __block NSIndexPath *indexPath;
    
    [self.collectionView performBatchUpdates:^{
        
        if (self.answerSetsInProgress.count == 0) {
            [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:freshCellsSection]];
            indexPath = [NSIndexPath indexPathForItem:0
                                            inSection:freshCellsSection];
        } else {
            [[HCRDataManager sharedManager] createNewSurveyAnswerSet];
             indexPath = [NSIndexPath indexPathForItem:self.answerSetsInProgress.count - 1
                                                         inSection:freshCellsSection];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
        
    } completion:^(BOOL finished) {
        
        [self _reloadSections:[NSIndexSet indexSetWithIndex:freshCellsSection]];
        
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
        
    }];
    
}

- (void)_removeAllButtonpressed {
    
    [UIAlertView showConfirmationDialogWithTitle:@"Delete All Surveys?"
                                         message:@"Are you sure you want to delete all submitted and in-progress surveys? This cannot be undone."
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             if (buttonIndex != alertView.cancelButtonIndex) {
                                                 
                                                 NSMutableIndexSet *dirtySections = [NSMutableIndexSet new];
                                                 NSMutableArray *answerSetsToDelete = @[].mutableCopy;
                                                 
                                                 for (NSArray *sectionData in self.layoutDataArray) {
                                                     
                                                     NSInteger section = [self.layoutDataArray indexOfObject:sectionData];
                                                     NSString *sectionHeader = [self _layoutHeaderStringForSection:section];
                                                     
                                                     if ([sectionHeader isEqualToString:kLayoutHeaderLabelInProgress] ||
                                                         [sectionHeader isEqualToString:kLayoutHeaderLabelSubmitted]) {
                                                         
                                                         [dirtySections addIndex:section];
                                                         
                                                     }
                                                     
                                                 }
                                                 
                                                 [answerSetsToDelete addObjectsFromArray:self.answerSetsSubmitted];
                                                 [answerSetsToDelete addObjectsFromArray:self.answerSetsInProgress];
                                                 
                                                 for (HCRSurveyAnswerSet *answerSet in answerSetsToDelete) {
                                                     [[HCRDataManager sharedManager] removeAnswerSetWithID:answerSet.localID];
                                                 }
                                                 
                                                 [self.collectionView performBatchUpdates:^{
                                                     [self.collectionView deleteSections:dirtySections];
                                                 } completion:^(BOOL finished) {
                                                     [self _reloadData];
                                                 }];
                                                 
                                             }
                                             
                                         }];
    
}

- (void)_deleteGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    HCRAnswerSetCell *tableCell = (HCRAnswerSetCell *)gestureRecognizer.view;
    NSParameterAssert([tableCell isKindOfClass:[HCRAnswerSetCell class]]);
    
    tableCell.userInteractionEnabled = NO;
    tableCell.processingAction = YES;
    
    NSString *bodyString = [NSString stringWithFormat:@"Are you sure you want to delete the survey created at %@ and remove it completely?",tableCell.title];
    [UIAlertView showConfirmationDialogWithTitle:@"Delete Survey?"
                                         message:bodyString
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             tableCell.userInteractionEnabled = YES;
                                             tableCell.processingAction = NO;
                                             
                                             if (buttonIndex != alertView.cancelButtonIndex) {
                                                 
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
                                                     [self _reloadSections:dirtySections];
                                                 }];
                                                 
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

- (void)_reloadData {
    self.submitButtonCell = nil;
    [self.collectionView reloadData];
}

- (void)_reloadSections:(NSIndexSet *)sections {
    self.submitButtonCell = nil;
    [self.collectionView reloadSections:sections];
}

- (void)_reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    self.submitButtonCell = nil;
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)_submitAnswerSet:(HCRSurveyAnswerSet *)answerSet withCompletion:(void (^)(NSError *error))completionBlock {
    
    if (!answerSet.householdID) {
    
        [self.answerSetIDsBeingSubmitted addObject:answerSet.localID];
        
        NSIndexPath *indexPath = [self _indexPathForAnswerSet:answerSet];
        [self _reloadItemsAtIndexPaths:@[indexPath]];
        
        if (!answerSet.duration) {
            answerSet.durationEnd = [NSDate date];
            answerSet.duration = @(answerSet.durationEnd.timeIntervalSinceReferenceDate - answerSet.durationStart.timeIntervalSinceReferenceDate);
        }
        
        [[HCRDataManager sharedManager] submitAnswerSet:answerSet withCompletion:^(NSError *error) {
            
            [self.answerSetIDsBeingSubmitted removeObject:answerSet.localID];
            
            if (completionBlock) {
                completionBlock(error);
            }
            
        }];
        
    } else {
        HCRWarning(@"Answer set already submitted!");
        if (completionBlock) {
            completionBlock(nil);
        }
    }
    
}

- (void)_submitAllCompletedAnswerSetsWithCompletion:(void (^)(NSError *error))completionBlock {
    
    self.submitButtonCell.tableButton.enabled = NO;
    self.submitButtonCell.processingAction = YES;
    
    for (HCRSurveyAnswerSet *answerSet in self.answerSetsUnsubmitted) {
        
        // get cell for answer set
        // if no cell, just upload directly
        [self _submitAnswerSet:answerSet withCompletion:^(NSError *error) {
            
            self.submitButtonCell.tableButton.enabled = YES;
            self.submitButtonCell.processingAction = NO;
            
            [self _reloadData];
            
            if (completionBlock) {
                completionBlock(error);
            }
            
        }];
        
    }
    
}

- (NSIndexPath *)_indexPathForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    for (NSArray *sectionData in self.layoutDataArray) {
        
        NSInteger currentSection = [self.layoutDataArray indexOfObject:sectionData];
        
        NSArray *answerSets = [self _layoutCellsForSection:currentSection];
        
        for (HCRSurveyAnswerSet *layoutAnswerSet in answerSets) {
            if (layoutAnswerSet == answerSet) {
                NSInteger currentRow = [answerSets indexOfObject:layoutAnswerSet];
                return [NSIndexPath indexPathForItem:currentRow
                                           inSection:currentSection];
            }
        }
        
    }
    
    return nil;
    
}

@end
