//
//  MKMapView+HCRMapView.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "MKMapView+HCRMapView.h"

@implementation MKMapView (HCRMapView)

+ (MKMapView *)mapViewWithFrame:(CGRect)frame latitude:(CGFloat)latitude longitude:(CGFloat)longitude span:(CGFloat)span {
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:frame];
    
    mapView.mapType = MKMapTypeHybrid;
    
    MKCoordinateRegion mapRegion;
    if (latitude == 0 && longitude == 0 && span == 0) {
        mapRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);
    } else {
        CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocationDistance latitudinalMeters = span;
        CLLocationDistance longitudinalMeters = span;
        mapRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, latitudinalMeters, longitudinalMeters);
    }
    
    mapView.region = mapRegion;
    
    return mapView;
    
}

@end
