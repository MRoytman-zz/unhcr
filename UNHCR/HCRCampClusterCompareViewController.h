//
//  HCRCampClusterCompareViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "SCGraphView.h"

@interface HCRCampClusterCompareViewController : HCRCollectionViewController
<SCGraphViewDataSource,SCGraphViewDelegate>

@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSDictionary *campDictionary;

@end
