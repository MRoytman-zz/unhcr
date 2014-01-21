//
//  HCRCollectionViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HCRHeaderView.h"
#import "HCRFooterView.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

extern NSString *const kLayoutCells;
extern NSString *const kLayoutCellLabel;
extern NSString *const kLayoutCellID;
extern NSString *const kLayoutHeaderLabel;
extern NSString *const kLayoutFooterLabel;

////////////////////////////////////////////////////////////////////////////////

@class HCRCollectionCell;

@interface HCRCollectionViewController : UICollectionViewController
<UICollectionViewDelegate>

@property (nonatomic) BOOL highlightCells;

+ (UICollectionViewLayout *)preferredLayout;

@end
