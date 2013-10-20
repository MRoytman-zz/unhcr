//
//  HCRCampClusterDetailViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

#import "SCGraphView.h"

@interface HCRCampClusterDetailViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout, SCGraphViewDataSource, SCGraphViewDelegate>

@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSDictionary *campDictionary;
@property (nonatomic, strong) NSDictionary *selectedClusterMetaData;

@end
