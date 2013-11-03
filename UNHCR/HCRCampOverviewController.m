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
#import "HCRTableCell.h"
#import "HCRRequestDataViewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kOverviewHeaderIdentifier = @"kOverviewHeaderIdentifier";
NSString *const kOverviewFooterIdentifier = @"kOverviewFooterIdentifier";

NSString *const kOverviewEmergencyCellIdentifier = @"kOverviewEmergencyCellIdentifier";
NSString *const kOverviewBulletinCellIdentifier = @"kOverviewBulletinCellIdentifier";
NSString *const kOverviewRequestsGraphCellIdentifier = @"kOverviewRequestsGraphCellIdentifier";
NSString *const kOverviewRequestsMoreInfoCellIdentifier = @"kOverviewRequestsMoreInfoCellIdentifier";
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

// DEBUG only?
@property (nonatomic, strong) NSArray *allMessagesDataArray;
@property NSDateFormatter *dateFormatter;

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
                            @{@"Header": kHeaderTitleRequests},
                            @{@"Header": kHeaderTitleBulletins},
                            @{@"Header": kHeaderTitleAgencies}
                            ];
        
        self.bulletinData = [HCRDataSource globalOnlyBulletinsData];
        self.emergencyData = [HCRDataSource globalEmergenciesData];
        
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:NO];
        
        self.highlightCells = YES;
        
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
    
    [self.collectionView registerClass:[HCRGraphCell class]
            forCellWithReuseIdentifier:kOverviewRequestsGraphCellIdentifier];
    
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kOverviewRequestsMoreInfoCellIdentifier];
    
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
    
    if ([sectionHeader isEqualToString:kHeaderTitleBulletins]) {
        return 3;
    } else if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        return 2;
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
        
        if (indexPath.row == 0) {
            
            HCRGraphCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewRequestsGraphCellIdentifier forIndexPath:indexPath];
            
            graphCell.graphDataSource = self;
            graphCell.graphDelegate = self;
            
            graphCell.dataLabel = @"All Requests";
            
            graphCell.xGraphTrailingSpace = 8.0; // hard-coded
            
            cell = graphCell;
            
        } else {
            
            HCRTableCell *tableCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewRequestsMoreInfoCellIdentifier forIndexPath:indexPath];
            
            tableCell.title = @"Explore Data";
            
            tableCell.badgeImage = [UIImage imageNamed:@"mixture-icon"];
            
            cell = tableCell;
        }
        
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

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionHeader = [self _headerForSection:indexPath.section];
    if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        if (indexPath.row == 1) {
            
            HCRRequestDataViewController *dataRequests = [[HCRRequestDataViewController alloc] initWithNibName:nil bundle:nil];
            
            dataRequests.campDictionary = [HCRDataSource iraqDomizCampData];
            
            [self.navigationController pushViewController:dataRequests animated:YES];
        }
    }
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
    } else if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        
        if (indexPath.row == 0) {
            return [HCRGraphCell preferredSizeForCollectionView:collectionView];
        } else {
            return [HCRTableCell preferredSizeForCollectionView:collectionView];
        }
        
    } else {
        return CGSizeZero;
    }
    
}

#pragma mark - SCGraphView Delegate

- (void)graphViewBeganTouchingData:(SCGraphView *)graphView withTouches:(NSSet *)touches {
    self.collectionView.scrollEnabled = NO;
}

- (void)graphViewStoppedTouchingData:(SCGraphView *)graphView {
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - SCGraphView DataSource

- (NSInteger)numberOfDataPointsInGraphView:(SCGraphView *)graphView {
    
    return self.allMessagesDataArray.count;
    
}

- (CGFloat)graphViewMinYValue:(SCGraphView *)graphView {
    return 0;
}

- (CGFloat)graphViewMaxYValue:(SCGraphView *)graphView {
    
    // http://stackoverflow.com/questions/3080540/finding-maximum-numeric-value-in-nsarray
    NSNumber *largestNumber = [self.allMessagesDataArray valueForKeyPath:@"@max.intValue"];
    CGFloat maxNumberWithPadding = largestNumber.floatValue * 1.1;
    
    return maxNumberWithPadding;
}

- (NSNumber *)graphView:(SCGraphView *)graphView dataPointForIndex:(NSInteger)index {
    
    return [self.allMessagesDataArray objectAtIndex:index ofClass:@"NSNumber"];
    
}

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index {
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((self.allMessagesDataArray.count - (index + 1)) * 60 * 60 * 24);
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];
    
    NSString *dateString = [self.dateFormatter stringFromDate:targetDate];
    
    return dateString;
    
}

#pragma mark - Getters & Setters

- (NSArray *)allMessagesDataArray {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDataPoints = 7;
    static const CGFloat kDataPointBaseline = 50.0;
    static const CGFloat kDataPointRange = 50.0;
    static const CGFloat kDataPointIncrement = 6.0;
    
    if ( ! _allMessagesDataArray ) {
        
        NSMutableArray *randomMessagesArray = @[].mutableCopy;
            
        for (NSInteger i = 0; i < kNumberOfDataPoints; i++) {
            CGFloat nextValue = kDataPointBaseline + (i * kDataPointIncrement) + arc4random_uniform(kDataPointRange);
            [randomMessagesArray addObject:@(nextValue)];
        }
        
        _allMessagesDataArray = randomMessagesArray;
    }
    
    return _allMessagesDataArray;
    
}

#pragma mark - Private Methods

- (NSString *)_headerForSection:(NSInteger)section {
    NSDictionary *sectionDictionary = [self.layoutData objectAtIndex:section ofClass:@"NSDictionary"];
    NSString *sectionHeader = [sectionDictionary objectForKey:@"Header" ofClass:@"NSString"];
    return sectionHeader;
}

@end
