//
//  HCRCampCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRCampCollectionViewController.h"
#import "HCRCampCollectionCell.h"
#import "HCRTableFlowLayout.h"
#import "HCRCampDetailController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampCellIdentifier = @"kCampCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampCollectionViewController ()

@property NSDictionary *globalCampsDictionary;
@property NSDictionary *targetCountryDictionary;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.globalCampsDictionary = @{@"Iraq":
                                           @{ @"Latitude": @34,
                                              @"Longitude": @44,
                                              @"Span": @1750000,
                                              @"Camps": @[
                                                      @{@"Name": @"Domiz",
                                                        @"Latitude": @35.3923733,
                                                        @"Longitude": @44.3757963,
                                                        @"Span": @20000},
                                                      @{@"Name": @"Erbil",
                                                        @"Latitude": @36.1995815,
                                                        @"Longitude": @44.0226888,
                                                        @"Span": @20000},
                                                      @{@"Name": @"Sulaimaniya",
                                                        @"Latitude": @35.5626992,
                                                        @"Longitude": @45.4365392,
                                                        @"Span": @20000}]},
                                       
                                       @"Uganda":
                                           @{ @"Latitude": @1,
                                              @"Longitude": @32,
                                              @"Span": @1000000,
                                              @"Camps": @[
                                                      @{@"Name": @"Nakivale",
                                                        @"Latitude": @-0.6041135,
                                                        @"Longitude": @30.6517214,
                                                        @"Span": @10000}]},
                                       
                                       @"Thailand":
                                           @{ @"Latitude": @15,
                                              @"Longitude": @101.5,
                                              @"Span": @1500000,
                                              @"Camps": @[
                                                      @{@"Name": @"Umpiem Mar",
                                                        @"Latitude": @16.6047072,
                                                        @"Longitude": @98.6652615,
                                                        @"Span": @20000}]}};
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.country);
    
    self.title = self.country;
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    [self.collectionView registerClass:[HCRCampCollectionCell class]
            forCellWithReuseIdentifier:kCampCellIdentifier];

    // TODO: weird; not sure why self.view.frame is necessary instead of self.view.bounds..?
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    
    mapView.mapType = MKMapTypeHybrid;
    
    CGFloat latitude = [[self.targetCountryDictionary objectForKey:@"Latitude"] floatValue];
    CGFloat longitude = [[self.targetCountryDictionary objectForKey:@"Longitude"] floatValue];
    CGFloat span = [[self.targetCountryDictionary objectForKey:@"Span"] floatValue];
    
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance latitudinalMeters = span;
    CLLocationDistance longitudinalMeters = span;
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudinalMeters, longitudinalMeters);
    mapView.region = mapRegion;
    
    [self.view addSubview:mapView];
    [self.view sendSubviewToBack:mapView];
    
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *campsArray = [self.targetCountryDictionary objectForKey:@"Camps"];
    return campsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCampCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCampCellIdentifier forIndexPath:indexPath];
    
    NSArray *campsArray = [self.targetCountryDictionary objectForKey:@"Camps"];
    cell.campDictionary = [campsArray objectAtIndex:indexPath.row];
    
    return cell;
    
}

#pragma mark - UICollectionViewController Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCampCollectionCell *cell = (HCRCampCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCampCollectionCell class]]);
    
    HCRTableFlowLayout *tableLayout = [[HCRTableFlowLayout alloc] init];
    HCRCampDetailController *campDetail = [[HCRCampDetailController alloc] initWithCollectionViewLayout:tableLayout];
    campDetail.campDictionary = cell.campDictionary;
    
    [self.navigationController pushViewController:campDetail animated:YES];
    
}

#pragma mark - Getters & Setters

- (void)setCountry:(NSString *)country {
    
    _country = country;
    
    self.targetCountryDictionary = [self.globalCampsDictionary objectForKey:country];
}

@end
