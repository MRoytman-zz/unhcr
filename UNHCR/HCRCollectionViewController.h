//
//  HCRCollectionViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HCRCollectionViewController : UICollectionViewController
<UICollectionViewDelegate>

@property (nonatomic) BOOL highlightCells;

+ (UICollectionViewLayout *)preferredLayout;

@end
