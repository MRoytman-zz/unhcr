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

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallyDetailCellIdentifier = @"kTallyDetailCellIdentifier";

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
    NSParameterAssert(self.selectedClusterMetaData);
    
    self.tallyResources = [self.tallySheetData objectForKey:@"Resources" ofClass:@"NSArray"];
    
    self.title = [self.tallySheetData objectForKey:@"Name" ofClass:@"NSString"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.925];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(_cancelButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(_submitButtonPressed)];
    [self.navigationItem setRightBarButtonItem:submitButton];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    tableLayout.minimumLineSpacing = 0;
    tableLayout.sectionInset = UIEdgeInsetsMake(15, 0, 0, 0);
    
    [self.collectionView registerClass:[HCRDataEntryCell class]
            forCellWithReuseIdentifier:kTallyDetailCellIdentifier];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    UIImage *clusterImage = [[UIImage imageNamed:[self.selectedClusterMetaData objectForKey:@"Image"]] colorImage:[UIColor lightGrayColor]
                                                                                                    withBlendMode:kCGBlendModeNormal
                                                                                                 withTransparency:YES];
    background.backgroundColor = [UIColor colorWithPatternImage:clusterImage];
    
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
    
    if (section == 0) {
        // data section
        return self.tallyLayoutData.count;
    } else {
        // tally section
        return self.tallyResources.count;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *dataCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallyDetailCellIdentifier
                                                                           forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        NSString *cellTitle = [self.tallyLayoutData objectAtIndex:indexPath.row ofClass:@"NSString"];
        
        if ([cellTitle isEqualToString:kTallyReportingPeriod]) {
            
            dataCell.cellStatus = HCRDataEntryCellStatusStatic;
            dataCell.dataDictionary = @{@"Header": @YES,
                                        @"Title": cellTitle,
                                        @"Input": [self _inputDateRangeString]};
            
        } else if ([cellTitle isEqualToString:kTallyLocation]) {
            
            NSString *inputString = [NSString stringWithFormat:@"%@ > %@",
                                     self.countryName,
                                     self.campName];
            
            dataCell.cellStatus = HCRDataEntryCellStatusStatic;
            dataCell.dataDictionary = @{@"Header": @YES,
                                        @"Title": cellTitle,
                                        @"Input": inputString};
            
        } else if ([cellTitle isEqualToString:kTallyOrganization]) {
            
            dataCell.cellStatus = HCRDataEntryCellStatusNotCompleted;
            dataCell.dataDictionary = @{@"Header": @YES,
                                        @"Title": cellTitle,
                                        @"Input": @"tap to select"};
            
        }
        
    } else if (indexPath.section == 1) {
        
        NSDictionary *resourceDictionary = [self.tallyResources objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        
        NSMutableDictionary *mutableData = @{@"Title": [resourceDictionary objectForKey:@"Title" ofClass:@"NSString"],
                                             @"Input": @"fill out"}.mutableCopy;
        
        NSString *subtitle = [resourceDictionary objectForKey:@"Subtitle" ofClass:@"NSString" mustExist:NO];
        if (subtitle) {
            [mutableData setObject:subtitle forKey:@"Subtitle"];
        }
        
        dataCell.dataDictionary = [NSDictionary dictionaryWithDictionary:mutableData];
        
    }
    
    return dataCell;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        NSString *cellTitle = [self.tallyLayoutData objectAtIndex:indexPath.row ofClass:@"NSString"];
        if ([cellTitle isEqualToString:kTallyOrganization]) {
            
//            self.agencyPickerBackground = [[UIView alloc] initWithFrame:self.view.bounds];
//            [self.view addSubview:self.agencyPickerBackground];
//            
//            UIPickerView *agencyPicker = [UIPickerView new];
//            [self.agencyPickerBackground addSubview:agencyPicker];
//            
//            agencyPicker.delegate = self;
//            
//            agencyPicker.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.5];
//            agencyPicker.center = CGPointMake(CGRectGetMidX(self.view.bounds),
//                                              CGRectGetMaxY(self.view.bounds) - CGRectGetMidY(agencyPicker.bounds));
//            
//            agencyPicker.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(agencyPicker.bounds));
//            
//            [UIView animateWithDuration:0.33
//                             animations:^{
//                                 self.agencyPickerBackground.transform = CGAffineTransformIdentity;
//                             }];
            
        }
        
    } else if (indexPath.section == 1) {
        
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
        
        tallyInput.headerDictionary = @{@"Header": [resourceDictionary objectForKey:@"Title" ofClass:@"NSString"],
                                        @"Subheader": [NSString stringWithFormat:@"%@ > %@ @ %@",
                                                       self.countryName,
                                                       self.campName,
                                                       [self _inputDateRangeString]]};
        
        tallyInput.questionsArray = questions;
        tallyInput.selectedClusterMetaData = self.selectedClusterMetaData;
        
        [self.navigationController pushViewController:tallyInput animated:YES];
        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *cell = (HCRDataEntryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRDataEntryCell class]]);
    
    [cell.dataEntryButton setHighlighted:YES];
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *cell = (HCRDataEntryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRDataEntryCell class]]);
    
    [cell.dataEntryButton setHighlighted:NO];
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return [HCRTableFlowLayout preferredTableFlowSingleLineCellSizeForCollectionView:collectionView];
    } else {
        
        NSDictionary *resourceDictionary = [self.tallyResources objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        if ([resourceDictionary objectForKey:@"Subtitle" ofClass:@"NSString" mustExist:NO]) {
            return [HCRTableFlowLayout preferredTableFlowDoubleLineCellSizeForCollectionView:collectionView];
        } else {
            return [HCRTableFlowLayout preferredTableFlowCellSizeForCollectionView:collectionView];
        }
            
    }
    
}

#pragma mark - UIPickerView Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSArray *agenciesArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
    return agenciesArray.count;
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *agenciesArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
    NSDictionary *agencyDictionary = [agenciesArray objectAtIndex:row ofClass:@"NSDictionary"];
    return [agencyDictionary objectForKey:@"Abbr" ofClass:@"NSString"];
    
}

#pragma mark - Private Methods

- (void)_agencyPickerBackgroundTapped {
    // dismiss
}

- (NSString *)_inputDateRangeString {
    
    NSTimeInterval secondsPerWeek = 60*60*24*7;
    NSDate *now = [NSDate new];
    NSDate *nextWeek = [now dateByAddingTimeInterval:secondsPerWeek];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMM dd";
    
    NSString *nowString = [formatter stringFromDate:now];
    NSString *nextWeekString = [formatter stringFromDate:nextWeek];
    NSString *inputString = [NSString stringWithFormat:@"%@ - %@",nowString,nextWeekString];
    return inputString;
    
}

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

@end
