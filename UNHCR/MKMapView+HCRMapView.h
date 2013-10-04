//
//  MKMapView+HCRMapView.h
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (HCRMapView)

+ (MKMapView *)mapViewWithFrame:(CGRect)frame latitude:(CGFloat)latitude longitude:(CGFloat)longitude span:(CGFloat)span;

@end
