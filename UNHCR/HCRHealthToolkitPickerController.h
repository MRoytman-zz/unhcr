//
//  HCRHealthTallySheetViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRHealthToolkitPickerController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSDictionary *campClusterData;

@end
