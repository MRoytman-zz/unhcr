//
//  HCRCampClusterCompareViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRCampClusterCompareViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSDictionary *campDictionary;

@end
