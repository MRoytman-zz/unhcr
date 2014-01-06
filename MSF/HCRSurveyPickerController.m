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
#import "HCRSurveyController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kSurveyPickerHeaderIdentifier = @"kSurveyPickerHeaderIdentifier";
NSString *const kSurveyPickerFooterIdentifier = @"kSurveyPickerFooterIdentifier";

NSString *const kSurveyPickerButtonCellIdentifier = @"kSurveyPickerButtonCellIdentifier";

NSString *const kLayoutCellLabel = @"kLayoutCellLabel";

NSString *const kLayoutCellLabelLebanon = @"Lebanon Access to Care";
NSString *const kLayoutCellLabelRefresh = @"Refresh Survey List";
NSString *const kLayoutCellLabelRequestNew = @"Request New Survey";

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyPickerController ()

@property NSArray *layoutDataArray;
@property NSDateFormatter *dateFormatter;

@property (nonatomic, weak) HCRTableButtonCell *lebanonCell;
@property (nonatomic, weak) HCRTableButtonCell *refreshCell;

@property (nonatomic) BOOL refreshingSurvey;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyPickerController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        self.layoutDataArray = @[
                                 @[
                                     @{kLayoutCellLabel: kLayoutCellLabelLebanon}
                                     ],
                                 @[
                                     @{kLayoutCellLabel: kLayoutCellLabelRefresh},
                                     @{kLayoutCellLabel: kLayoutCellLabelRequestNew}
                                     ]
                                 ];
        
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Surveys";
    
    self.highlightCells = YES;
    
    self.collectionView.backgroundColor = [UIColor tableBackgroundColor];
    
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
    
    if ([[HCRDataManager sharedManager] surveyQuestionsArray] == nil) {
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
    
    HCRCollectionCell *cell;
    
    NSString *cellTitle = [self _layoutLabelForIndexPath:indexPath];
    
    if ([cellTitle isEqualToString:kLayoutCellLabelLebanon] ||
        [cellTitle isEqualToString:kLayoutCellLabelRequestNew] ||
        [cellTitle isEqualToString:kLayoutCellLabelRefresh]) {
        
        HCRTableButtonCell *buttonCell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:kSurveyPickerButtonCellIdentifier
                                                       forIndexPath:indexPath];
        
        cell = buttonCell;
        
        buttonCell.tableButtonTitle = cellTitle;
        
        if ([cellTitle isEqualToString:kLayoutCellLabelLebanon]) {
            self.lebanonCell = buttonCell;
        } else if ([cellTitle isEqualToString:kLayoutCellLabelRefresh]) {
            self.refreshCell = buttonCell;
        }
        
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
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
        
        if ([[self _layoutLabelForIndexPath:indexPath] isEqualToString:kLayoutCellLabelLebanon]) {
            
            NSDate *lastUpdated = [[HCRDataManager sharedManager] surveyLastUpdated];
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
    
    if ([cellTitle isEqualToString:kLayoutCellLabelLebanon]) {
        [self _lebanonStudyButtonPressed];
    } else if ([cellTitle isEqualToString:kLayoutCellLabelRequestNew]) {
        [self _newStudyButtonPressedFromIndexPath:indexPath];
    } else if ([cellTitle isEqualToString:kLayoutCellLabelRefresh]) {
        [self _refreshButtonPressed];
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

- (void)setRefreshingSurvey:(BOOL)refreshingSurvey {
    _refreshingSurvey = refreshingSurvey;
    
    self.lebanonCell.processingAction = refreshingSurvey;
    self.lebanonCell.tableButton.enabled = !refreshingSurvey;
    
    self.refreshCell.tableButton.enabled = !refreshingSurvey;
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

- (void)_newStudyButtonPressedFromIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableButtonCell *buttonCell = (HCRTableButtonCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([buttonCell isKindOfClass:[HCRTableButtonCell class]]);
    
    buttonCell.processingAction = YES;
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[@"studies@hms.io"]
                                                withSubjectText:@"Request for new Study or Survey"
                                                   withBodyText:nil
                                                 withCompletion:^(EAEmailStatus emailStatus) {
                                                     buttonCell.processingAction = NO;
                                                 }];
    
}

- (void)_lebanonStudyButtonPressed {
    
    if ([[HCRDataManager sharedManager] surveyQuestionsArray] == nil) {
        
        NSString *bodyString = [NSString stringWithFormat:@"The survey you are trying to access is too old. Please use the %@ button and try again.",kLayoutCellLabelRefresh];
        
        [UIAlertView showWithTitle:@"Outdated Survey"
                           message:bodyString
                           handler:nil];
        
    } else {
        HCRSurveyController *surveyController = [[HCRSurveyController alloc] initWithCollectionViewLayout:[HCRSurveyController preferredLayout]];
        
        [self presentViewController:surveyController animated:YES completion:nil];
    }
    
}

- (void)_refreshButtonPressed {
    
    [self _refreshSurveyData];
    
}

- (void)_refreshSurveyData {
    
    self.refreshingSurvey = YES;
    
    [[HCRDataManager sharedManager] refreshSurveyQuestionsWithCompletion:^(NSError *error) {
        
        self.refreshingSurvey = NO;
        
        if (!error) {
            [self.collectionView reloadData];
        }
        
    }];
    
}

@end
