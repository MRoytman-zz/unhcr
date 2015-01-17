//
//  HCRCampClusterDetailViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRClusterToolsViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *campDictionary;
@property (nonatomic, strong) NSDictionary *selectedCluster;

@end
