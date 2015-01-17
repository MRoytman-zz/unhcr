//
//  HCRRequestDataViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 11/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCGraphView.h"

@interface HCRRequestDataViewController : UIViewController
<UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
SCGraphViewDataSource,
SCGraphViewDelegate>

@property (nonatomic, strong) NSDictionary *campDictionary;

@end
