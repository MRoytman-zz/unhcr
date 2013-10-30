//
//  HCRCampClusterDetailViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterDetailViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRGraphCell.h"
#import "HCRTableButtonCell.h"
#import "HCRTallySheetPickerViewController.h"
#import "EAEmailUtilities.h"
#import "HCREmergencyCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampClusterHeaderIdentifier = @"kCampClusterHeaderIdentifier";
NSString *const kCampClusterFooterIdentifier = @"kCampClusterFooterIdentifier";

NSString *const kCampClusterAlertCellIdentifier = @"kCampClusterAlertCellIdentifier";
NSString *const kCampClusterGraphCellIdentifier = @"kCampClusterGraphCellIdentifier";
NSString *const kCampClusterResourcesCellIdentifier = @"kCampClusterResourcesCellIdentifier";
NSString *const kCampClusterAgenciesCellIdentifier = @"kCampClusterAgenciesCellIdentifier";

NSString *const kResourceNameSupplies = @"Request Supplies";
NSString *const kResourceNameSitReps = @"Situation Reports";
NSString *const kResourceNameTallySheets = @"Tally Sheets";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterDetailViewController ()

@property NSMutableArray *localAlerts;
@property NSDictionary *campClusterData;
@property NSMutableArray *campClusterCollectionLayoutData;

@property NSDateFormatter *dateFormatter;

@property (nonatomic) BOOL alertsAdded;

@property (nonatomic, readonly) BOOL clusterContainsTallySheets;

// DEBUG ONLY //
@property (nonatomic) NSArray *messagesReceivedArray;
// DEBUG ONLY //

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterDetailViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        self.alertsAdded = NO;
        self.localAlerts = @[].mutableCopy;
        
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatMMMdd];
        
        self.campClusterCollectionLayoutData = @[
                                      @{@"Section": @"Refugee Requests",
                                        @"Cell": kCampClusterGraphCellIdentifier},
                                      @{@"Section": @"Resources",
                                        @"Cell": kCampClusterResourcesCellIdentifier,
                                        @"Resources": @[
                                                kResourceNameSupplies,
                                                kResourceNameSitReps,
                                                kResourceNameTallySheets
                                                ]},
                                      @{@"Section": @"Local Agencies",
                                        @"Cell": kCampClusterAgenciesCellIdentifier}
                                      ].mutableCopy;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.selectedClusterMetaData);
    NSParameterAssert(self.campDictionary);
    
    // finish data source
    NSString *selectedCluster = [self.selectedClusterMetaData objectForKey:@"Name"];
    if ([HCRDataSource globalEmergenciesData].count > 0) {
        
        for (NSDictionary *alertsDictionary in [HCRDataSource globalEmergenciesData]) {
            
            NSString *alertCluster = [alertsDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
            if ([alertCluster isEqualToString:selectedCluster]) {
                
                [self.localAlerts addObject:alertsDictionary];
                
                if (!self.alertsAdded) {
                    self.alertsAdded = YES;
                    [self.campClusterCollectionLayoutData insertObject:@{@"Section": @"Alerts",
                                                                         @"Cell": kCampClusterAlertCellIdentifier}
                                                               atIndex:0];
                    
                }
                
                
            }
            
            
        }
        
    }
    [self.collectionView reloadData];
    
    self.campClusterData = [[self.campDictionary objectForKey:@"Clusters" ofClass:@"NSDictionary"] objectForKey:selectedCluster ofClass:@"NSDictionary"];
    
    self.title = selectedCluster;
    
    self.highlightCells = YES;
    
    HCRFlowLayout *flowLayout = (HCRFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([flowLayout isKindOfClass:[HCRFlowLayout class]]);
    [flowLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampClusterHeaderIdentifier];
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCampClusterFooterIdentifier];
    
    [self.collectionView registerClass:[HCRGraphCell class]
            forCellWithReuseIdentifier:kCampClusterGraphCellIdentifier];
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier];
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier];
    [self.collectionView registerClass:[HCREmergencyCell class]
            forCellWithReuseIdentifier:kCampClusterAlertCellIdentifier];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.campClusterCollectionLayoutData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:section ofClass:@"NSDictionary"];
    NSString *cellType = [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
    if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        return (self.clusterContainsTallySheets) ? 3 : 2;
        
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        
        NSArray *agencyArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
        return agencyArray.count;
        
    } else if ([cellType isEqualToString:kCampClusterAlertCellIdentifier]) {
        
        return self.localAlerts.count;
        
    } else {
    
        return 1;
        
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    HCRCollectionCell *cell;
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        HCRGraphCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterGraphCellIdentifier forIndexPath:indexPath];
        
        graphCell.graphDelegate = self;
        graphCell.graphDataSource = self;
        
        cell = graphCell;
        
    } else if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        HCRTableButtonCell *resourcesCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier forIndexPath:indexPath];
        
        NSDictionary *campClusterLayoutDictionary = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        NSArray *resourcesArray = [campClusterLayoutDictionary objectForKey:@"Resources" ofClass:@"NSArray"];
        resourcesCell.tableButtonTitle = [resourcesArray objectAtIndex:indexPath.row ofClass:@"NSString"];
        
        cell = resourcesCell;
        
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        HCRTableButtonCell *agencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier forIndexPath:indexPath];
        
        NSArray *agencyArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
        NSDictionary *agencyDictionary = [agencyArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        agencyCell.tableButtonTitle = [agencyDictionary objectForKey:@"Abbr" ofClass:@"NSString"];
        
        cell = agencyCell;
    } else if ([cellType isEqualToString:kCampClusterAlertCellIdentifier]) {
        HCREmergencyCell *alertCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterAlertCellIdentifier forIndexPath:indexPath];
        
        alertCell.emergencyDictionary = [self.localAlerts objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        
        cell = alertCell;
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        NSString *titleString = [sectionData objectForKey:@"Section" ofClass:@"NSString"];
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kCampClusterHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = titleString;
        
        // check if it's alerts
        NSDictionary *layoutObject = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        NSString *sectionTitle = [layoutObject objectForKey:@"Section" ofClass:@"NSString"];
        if ([sectionTitle isEqualToString:@"Alerts"]) {
            header.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        }
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kCampClusterFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        if ([self _sectionEqualToRefugeeRequestsSection:indexPath.section]) {
            [footer setButtonType:HCRFooterButtonTypeRawData withButtonTitle:@"Raw Data"];
            
            [footer.button addTarget:self
                              action:@selector(_footerButtonPressed)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        
        // do nothing
        
    } else if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        HCRTableButtonCell *cell = (HCRTableButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSParameterAssert([cell isKindOfClass:[HCRTableButtonCell class]]);
        
        if ([cell.tableButtonTitle isEqualToString:kResourceNameSupplies]) {
            [self _requestSuppliesButtonPressed];
        } else if ([cell.tableButtonTitle isEqualToString:kResourceNameSitReps]) {
            [self _sitRepsButtonPressed];
        } else if ([cell.tableButtonTitle isEqualToString:kResourceNameTallySheets]) {
            [self _tallySheetsButtonPressed];
        }
        
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        
        //
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                          [HCRGraphCell preferredHeightForGraphCell]);
    } else if ([cellType isEqualToString:kCampClusterAlertCellIdentifier]) {
        
        return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                          [HCREmergencyCell preferredCellHeight]);
        
    } else {
        
        return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                          [HCRTableButtonCell preferredCellHeight]);
        
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if ([self _sectionEqualToRefugeeRequestsSection:section]) {
        return [HCRFooterView preferredFooterSizeWithGraphCellForCollectionView:collectionView];
    } else {
        return [HCRFooterView preferredFooterSizeWithTopLineForCollectionView:collectionView];
    }
    
}

#pragma mark - SCGraphView Delegate

- (void)graphViewBeganTouchingData:(SCGraphView *)graphView withTouches:(NSSet *)touches {
    self.collectionView.scrollEnabled = NO;
}

- (void)graphViewStoppedTouchingData:(SCGraphView *)graphView {
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - SCGraphView Data Source

- (NSInteger)numberOfDataPointsInGraphView:(SCGraphView *)graphView {
    return self.messagesReceivedArray.count;
}

- (CGFloat)graphViewMinYValue:(SCGraphView *)graphView {
    return 0;
}

- (CGFloat)graphViewMaxYValue:(SCGraphView *)graphView {
    
    // http://stackoverflow.com/questions/3080540/finding-maximum-numeric-value-in-nsarray
    NSNumber *largestNumber = [self.messagesReceivedArray valueForKeyPath:@"@max.intValue"];
    CGFloat maxNumberWithPadding = largestNumber.floatValue * 1.1;
    
    return maxNumberWithPadding;
}

- (NSNumber *)graphView:(SCGraphView *)graphView dataPointForIndex:(NSInteger)index {
    
    return [self.messagesReceivedArray objectAtIndex:index];
    
}

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index {
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((self.messagesReceivedArray.count - (index + 1)) * 60 * 60 * 24);
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];

    NSString *dateString = [self.dateFormatter stringFromDate:targetDate];
    
    return dateString;
}

#pragma mark - Getters & Setters

- (NSArray *)messagesReceivedArray {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDataPoints = 30;
    static const CGFloat kDataPointBaseline = 50.0;
    static const CGFloat kDataPointRange = 50.0;
    static const CGFloat kDataPointIncrement = 6.0;
    
    if ( ! _messagesReceivedArray ) {
        
        NSMutableArray *randomMessagesArray = @[].mutableCopy;
        
        for (NSInteger i = 0; i < kNumberOfDataPoints; i++) {
            CGFloat nextValue = kDataPointBaseline + (i * kDataPointIncrement) + arc4random_uniform(kDataPointRange);
            [randomMessagesArray addObject:@(nextValue)];
        }
        
        _messagesReceivedArray = randomMessagesArray;
    }
    
    return _messagesReceivedArray;
    
}

- (BOOL)clusterContainsTallySheets {
    return ([self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray" mustExist:NO] != nil);
}

#pragma mark - Private Methods

- (NSString *)_cellTypeForSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:section ofClass:@"NSDictionary"];
    return [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
}

- (void)_requestSuppliesButtonPressed {
    
    NSString *clusterName = [self.selectedClusterMetaData objectForKey:@"Name"];
    NSString *toString = [NSString stringWithFormat:@"%@@unhcr.org", [[clusterName stringByReplacingOccurrencesOfString:@" " withString:@"."] lowercaseString]];
    NSString *subjectString = [NSString stringWithFormat:@"%@ Supply Request", clusterName];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[toString]
                                                withSubjectText:subjectString
                                                   withBodyText:nil
                                                 withCompletion:nil];
    
}

- (void)_sitRepsButtonPressed {
    
    NSString *sitRepString = [self.campClusterData objectForKey:@"SitReps" ofClass:@"NSString" mustExist:NO];
    
    NSURL *targetURL = [NSURL URLWithString:(sitRepString) ? sitRepString : [self.campDictionary objectForKey:@"SitReps" ofClass:@"NSString"]];
    
    [[UIApplication sharedApplication] openURL:targetURL];
    
}

- (void)_tallySheetsButtonPressed {
    
    HCRTallySheetPickerViewController *healthTallySheet = [[HCRTallySheetPickerViewController alloc] initWithCollectionViewLayout:[HCRTallySheetPickerViewController preferredLayout]];
    
    healthTallySheet.title = kResourceNameTallySheets;
    healthTallySheet.countryName = self.countryName;
    healthTallySheet.campData = self.campDictionary;
    healthTallySheet.campClusterData = self.campClusterData;
    healthTallySheet.selectedClusterMetaData = self.selectedClusterMetaData;
    
    [self.navigationController pushViewController:healthTallySheet animated:YES];
    
}

- (void)_footerButtonPressed {
    // TODO: footer button!
}

- (BOOL)_sectionEqualToRefugeeRequestsSection:(NSInteger)section {
    
    NSDictionary *layoutObject = [self.campClusterCollectionLayoutData objectAtIndex:section ofClass:@"NSDictionary"];
    NSString *sectionTitle = [layoutObject objectForKey:@"Section" ofClass:@"NSString"];
    return [sectionTitle isEqualToString:@"Refugee Requests"];
    
}

@end
