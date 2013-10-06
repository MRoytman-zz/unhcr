//
//  HCRCampClusterDetailViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRCampClusterDetailViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *campDictionary;
@property (nonatomic, strong) NSDictionary *selectedClusterMetaData;

@end
