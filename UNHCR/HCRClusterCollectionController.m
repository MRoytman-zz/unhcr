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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    
    mapView.mapType = MKMapTypeHybrid;
    
    CGFloat latitude = [[self.campDictionary objectForKey:@"Latitude"] floatValue];
    CGFloat longitude = [[self.campDictionary objectForKey:@"Longitude"] floatValue];
    CGFloat span = [[self.campDictionary objectForKey:@"Span"] floatValue];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance latitudinalMeters = span;
    CLLocationDistance longitudinalMeters = span;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudinalMeters, longitudinalMeters);
    mapView.region = mapRegion;
    
    [self.view addSubview:mapView];
    [self.view sendSubviewToBack:mapView];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [HCRDataSource clustersArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kClusterCellIdentifier forIndexPath:indexPath];
    
    NSArray *clustersArray = [HCRDataSource clustersArray];
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
        
        UIButton *footerButton = [[UIButton alloc] initWithFrame:footer.bounds];
        [footer addSubview:footerButton];
        
        [footerButton setTitle:@"Compare All Clusters" forState:UIControlStateNormal];
        
        [footerButton setTitleColor:[UIColor UNHCRBlue] forState:UIControlStateNormal];
        [footerButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        
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
    
    HCRFlowLayout *flowLayout = [[HCRFlowLayout alloc] init];
    HCRCampClusterDetailViewController *campClusterDetail = [[HCRCampClusterDetailViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    campClusterDetail.campDictionary = self.campDictionary;
    campClusterDetail.clusterDictionary = cell.clusterDictionary;
    
    [self.navigationController pushViewController:campClusterDetail animated:YES];
    
}

#pragma mark - Private Methods

- (void)_footerButtonPressed {
    
    // TODO: push special controller with everything
    
}

@end
