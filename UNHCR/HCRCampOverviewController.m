//
//  HCRCampOverviewController.m
//  UNHCR
//
//  Created by Sean Conrad on 11/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampOverviewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRCollectionCell.h"
#import "HCREmergencyCell.h"
#import "HCRBulletinCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kOverviewHeaderIdentifier = @"kOverviewHeaderIdentifier";
NSString *const kOverviewFooterIdentifier = @"kOverviewFooterIdentifier";

NSString *const kOverviewEmergencyCellIdentifier = @"kOverviewEmergencyCellIdentifier";
NSString *const kOverviewBulletinCellIdentifier = @"kOverviewBulletinCellIdentifier";
NSString *const kOverviewRequestsCellIdentifier = @"kOverviewRequestsCellIdentifier";
NSString *const kOverviewClusterCellIdentifier = @"kOverviewClusterCellIdentifier";

NSString *const kHeaderTitleEmergencies = @"Emergencies";
NSString *const kHeaderTitleBulletins = @"Bulletins";
NSString *const kHeaderTitleRequests = @"Refugee Requests";
NSString *const kHeaderTitleAgencies = @"Agencies & Tools";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampOverviewController ()

@property NSArray *layoutData;
@property NSArray *bulletinData;
@property NSArray *emergencyData;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampOverviewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.layoutData = @[
                            @{@"Header": kHeaderTitleEmergencies},
                            @{@"Header": kHeaderTitleBulletins},
                            @{@"Header": kHeaderTitleRequests},
                            @{@"Header": kHeaderTitleAgencies}
                            ];
        
        self.bulletinData = [HCRDataSource globalOnlyBulletinsData];
        self.emergencyData = [HCRDataSource globalEmergenciesData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.campName);
    
    self.title = self.campName;
    
    // LAYOUT AND REUSABLES
//    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
//    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [self.collectionView registerClass:[HCREmergencyCell class]
            forCellWithReuseIdentifier:kOverviewEmergencyCellIdentifier];
    
    [self.collectionView registerClass:[HCRBulletinCell class]
            forCellWithReuseIdentifier:kOverviewBulletinCellIdentifier];
    
    [self.collectionView registerClass:[HCRCollectionCell class]
            forCellWithReuseIdentifier:kOverviewRequestsCellIdentifier];
    
    [self.collectionView registerClass:[HCRCollectionCell class]
            forCellWithReuseIdentifier:kOverviewClusterCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kOverviewHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kOverviewFooterIdentifier];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.layoutData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSString *sectionHeader = [self _headerForSection:section];
    
    if ([sectionHeader isEqualToString:kOverviewBulletinCellIdentifier]) {
        return 3;
    } else {
        return 1;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    NSString *sectionHeader = [self _headerForSection:indexPath.section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleEmergencies]) {
        
        HCREmergencyCell *emergencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewEmergencyCellIdentifier forIndexPath:indexPath];
        
        emergencyCell.showEmergencyBanner = YES;
        emergencyCell.emergencyDictionary = [self.emergencyData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        
        cell = emergencyCell;
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleBulletins]) {
        
        HCRBulletinCell *bulletinCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewBulletinCellIdentifier forIndexPath:indexPath];
        
        bulletinCell.bulletinDictionary = [self.bulletinData objectAtIndex:indexPath.row];
        
        cell = bulletinCell;
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewRequestsCellIdentifier
                                                         forIndexPath:indexPath];
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewClusterCellIdentifier
                                                         forIndexPath:indexPath];
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kOverviewHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        NSString *sectionHeader = [self _headerForSection:indexPath.section];
        BOOL isEmergencySection = [sectionHeader isEqualToString:kHeaderTitleEmergencies];
        if (!isEmergencySection) {
            header.titleString = [self _headerForSection:indexPath.section];
        }
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kOverviewFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    NSString *sectionHeader = [self _headerForSection:section];
    BOOL isEmergencySection = [sectionHeader isEqualToString:kHeaderTitleEmergencies];
    
    return (isEmergencySection) ? [HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:collectionView] : [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    BOOL isLastSection = (section == [collectionView numberOfSections] - 1);
    
    return (isLastSection) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionHeader = [self _headerForSection:indexPath.section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleEmergencies]) {
        return [HCREmergencyCell preferredSizeWithEmergencyBannerForCollectionView:collectionView];
    } else if ([sectionHeader isEqualToString:kHeaderTitleBulletins]) {
        return [HCRBulletinCell sizeForCellInCollectionView:collectionView
                                     withBulletinDictionary:[self.bulletinData objectAtIndex:indexPath.row ofClass:@"NSDictionary"]];
    } else {
        return CGSizeZero;
    }
    
}

#pragma mark - Private Methods

- (NSString *)_headerForSection:(NSInteger)section {
    NSDictionary *sectionDictionary = [self.layoutData objectAtIndex:section ofClass:@"NSDictionary"];
    NSString *sectionHeader = [sectionDictionary objectForKey:@"Header" ofClass:@"NSString"];
    return sectionHeader;
}

@end
