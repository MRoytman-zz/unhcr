//
//  HCRTallySheetDetailViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

#import "HCRTallySheetDetailViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRDataEntryCell.h"
#import "HCRTallySheetDetailInputViewController.h"
#import "HCRTableTallyCell.h"
#import "HCRHeaderTallyView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallyDetailCellIdentifier = @"kTallyDetailCellIdentifier";
NSString *const kTallyDetailHeaderIdentifier = @"kTallyDetailHeaderIdentifier";
NSString *const kTallyDetailFooterIdentifier = @"kTallyDetailFooterIdentifier";

NSString *const kTallyReportingPeriod = @"Reporting Period";
NSString *const kTallyLocation = @"Location";
NSString *const kTallyOrganization = @"Organization";

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetDetailViewController ()

@property NSArray *tallyResources;
@property NSArray *tallyLayoutData;

@property UIView *agencyPickerBackground;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallySheetDetailViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        
        // Custom initialization
        self.tallyLayoutData = @[
                                 kTallyReportingPeriod,
                                 kTallyLocation,
                                 kTallyOrganization
                                 ];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.tallySheetData);
    
    self.highlightCells = YES;
    self.tallyResources = [self.tallySheetData objectForKey:@"Resources" ofClass:@"NSArray"];
    
    // LAYOUT & REUSABLES
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRTableTallyCell class]
            forCellWithReuseIdentifier:kTallyDetailCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderTallyView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kTallyDetailHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kTallyDetailFooterIdentifier];
    
    // BAR ITEMS
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(_cancelButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(_submitButtonPressed)];
    [self.navigationItem setRightBarButtonItem:submitButton];
    
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
    
    return self.tallyResources.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableTallyCell *tallyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallyDetailCellIdentifier
                                                                             forIndexPath:indexPath];
    
    NSDictionary *resourceDictionary = [self.tallyResources objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    NSString *title = [resourceDictionary objectForKey:@"Title" ofClass:@"NSString"];
    NSString *subtitle = [resourceDictionary objectForKey:@"Subtitle" ofClass:@"NSString" mustExist:NO];
    NSString *cellTitle = (subtitle) ? [NSString stringWithFormat:@"%@ %@",title,subtitle] : title;
    tallyCell.title = cellTitle;
    
    [tallyCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return tallyCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderTallyView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                        withReuseIdentifier:kTallyDetailHeaderIdentifier
                                                                               forIndexPath:indexPath];
        
        header.stringArray = [self _headerStringArrayForSection:indexPath.section];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kTallyDetailFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *questions = [self.tallySheetData objectForKey:@"Questions" ofClass:@"NSArray"];
    
    NSDictionary *resourceDictionary = [self.tallyResources objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    NSArray *exclusions = [resourceDictionary objectForKey:@"Exclusions" ofClass:@"NSArray" mustExist:NO];
    if (exclusions) {
        NSMutableArray *mutableQuestions = questions.mutableCopy;
        
        for (NSString *question in questions) {
            if ([exclusions containsObject:question]) {
                [mutableQuestions removeObject:question];
            }
        }
        
        questions = mutableQuestions;
        
    }
    
    HCRTallySheetDetailInputViewController *tallyInput = [[HCRTallySheetDetailInputViewController alloc] initWithCollectionViewLayout:[HCRTallySheetDetailInputViewController preferredLayout]];
    
    tallyInput.questionsArray = questions;
    
    [self.navigationController pushViewController:tallyInput animated:YES];
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return [HCRHeaderTallyView sizeForTallyHeaderInCollectionView:collectionView withStringArray:[self _headerStringArrayForSection:section]];
    
}

#pragma mark - Private Methods - Buttons

- (void)_cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_submitButtonPressed {
    
    self.collectionView.userInteractionEnabled = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window]
                                              animated:YES];
    
    hud.labelText = @"Sending..";
    hud.mode = MBProgressHUDModeIndeterminate;
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

#pragma mark - Private Methods

- (NSArray *)_headerStringArrayForSection:(NSInteger)section {
    return @[[self.tallySheetData objectForKey:@"Name" ofClass:@"NSString"],
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

@end
