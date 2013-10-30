//
//  HCRCampClusterCompareViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterCompareViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRGraphCell.h"
#import "HCRCampClusterDetailViewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampClusterCompareCellIdentifier = @"kCampClusterCompareCellIdentifier";
NSString *const kCampClusterCompareHeaderIdentifier = @"kCampClusterCompareHeaderIdentifier";
NSString *const kCampClusterCompareFooterIdentifier = @"kCampClusterCompareFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterCompareViewController ()

@property NSArray *clusterCompareDataArray;

@property NSDateFormatter *dateFormatter;

@property (nonatomic) NSArray *messagesReceivedArrays;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterCompareViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        NSMutableArray *clusterData = [HCRDataSource clusterLayoutMetaDataArray].mutableCopy;
        [clusterData insertObject:@{@"Name": @"All Clusters"} atIndex:0];
        
        self.clusterCompareDataArray = clusterData;
        
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatMMMdd];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.campDictionary);
    
    self.title = @"Compare Clusters";
    
    [self.collectionView registerClass:[HCRGraphCell class]
            forCellWithReuseIdentifier:kCampClusterCompareCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampClusterCompareHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCampClusterCompareFooterIdentifier];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    tableLayout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                      [HCRGraphCell preferredHeightForGraphCell]);
    tableLayout.footerReferenceSize = [HCRFooterView preferredFooterSizeWithGraphCellForCollectionView:self.collectionView];

}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.clusterCompareDataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSDictionary *clusterDictionary = [self.clusterCompareDataArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        NSString *titleString = [clusterDictionary objectForKey:@"Name" ofClass:@"NSString"];
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kCampClusterCompareHeaderIdentifier
                                                                          forIndexPath:indexPath];
        header.titleString = titleString;
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kCampClusterCompareFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        [footer setButtonType:HCRFooterButtonTypeRawData withButtonTitle:@"Raw Data"];
        
        footer.button.tag = indexPath.section;
        
        [footer.button addTarget:self
                          action:@selector(_footerButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
        
        return footer;
        
    }
    
    return nil;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRGraphCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterCompareCellIdentifier forIndexPath:indexPath];
    
    cell.graphView.tag = indexPath.section;
    cell.graphDataSource = self;
    cell.graphDelegate = self;
    
    return cell;
    
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
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:graphView.tag];
    return dataPointArray.count;
    
}

- (CGFloat)graphViewMinYValue:(SCGraphView *)graphView {
    return 0;
}

- (CGFloat)graphViewMaxYValue:(SCGraphView *)graphView {
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:graphView.tag];
    
    // http://stackoverflow.com/questions/3080540/finding-maximum-numeric-value-in-nsarray
    NSNumber *largestNumber = [dataPointArray valueForKeyPath:@"@max.intValue"];
    CGFloat maxNumberWithPadding = largestNumber.floatValue * 1.1;
    
    return maxNumberWithPadding;
}

- (NSNumber *)graphView:(SCGraphView *)graphView dataPointForIndex:(NSInteger)index {
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:graphView.tag];
    return [dataPointArray objectAtIndex:index];
    
}

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index {
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:graphView.tag];
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((dataPointArray.count - (index + 1)) * 60 * 60 * 24);
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];
    
    NSString *dateString = [self.dateFormatter stringFromDate:targetDate];
    
    return dateString;
    
}

#pragma mark - Getters & Setters

- (NSArray *)messagesReceivedArrays {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDataPoints = 30;
    static const CGFloat kDataPointBaseline = 50.0;
    static const CGFloat kDataPointRange = 50.0;
    static const CGFloat kDataPointIncrement = 6.0;
    
    if ( ! _messagesReceivedArrays ) {
        
        NSMutableArray *allArrays = @[].mutableCopy;
        
        for (NSInteger topInt = 0; topInt < self.clusterCompareDataArray.count; topInt++) {
            
            NSMutableArray *randomMessagesArray = @[].mutableCopy;
            
            for (NSInteger i = 0; i < kNumberOfDataPoints; i++) {
                CGFloat nextValue = kDataPointBaseline + (i * kDataPointIncrement) + arc4random_uniform(kDataPointRange);
                [randomMessagesArray addObject:@(nextValue)];
            }
            
            [allArrays addObject:randomMessagesArray];
        }
        
        _messagesReceivedArrays = allArrays;
    }
    
    return _messagesReceivedArrays;
    
}

#pragma mark - Private Methods

- (void)_footerButtonPressed:(UIButton *)button {
    
    HCRCampClusterDetailViewController *campClusterDetail = [[HCRCampClusterDetailViewController alloc] initWithCollectionViewLayout:[HCRCampClusterDetailViewController preferredLayout]];
    
    campClusterDetail.countryName = self.countryName;
    campClusterDetail.campDictionary = self.campDictionary;
    campClusterDetail.selectedClusterMetaData = [self.clusterCompareDataArray objectAtIndex:button.tag ofClass:@"NSDictionary"];
    
    [self.navigationController pushViewController:campClusterDetail animated:YES];
    
}

@end
