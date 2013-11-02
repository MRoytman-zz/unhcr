//
//  HCRCampOverviewController.h
//  UNHCR
//
//  Created by Sean Conrad on 11/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRCampOverviewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *campName;

@end
