//
//  HCRSurveyPickerController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyPickerController.h"
#import "HCRTableButtonCell.h"
#import "HCRTableFlowLayout.h"
#import "EAEmailUtilities.h"
#import "HCRAnswerSetPickerController.h"

#import <MBProgressHUD.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kSurveyPickerHeaderIdentifier = @"kSurveyPickerHeaderIdentifier";
NSString *const kSurveyPickerFooterIdentifier = @"kSurveyPickerFooterIdentifier";

NSString *const kSurveyPickerButtonCellIdentifier = @"kSurveyPickerButtonCellIdentifier";

NSString *const kLayoutCellLabelRefresh = @"Refresh Surveys";
NSString *const kLayoutCellLabelRequestNew = @"Request New Survey";

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyPickerController ()

@property (nonatomic, readonly) NSArray *layoutDataArray;
@property NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSMutableArray *surveyCells;
@property (nonatomic, weak) HCRTableButtonCell *refreshCell;

@property (nonatomic) BOOL refreshingSurvey;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyPickerController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.surveyCells = @[].mutableCopy;
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Surveys";
    
    self.highlightCells = YES;
    
    // LAYOUT AND REUSABLES
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kSurveyPickerHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kSurveyPickerFooterIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kSurveyPickerButtonCellIdentifier];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // TODO: this is not the correct detection for this event; should be based on # of surveys
    if ([[[[HCRDataManager sharedManager] localSurveys] objectAtIndex:0] title] == nil) {
        [self _refreshSurveyData];
    }
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.layoutDataArray.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *sectionDataArrays = [self _layoutDataForSection:section];
    return sectionDataArrays.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    HCRTableButtonCell *buttonCell =
    [self.collectionView dequeueReusableCellWithReuseIdentifier:kSurveyPickerButtonCellIdentifier
                                                   forIndexPath:indexPath];
    
    buttonCell.tableButtonTitle = cellTitle;
    
    if ([cellTitle isEqualToString:kLayoutCellLabelRefresh]) {
        self.refreshCell = buttonCell;
    } else if (![cellTitle isEqualToString:kLayoutCellLabelRequestNew]) {
        // if NOT the request new cell, it is a survey
        [self.surveyCells addObject:buttonCell];
    }
    
    [buttonCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return buttonCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kSurveyPickerHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            header.titleString = @"Active Surveys";
        }
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kSurveyPickerFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
        if (![cellTitle isEqualToString:kLayoutCellLabelRefresh] &&
            ![cellTitle isEqualToString:kLayoutCellLabelRequestNew]) {
            
            NSDate *lastUpdated = [[HCRDataManager sharedManager] surveyQuestionsLastUpdated];
            footer.titleString = [NSString stringWithFormat:@"Revision: %@",
                                  (lastUpdated) ? [self.dateFormatter stringFromDate:lastUpdated] : @"n/a"];
            
        }
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    if (self.refreshingSurvey == NO) {
        
        if ([cellTitle isEqualToString:kLayoutCellLabelRequestNew]) {
            [self _newStudyButtonPressedFromIndexPath:indexPath];
        } else if ([cellTitle isEqualToString:kLayoutCellLabelRefresh]) {
            [self _refreshButtonPressed];
        } else {
            [self _openStudyButtonPressed];
        }
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return (section == 0) ? [HCRFooterView preferredFooterSizeWithTitleForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return (section == 0) ? [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:collectionView];
    
}

#pragma mark - Getters & Setters

- (NSArray *)layoutDataArray {
    
    NSArray *surveys = [[HCRDataManager sharedManager] localSurveys];
    
    NSMutableArray *layoutData = @[].mutableCopy;
    NSMutableArray *surveysData = @[].mutableCopy;
    
    for (HCRSurvey *survey in surveys) {
        if (survey.title) {
            [surveysData addObject:@{kLayoutCellLabel:survey.title}];
        }
    }
    
    if (surveysData.count > 0) {
        [layoutData addObject:surveysData];
    }
    
    [layoutData addObject:@[
                            @{kLayoutCellLabel: kLayoutCellLabelRefresh},
                            @{kLayoutCellLabel: kLayoutCellLabelRequestNew}
                            ]];
    
    return layoutData;
    
}

- (void)setRefreshingSurvey:(BOOL)refreshingSurvey {
    _refreshingSurvey = refreshingSurvey;
    
    for (HCRTableButtonCell *surveyCell in self.surveyCells) {
        surveyCell.processingAction = refreshingSurvey;
        surveyCell.tableButton.enabled = !refreshingSurvey;
    }
    
    self.refreshCell.tableButton.enabled = !refreshingSurvey;
}

#pragma mark - Private Methods (Buttons)

- (void)_newStudyButtonPressedFromIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableButtonCell *buttonCell = (HCRTableButtonCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([buttonCell isKindOfClass:[HCRTableButtonCell class]]);
    
    buttonCell.processingAction = YES;
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[@"jesse@dharmahs.io"]
                                                withSubjectText:@"Request for new Study or Survey"
                                                   withBodyText:nil
                                                 withCompletion:^(EAEmailStatus emailStatus) {
                                                     buttonCell.processingAction = NO;
                                                 }];
    
}

- (void)_openStudyButtonPressed {
    
    if ([[HCRDataManager sharedManager] localQuestionsArray] == nil) {
        
        NSString *bodyString = [NSString stringWithFormat:@"The survey you are trying to access is too old. Please use the %@ button and try again.",kLayoutCellLabelRefresh];
        
        [UIAlertView showWithTitle:@"Outdated Survey"
                           message:bodyString
                           handler:nil];
        
    } else {
        
        HCRAnswerSetPickerController *answerSetPicker = [[HCRAnswerSetPickerController alloc] initWithCollectionViewLayout:[HCRAnswerSetPickerController preferredLayout]];
        
        [self.navigationController pushViewController:answerSetPicker animated:YES];
    }
    
}

- (void)_refreshButtonPressed {
    
    [self _refreshSurveyData];
    
}

#pragma mark - Private Methods

- (NSArray *)_layoutDataForSection:(NSInteger)section {
    NSArray *sectionData = [self.layoutDataArray objectAtIndex:section ofClass:@"NSArray"];
    return sectionData;
}

- (NSString *)_layoutLabelForIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = [self _layoutDataForSection:indexPath.section];
    NSDictionary *dataForIndexPath = [sectionData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    NSString *string = [dataForIndexPath objectForKey:kLayoutCellLabel ofClass:@"NSString"];
    return string;
}

- (NSIndexPath *)_indexPathForCellTitle:(NSString *)cellTitle {
    
    NSNumber *section, *row;
    
    for (NSArray *sections in self.layoutDataArray) {
        
        for (NSDictionary *cell in sections) {
            
            NSString *title = [cell objectForKey:kLayoutCellLabel ofClass:@"NSString"];
            
            if ([title isEqualToString:cellTitle]) {
                row = @([sections indexOfObject:cell]);
                break;
            }
            
        }
        
        if (row) {
            section = @([self.layoutDataArray indexOfObject:sections]);
            break;
        }
        
    }
    
    return [NSIndexPath indexPathForRow:row.integerValue inSection:section.integerValue];

}

- (void)_refreshSurveyData {
    
    self.refreshingSurvey = YES;
    
    MBProgressHUD *progressHUD;
    if (self.surveyCells.count == 0) {
        progressHUD = [[MBProgressHUD alloc] initWithView:self.collectionView];
        [self.collectionView addSubview:progressHUD];
        progressHUD.removeFromSuperViewOnHide = YES;
        progressHUD.labelText = @"Updating";
        progressHUD.mode = MBProgressHUDModeIndeterminate;
        [progressHUD show:YES];
    }
    
    [[HCRDataManager sharedManager] refreshSurveysWithCompletion:^(NSError *error) {
        
        if (!error) {
            
            [[HCRDataManager sharedManager] refreshSurveyQuestionsWithCompletion:^(NSError *error) {
                
                [progressHUD hide:YES];
                self.refreshingSurvey = NO;
                
                if (!error) {
                    self.surveyCells = @[].mutableCopy;
                    [self.collectionView reloadData];
                }
                
            }];
            
        }
        
    }];
    
}

@end
