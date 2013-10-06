//
//  HCRCampDetailController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRClusterCollectionController.h"
#import "HCRClusterFlowLayout.h"
#import "HCRClusterCollectionCell.h"
#import "HCRDataSource.h"
#import "HCRCampClusterDetailViewController.h"
#import "HCRCampClusterCompareViewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kClusterCellIdentifier = @"kClusterCellIdentifier";
NSString *const kClusterHeaderIdentifier = @"kClusterHeaderIdentifier";
NSString *const kClusterFooterIdentifier = @"kClusterFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRClusterCollectionController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterCollectionController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.campDictionary);
    
    self.title = [self.campDictionary objectForKey:@"Name"];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    HCRClusterFlowLayout *clusterLayout = (HCRClusterFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([clusterLayout isKindOfClass:[HCRClusterFlowLayout class]]);
    [clusterLayout setDisplayHeader:YES withSize:[HCRClusterFlowLayout preferredHeaderSizeForCollectionView:self.collectionView]];
    [clusterLayout setDisplayFooter:YES withSize:[HCRClusterFlowLayout preferredFooterSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRClusterCollectionCell class]
            forCellWithReuseIdentifier:kClusterCellIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kClusterHeaderIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kClusterFooterIdentifier];
    
    // TODO: weird; not sure why self.view.frame is necessary instead of self.view.bounds..?
    MKMapView *mapView = [MKMapView mapViewWithFrame:self.view.frame
                                            latitude:[[self.campDictionary objectForKey:@"Latitude"] floatValue]
                                           longitude:[[self.campDictionary objectForKey:@"Longitude"] floatValue]
                                                span:[[self.campDictionary objectForKey:@"Span"] floatValue]];
    
    [self.view insertSubview:mapView atIndex:0];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRClusterFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [HCRDataSource clusterLayoutMetaDataArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kClusterCellIdentifier forIndexPath:indexPath];
    
    NSArray *clustersArray = [HCRDataSource clusterLayoutMetaDataArray];
    cell.clusterDictionary = [clustersArray objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [UICollectionReusableView headerForUNHCRCollectionView:collectionView
                                                                                       identifier:kClusterHeaderIdentifier
                                                                                        indexPath:indexPath
                                                                                            title:@"Clusters"];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [UICollectionReusableView footerForUNHCRGraphCellWithCollectionCollection:collectionView
                                                                                                          identifier:kClusterFooterIdentifier
                                                                                                           indexPath:indexPath];
        
        CGSize buttonSize = CGSizeMake(180, CGRectGetHeight(footer.bounds));
        UIButton *footerButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Compare All Clusters"
                                                          horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                                         buttonSize:buttonSize
                                                                     fontSize:@16.0];
        [footer addSubview:footerButton];
        
        footerButton.center = CGPointMake(CGRectGetMidX(footer.bounds), CGRectGetMidY(footer.bounds));
        
        [footerButton addTarget:self
                         action:@selector(_footerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterCollectionCell *cell = (HCRClusterCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRClusterCollectionCell class]]);
    
    HCRCampClusterDetailViewController *campClusterDetail = [[HCRCampClusterDetailViewController alloc] initWithCollectionViewLayout:[HCRCampClusterDetailViewController preferredLayout]];
    
    campClusterDetail.countryName = self.countryName;
    campClusterDetail.campDictionary = self.campDictionary;
    campClusterDetail.selectedClusterMetaData = cell.clusterDictionary;
    
    [self.navigationController pushViewController:campClusterDetail animated:YES];
    
}

#pragma mark - Private Methods

- (void)_footerButtonPressed {
    
    HCRCampClusterCompareViewController *campClusterCompareController = [[HCRCampClusterCompareViewController alloc] initWithCollectionViewLayout:[HCRCampClusterCompareViewController preferredLayout]];
    campClusterCompareController.campDictionary = self.campDictionary;
    
    [self.navigationController pushViewController:campClusterCompareController animated:YES];
    
}

@end
