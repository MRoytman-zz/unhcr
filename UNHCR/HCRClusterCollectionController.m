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
    [clusterLayout setDisplayHeader:YES withSize:CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                                            [HCRClusterFlowLayout preferredHeaderHeight])];
    [clusterLayout setDisplayFooter:YES withSize:CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                                            [HCRClusterFlowLayout preferredFooterHeight])];
    
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
    return [HCRDataSource clusterImagesArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kClusterCellIdentifier forIndexPath:indexPath];
    
    NSArray *clustersArray = [HCRDataSource clusterImagesArray];
    cell.clusterDictionary = [clustersArray objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:kClusterHeaderIdentifier
                                                                                     forIndexPath:indexPath];
        
        if (header.subviews.count > 0) {
            NSArray *subviews = [NSArray arrayWithArray:header.subviews];
            for (UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
        }
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
        [header addSubview:headerLabel];
        
        headerLabel.text = @"Clusters";
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.7];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                              withReuseIdentifier:kClusterFooterIdentifier
                                                                                     forIndexPath:indexPath];
        
        if (footer.subviews.count > 0) {
            NSArray *subviews = [NSArray arrayWithArray:footer.subviews];
            for (UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
        }
        
        UIButton *footerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [footer addSubview:footerButton];
        
        footerButton.frame = footer.bounds;
        footerButton.tintColor = [UIColor UNHCRBlue];
        
        [footerButton setTitle:@"Compare All Clusters" forState:UIControlStateNormal];
        footerButton.titleLabel.font = [UIFont systemFontOfSize:16];
        
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
    
    campClusterDetail.campDictionary = self.campDictionary;
    campClusterDetail.clusterDictionary = cell.clusterDictionary;
    
    [self.navigationController pushViewController:campClusterDetail animated:YES];
    
}

#pragma mark - Private Methods

- (void)_footerButtonPressed {
    
    // TODO: push special controller with everything
    
}

@end
