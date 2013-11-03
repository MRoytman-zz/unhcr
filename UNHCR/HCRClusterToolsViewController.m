//
//  HCRCampClusterDetailViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRClusterToolsViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableButtonCell.h"
#import "HCRTallySheetPickerViewController.h"
#import "EAEmailUtilities.h"
#import "HCREmergencyCell.h"
#import "HCRContactViewController.h"
#import "HCRTableCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampClusterHeaderIdentifier = @"kCampClusterHeaderIdentifier";
NSString *const kCampClusterFooterIdentifier = @"kCampClusterFooterIdentifier";

NSString *const kCampClusterResourcesCellIdentifier = @"kCampClusterResourcesCellIdentifier";
NSString *const kCampClusterAgenciesCellIdentifier = @"kCampClusterAgenciesCellIdentifier";

NSString *const kResourceNameSupplies = @"Request Supplies";
NSString *const kResourceNameSitReps = @"Situation Reports";
NSString *const kResourceNameTallySheets = @"Tally Sheets";

////////////////////////////////////////////////////////////////////////////////

@interface HCRClusterToolsViewController ()

@property NSDictionary *campClusterData;
@property NSArray *campClusterCollectionLayoutData;

@property (nonatomic, readonly) BOOL clusterContainsTallySheets;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterToolsViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        self.campClusterCollectionLayoutData = @[
                                      @{@"Section": @"Resources",
                                        @"Cell": kCampClusterResourcesCellIdentifier,
                                        @"Resources": @[
                                                kResourceNameSupplies,
                                                kResourceNameSitReps,
                                                kResourceNameTallySheets
                                                ]},
                                      @{@"Section": @"Local Agencies",
                                        @"Cell": kCampClusterAgenciesCellIdentifier}
                                      ];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.campDictionary);
    NSParameterAssert(self.selectedCluster);
    
    // finish data source
    NSString *selectedClusterName = [self.selectedCluster objectForKey:@"Name" ofClass:@"NSString"];
    self.campClusterData = [[self.campDictionary objectForKey:@"Clusters" ofClass:@"NSDictionary"] objectForKey:selectedClusterName ofClass:@"NSDictionary"];
    
    self.title = selectedClusterName;
    
    self.highlightCells = YES;
    
    HCRFlowLayout *flowLayout = (HCRFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([flowLayout isKindOfClass:[HCRFlowLayout class]]);
    [flowLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    [flowLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampClusterHeaderIdentifier];
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCampClusterFooterIdentifier];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier];
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
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
        
    }
    
    return 0;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    HCRCollectionCell *cell;
    
    if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        HCRTableButtonCell *resourcesCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier forIndexPath:indexPath];
        
        NSDictionary *campClusterLayoutDictionary = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        NSArray *resourcesArray = [campClusterLayoutDictionary objectForKey:@"Resources" ofClass:@"NSArray"];
        resourcesCell.tableButtonTitle = [resourcesArray objectAtIndex:indexPath.row ofClass:@"NSString"];
        
        cell = resourcesCell;
        
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        HCRTableCell *agencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier forIndexPath:indexPath];
        
        NSArray *agencyArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
        NSDictionary *agencyDictionary = [agencyArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        agencyCell.title = [agencyDictionary objectForKey:@"Abbr" ofClass:@"NSString"];
        
        cell = agencyCell;
        
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
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
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
        
        [self _agencyButtonPressedAtIndexPath:indexPath];
        
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellType = [self _cellTypeForSection:indexPath.section];
    
    if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        return [HCRTableButtonCell preferredSizeForCollectionView:collectionView];
        
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        
        return [HCRTableCell preferredSizeForCollectionView:collectionView];
        
    }
    
    return CGSizeZero;
    
}

#pragma mark - Getters & Setters

- (BOOL)clusterContainsTallySheets {
    return ([self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray" mustExist:NO] != nil);
}

#pragma mark - Private Methods

- (NSString *)_cellTypeForSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:section ofClass:@"NSDictionary"];
    return [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
}

- (void)_requestSuppliesButtonPressed {
    
    NSString *clusterName = [[HCRDataSource iraqDomizCampData] objectForKey:@"Name" ofClass:@"NSString"];
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
//    healthTallySheet.countryName = self.countryName;
    healthTallySheet.campData = self.campDictionary;
    healthTallySheet.campClusterData = self.campClusterData;
//    healthTallySheet.selectedClusterMetaData = self.selectedClusterMetaData;
    
    [self.navigationController pushViewController:healthTallySheet animated:YES];
    
}

- (void)_agencyButtonPressedAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *agencyArray = [self.campClusterData objectForKey:@"Agencies" ofClass:@"NSArray"];
    NSDictionary *agencyDictionary = [agencyArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    HCRContactViewController *contactController = [[HCRContactViewController alloc] initWithCollectionViewLayout:[HCRContactViewController preferredLayout]];
    
    contactController.agencyDictionary = agencyDictionary;
    
    [self.navigationController pushViewController:contactController animated:YES];
    
}

@end
