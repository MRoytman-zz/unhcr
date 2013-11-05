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
#import "HCRClusterPickerCell.h"
#import "HCRClusterToolsViewController.h"
#import "EAEmailUtilities.h"

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

static const CGFloat kUniversalClusterCollectionPadding = 10.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampOverviewController ()

@property NSArray *layoutData;
@property NSArray *bulletinData;
@property NSArray *emergencyData;

// TODO: make this better - see inline comments
@property UIView *hackyWorkaroundView;

// DEBUG only?
@property (nonatomic, strong) NSArray *allMessagesDataArray;
// DEBUG

@property NSDateFormatter *dateFormatterPlain;
@property NSDateFormatter *dateFormatterTimeStamp;

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
                            @{@"Header": kHeaderTitleAgencies},
                            @{@"Header": kHeaderTitleBulletins}
                            ];
        
        self.bulletinData = [HCRDataSource globalOnlyBulletinsData];
        self.emergencyData = [HCRDataSource globalEmergenciesData];
        
        self.dateFormatterPlain = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:YES];
        self.dateFormatterTimeStamp = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        
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
    
    [self.collectionView registerClass:[HCRClusterPickerCell class]
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
        return self.bulletinData.count;
    } else if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        return 2;
    } else if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        return [HCRDataSource clusterLayoutMetaDataArray].count;
    } else {
        return 1;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    NSString *sectionHeader = [self _headerForSection:indexPath.section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleEmergencies]) {
        
        HCREmergencyCell *emergencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewEmergencyCellIdentifier forIndexPath:indexPath];
        
        emergencyCell.emergencyDictionary = [self.emergencyData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        
        emergencyCell.emailContactButton.tag = indexPath.section;
        [emergencyCell.emailContactButton addTarget:self
                                             action:@selector(_emergencyEmailButtonPressed:)
                                   forControlEvents:UIControlEventTouchUpInside];
        
        cell = emergencyCell;
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleBulletins]) {
        
        HCRBulletinCell *bulletinCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewBulletinCellIdentifier forIndexPath:indexPath];
        
        bulletinCell.bulletinDictionary = [self.bulletinData objectAtIndex:indexPath.row];
        
        bulletinCell.replyButton.tag = indexPath.row;
        bulletinCell.forwardButton.tag = indexPath.row;
        
        [bulletinCell.replyButton addTarget:self
                                     action:@selector(_replyButtonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
        
        [bulletinCell.forwardButton addTarget:self
                                       action:@selector(_forwardButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
        
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
            
            tableCell.badgeImage = [[UIImage imageNamed:@"graph"] colorImage:[UIColor whiteColor]
                                                                  withBlendMode:kCGBlendModeNormal
                                                               withTransparency:YES];
            tableCell.badgeImageView.backgroundColor = [UIColor colorWithRed:104 / 255.0
                                                                       green:188 / 255.0
                                                                        blue:29 / 255.0
                                                                       alpha:1.0];
            
            cell = tableCell;
        }
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        
        HCRClusterPickerCell *clusterCell = [collectionView dequeueReusableCellWithReuseIdentifier:kOverviewClusterCellIdentifier
                                                                                      forIndexPath:indexPath];
        
        NSDictionary *clusterDictionary = [[HCRDataSource clusterLayoutMetaDataArray] objectAtIndex:indexPath.row];
        clusterCell.clusterDictionary = clusterDictionary;
        
        clusterCell.contentView.backgroundColor = [UIColor whiteColor];
        
        return clusterCell;
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
    } else if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        
        HCRClusterToolsViewController *clusterTools = [[HCRClusterToolsViewController alloc] initWithCollectionViewLayout:[HCRClusterToolsViewController preferredLayout]];
        
        clusterTools.campDictionary = [HCRDataSource iraqDomizCampData];
        clusterTools.selectedCluster = [[HCRDataSource clusterLayoutMetaDataArray] objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:clusterTools animated:YES];
        
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
        NSDictionary *emergencyDictionary = [self.emergencyData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        return [HCREmergencyCell sizeForCellInCollectionView:collectionView withEmergencyDictionary:emergencyDictionary];
    } else if ([sectionHeader isEqualToString:kHeaderTitleBulletins]) {
        NSDictionary *bulletinDictionary = [self.bulletinData objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
        return [HCRBulletinCell sizeForCellInCollectionView:collectionView withBulletinDictionary:bulletinDictionary];
    } else if ([sectionHeader isEqualToString:kHeaderTitleRequests]) {
        
        if (indexPath.row == 0) {
            return [HCRGraphCell preferredSizeForCollectionView:collectionView];
        } else {
            return [HCRTableCell preferredSizeForCollectionView:collectionView];
        }
        
    } else if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        return [HCRClusterPickerCell preferredSizeForCollectionView:collectionView];
    }
    
    return CGSizeZero;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSString *sectionHeader = [self _headerForSection:section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        static const CGFloat kClusterEdgeInsets = kUniversalClusterCollectionPadding;
        return UIEdgeInsetsMake(kClusterEdgeInsets, kClusterEdgeInsets, kClusterEdgeInsets, kClusterEdgeInsets);
    } else {
        HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)collectionViewLayout;
        return tableLayout.sectionInset;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    NSString *sectionHeader = [self _headerForSection:section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        return kUniversalClusterCollectionPadding;
    } else {
        HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)collectionViewLayout;
        return tableLayout.minimumInteritemSpacing;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSString *sectionHeader = [self _headerForSection:section];
    
    if ([sectionHeader isEqualToString:kHeaderTitleAgencies]) {
        return kUniversalClusterCollectionPadding;
    } else {
        HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)collectionViewLayout;
        return tableLayout.minimumLineSpacing;
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

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index withTimeStamp:(BOOL)showTimeStamp {
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((self.allMessagesDataArray.count - (index + 1)) * 60 * 60 * 24) / 4.5;
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];
    
    NSDateFormatter *formatter = (showTimeStamp) ? self.dateFormatterTimeStamp : self.dateFormatterPlain;
    NSString *dateString = [formatter stringFromDate:targetDate];
    
    return dateString;
    
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.hackyWorkaroundView) {
        // TODO: make this less hacky or get rid of it.. not sure how else to solve this problem, sadly
        NSInteger triggerSection = [self _sectionForHeader:kHeaderTitleAgencies];
        triggerSection = (triggerSection == 0) ? 0 : triggerSection - 1;
        
        NSInteger triggerItem = [self.collectionView numberOfItemsInSection:triggerSection] - 1;
        NSIndexPath *triggerIndexPath = [NSIndexPath indexPathForItem:triggerItem inSection:triggerSection];
        UICollectionViewCell *triggerCell = [self.collectionView cellForItemAtIndexPath:triggerIndexPath];
        
        if (triggerCell) {
            
            // ADD WHITE BACKGROUND TO CLUSTER PICKER SECTION
            // TODO: make not hacky; is there a way to show background on just one section of UICollectionView?
            CGFloat yOffsetForHackyView = CGRectGetMaxY(triggerCell.frame) + [HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView].height;
            
            self.hackyWorkaroundView = [[UIView alloc] initWithFrame:[self _hackyWorkaroundFrameAtYOffset:yOffsetForHackyView]];
            [self.collectionView insertSubview:self.hackyWorkaroundView atIndex:0];
            
            self.hackyWorkaroundView.backgroundColor = [UIColor whiteColor];
            
        }
    }
    
}

#pragma mark - Getters & Setters

- (NSArray *)allMessagesDataArray {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDaysToShow = 7;
    static const NSInteger kNumberOfDataPoints = kNumberOfDaysToShow * 4.5;
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

- (NSInteger)_sectionForHeader:(NSString *)header {
    
    for (NSDictionary *dictionary in self.layoutData) {
        NSString *headerString = [dictionary objectForKey:@"Header" ofClass:@"NSString"];
        
        if ([headerString isEqualToString:header]) {
            return [self.layoutData indexOfObject:dictionary];
        }
        
    }
    
    NSAssert(NO, @"No known section with header string.");
    return 0;
    
}

- (CGRect)_hackyWorkaroundFrameAtYOffset:(CGFloat)yOffset {
    
    CGPoint hackyOrigin = CGPointMake(0,
                                      yOffset);
    
    static const NSInteger kNumberOfCellsHigh = 4;
    CGSize hackySize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                  kNumberOfCellsHigh * (kUniversalClusterCollectionPadding + [HCRClusterPickerCell preferredSizeForCollectionView:self.collectionView].height) + kUniversalClusterCollectionPadding);
    
    CGRect hackyRect = CGRectMake(hackyOrigin.x,
                                  hackyOrigin.y,
                                  hackySize.width,
                                  hackySize.height);
    
    return hackyRect;
    
}

- (void)_replyButtonPressed:(UIButton *)sender {
    
    HCRBulletinCell *bulletinCell = (HCRBulletinCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:[self _sectionForHeader:kHeaderTitleBulletins]]];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[[bulletinCell emailSenderString]]
                                                withSubjectText:[bulletinCell emailSubjectStringWithPrefix:@"[RIS] RE:"]
                                                   withBodyText:[bulletinCell emailBodyString]
                                                 withCompletion:nil];
    
}

- (void)_forwardButtonPressed:(UIButton *)sender {
    
    HCRBulletinCell *bulletinCell = (HCRBulletinCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:[self _sectionForHeader:kHeaderTitleBulletins]]];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:nil
                                                withSubjectText:[bulletinCell emailSubjectStringWithPrefix:@"[RIS] FWD:"]
                                                   withBodyText:[bulletinCell emailBodyString]
                                                 withCompletion:nil];
    
}

- (void)_emergencyEmailButtonPressed:(UIButton *)emailButton {
    
    NSDictionary *emergencyDictionary = [self.emergencyData objectAtIndex:emailButton.tag ofClass:@"NSDictionary"];
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                        withEmergencyDictionary:emergencyDictionary
                                                 withCompletion:nil];
    
}

@end
