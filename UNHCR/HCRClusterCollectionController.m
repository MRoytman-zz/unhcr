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
    cell.clusterName = [[clustersArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
    cell.clusterImagePath = [[clustersArray objectAtIndex:indexPath.row] objectForKey:@"Image"];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:kClusterHeaderIdentifier
                                                                                     forIndexPath:indexPath];
        
        if (header.subviews) {
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
        // TODO: add 'snapshot' button/link/whatever
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

@end
