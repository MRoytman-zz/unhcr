//
//  HCRCampClusterCompareViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterCompareViewController.h"
#import "HCRDataSource.h"
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
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.campDictionary);
    
    self.title = @"Compare Clusters";
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    [self.collectionView registerClass:[HCRGraphCell class]
            forCellWithReuseIdentifier:kCampClusterCompareCellIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampClusterCompareHeaderIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCampClusterCompareFooterIdentifier];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRTableFlowLayout preferredHeaderSizeForCollectionView:self.collectionView]];
    tableLayout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                      [HCRGraphCell preferredHeightForGraphCell]);
    
    // TODO: weird; not sure why self.view.frame is necessary instead of self.view.bounds..?
    MKMapView *mapView = [MKMapView mapViewWithFrame:self.view.frame
                                            latitude:[[self.campDictionary objectForKey:@"Latitude"] floatValue]
                                           longitude:[[self.campDictionary objectForKey:@"Longitude"] floatValue]
                                                span:[[self.campDictionary objectForKey:@"Span"] floatValue]];
    
    [self.view insertSubview:mapView atIndex:0];
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
        
        UICollectionReusableView *header = [UICollectionReusableView headerForUNHCRCollectionView:collectionView
                                                                                       identifier:kCampClusterCompareHeaderIdentifier
                                                                                        indexPath:indexPath
                                                                                            title:titleString];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [UICollectionReusableView footerForUNHCRGraphCellWithCollectionCollection:collectionView
                                                                                                          identifier:kCampClusterCompareFooterIdentifier
                                                                                                           indexPath:indexPath];
        
        if (indexPath.section != 0) {
            UIButton *footerButton = [UIButton footerButtonForUNHCRGraphCellInFooter:footer title:@"See More"];
            [footer addSubview:footerButton];
            
            footerButton.tag = indexPath.section;
            
            [footerButton addTarget:self
                             action:@selector(_footerButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
        }
        
        return footer;
        
    }
    
    return nil;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRGraphCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterCompareCellIdentifier forIndexPath:indexPath];
    
    return cell;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return [HCRTableFlowLayout preferredFooterSizeForCollectionView:collectionView];
    } else {
        return [HCRTableFlowLayout preferredFooterSizeForGraphCellInCollectionView:collectionView];
    }
    
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