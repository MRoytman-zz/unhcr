//
//  HCRRequestDataViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 11/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRRequestDataViewController.h"
#import "HCRCollectionViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableCell.h"
#import "EASoundManager.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kRequestListCellIdentifier = @"kRequestListCellIdentifier";
NSString *const kRequestListHeaderIdentifier = @"kRequestListHeaderIdentifier";
NSString *const kRequestListFooterIdentifier = @"kRequestListFooterIdentifier";

static const CGFloat kGraphHeight = 200.0;
static const CGFloat kGraphContainerPadding = 8.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRRequestDataViewController ()

@property NSArray *clusterCompareDataArray;

@property NSDateFormatter *dateFormatterPlain;
@property NSDateFormatter *dateFormatterTimeStamp;

@property HCRCollectionViewController *dataPicker;
@property SCGraphView *graphView;

@property (nonatomic) NSArray *messagesReceivedArrays;
@property (nonatomic) NSIndexPath *selectedClusterIndexPath;

@property NSInteger selectedDateIndex;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRRequestDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSMutableArray *clusterData = [HCRDataSource clusterLayoutMetaDataArray].mutableCopy;
        [clusterData insertObject:@{@"Name": @"All Clusters"} atIndex:0];
        
        self.clusterCompareDataArray = clusterData;
        
        self.dateFormatterPlain = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMM forceEuropeanFormat:YES];
        self.dateFormatterTimeStamp = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatddMMMHHmm forceEuropeanFormat:YES];
        
        [[EASoundManager sharedSoundManager] registerSoundIDs:@[@(EASoundIDClick1)]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Refugee Requests";
    
    // DATA PICKER
    HCRTableFlowLayout *layout = [HCRTableFlowLayout new];
    self.dataPicker = [[HCRCollectionViewController alloc] initWithCollectionViewLayout:layout];
    [self addChildViewController:self.dataPicker];
    [self.view addSubview:self.dataPicker.view];
    
    self.dataPicker.view.frame = CGRectMake(0,
                                            0,
                                            CGRectGetWidth(self.view.bounds),
                                            CGRectGetHeight(self.view.bounds));
    
    self.dataPicker.collectionView.contentInset = UIEdgeInsetsMake(0, 0, kGraphHeight, 0);
    
    self.dataPicker.collectionView.backgroundColor = [UIColor tableBackgroundColor];
    
    self.dataPicker.collectionView.delegate = self;
    self.dataPicker.collectionView.dataSource = self;
    
    self.dataPicker.highlightCells = YES;
    
    // DATA PICKER LAYOUT STUFF
    [layout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:self.dataPicker.collectionView]];
    
    [layout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.dataPicker.collectionView]];
    
    [self.dataPicker.collectionView registerClass:[HCRTableCell class]
                       forCellWithReuseIdentifier:kRequestListCellIdentifier];
    
    [self.dataPicker.collectionView registerClass:[HCRHeaderView class]
                       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                              withReuseIdentifier:kRequestListHeaderIdentifier];
    
    [self.dataPicker.collectionView registerClass:[HCRFooterView class]
                       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                              withReuseIdentifier:kRequestListFooterIdentifier];
    
    // GRAPH CONTAINER
    UIView *graphContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      CGRectGetHeight(self.view.bounds) - kGraphHeight,
                                                                      CGRectGetWidth(self.view.bounds),
                                                                      kGraphHeight)];
    [self.view addSubview:graphContainer];
    
    graphContainer.backgroundColor = [UIColor whiteColor];
    graphContainer.layer.borderColor = [UIColor tableDividerColor].CGColor;
    graphContainer.layer.borderWidth = 1.0;
    
    // GRAPH VIEW
    CGRect graphViewFrame = UIEdgeInsetsInsetRect(graphContainer.bounds,
                                                  UIEdgeInsetsMake(0,
                                                                   kGraphContainerPadding,
                                                                   0,
                                                                   kGraphContainerPadding));
    self.graphView = [[SCGraphView alloc] initWithFrame:graphViewFrame];
    [graphContainer addSubview:self.graphView];
    
    self.graphView.delegate = self;
    self.graphView.dataSource = self;
    
    // OTHER
    self.selectedClusterIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.clusterCompareDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kRequestListCellIdentifier
                                                                   forIndexPath:indexPath];
    
    NSDictionary *rowDictionary = [self.clusterCompareDataArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    cell.title = [rowDictionary objectForKey:@"Name" ofClass:@"NSString"];
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:indexPath.row];
    cell.detailNumber = [dataPointArray objectAtIndex:self.selectedDateIndex ofClass:@"NSNumber"];
    
    if ([indexPath isEqual:self.selectedClusterIndexPath]) {
        cell.contentView.backgroundColor = [UIColor tableSelectedCellColor];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kRequestListHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kRequestListFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedClusterIndexPath) {
        [self _unhighlightCellInCollectionView:collectionView atIndexPath:self.selectedClusterIndexPath];
    }
    
    self.selectedClusterIndexPath = indexPath;
    [self _highlightCellInCollectionView:collectionView atIndexPath:indexPath];
    
    [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDClick1];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self _unhighlightCellInCollectionView:collectionView atIndexPath:indexPath];
    
    self.selectedClusterIndexPath = nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self _highlightCellInCollectionView:collectionView atIndexPath:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self _unhighlightCellInCollectionView:collectionView atIndexPath:indexPath];
    
}

#pragma mark - SCGraphView Delegate

- (void)graphViewBeganTouchingData:(SCGraphView *)graphView withTouches:(NSSet *)touches {
    self.dataPicker.collectionView.scrollEnabled = NO;
}

- (void)graphViewStoppedTouchingData:(SCGraphView *)graphView {
    self.dataPicker.collectionView.scrollEnabled = YES;
}

- (void)graphView:(SCGraphView *)graphView didChangeSelectedIndex:(NSInteger)selectedIndex {
    
    self.selectedDateIndex = selectedIndex;
    [self.dataPicker.collectionView reloadData];
    
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

- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index withTimeStamp:(BOOL)showTimeStamp {
    
    NSArray *dataPointArray = [self.messagesReceivedArrays objectAtIndex:graphView.tag];
    
    // go back [index] days since today
    NSTimeInterval numberOfSecondsToTargetDate = ((dataPointArray.count - (index + 1)) * 60 * 60 * 24) / 4.5;
    NSDate *targetDate = [NSDate dateWithTimeIntervalSinceNow:(-1 * numberOfSecondsToTargetDate)];
    
    NSDateFormatter *formatter = (showTimeStamp) ? self.dateFormatterTimeStamp : self.dateFormatterPlain;
    NSString *dateString = [formatter stringFromDate:targetDate];
    
    return dateString;
    
}

#pragma mark - Getters & Setters

- (void)setSelectedClusterIndexPath:(NSIndexPath *)selectedIndexPath {
    
    _selectedClusterIndexPath = selectedIndexPath;
    
    NSInteger selectedRow = selectedIndexPath.row;
    
    NSDictionary *labelDictionary = [self.clusterCompareDataArray objectAtIndex:selectedRow ofClass:@"NSDictionary"];
    self.graphView.dataLabelString = [labelDictionary objectForKey:@"Name" ofClass:@"NSString"];
    
    self.graphView.tag = selectedRow;
    
    [self.graphView setNeedsDisplay];
    
}

- (NSArray *)messagesReceivedArrays {
    
    // TODO: debug only - need to retrieve live data
    static const NSInteger kNumberOfDaysToShow = 7;
    static const NSInteger kNumberOfDataPoints = kNumberOfDaysToShow * 4.5;
    static const CGFloat kDataPointBaseline = 50.0;
    static const CGFloat kDataPointRange = 50.0;
    static const CGFloat kDataPointIncrement = 6.0;
    
    if ( ! _messagesReceivedArrays ) {
        
        NSMutableArray *allArrays = @[].mutableCopy;
        
        for (NSInteger topInt = 0; topInt < self.clusterCompareDataArray.count; topInt++) {
            
            CGFloat multiplier = (topInt > 0) ? 1.0 : self.clusterCompareDataArray.count - 1;
            NSMutableArray *randomMessagesArray = @[].mutableCopy;
            
            for (NSInteger i = 0; i < kNumberOfDataPoints; i++) {
                
                CGFloat nextValue = multiplier * (kDataPointBaseline + (i * kDataPointIncrement) + arc4random_uniform(kDataPointRange));
                [randomMessagesArray addObject:@(nextValue)];
            }
            
            [allArrays addObject:randomMessagesArray];
        }
        
        _messagesReceivedArrays = allArrays;
    }
    
    return _messagesReceivedArrays;
    
}

#pragma mark - Private Methods

- (void)_highlightCellInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    HCRTableCell *tableCell = (HCRTableCell *)[collectionView cellForItemAtIndexPath:indexPath];
    tableCell.contentView.backgroundColor = [UIColor tableSelectedCellColor];
}

- (void)_unhighlightCellInCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    HCRTableCell *tableCell = (HCRTableCell *)[collectionView cellForItemAtIndexPath:indexPath];
    tableCell.contentView.backgroundColor = [UIColor whiteColor];
}

@end
