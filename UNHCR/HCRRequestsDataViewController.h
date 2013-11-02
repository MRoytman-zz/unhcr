//
//  HCRCampClusterCompareViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "SCGraphView.h"

@interface HCRRequestsDataViewController : HCRCollectionViewController
<SCGraphViewDataSource,SCGraphViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *campDictionary;

@end
