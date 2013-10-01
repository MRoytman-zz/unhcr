//
//  HCRCampDetailController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRCampDetailController.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampDetailController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampDetailController

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
    
//    [self.collectionView registerClass:[HCRCampCollectionCell class]
//            forCellWithReuseIdentifier:kCampCellIdentifier];
    
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

@end
