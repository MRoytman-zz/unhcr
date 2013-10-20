//
//  HCRGraphCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCGraphView.h"

@interface HCRGraphCell : UICollectionViewCell

+ (CGFloat)preferredHeightForGraphCell;

@property (nonatomic, weak) id<SCGraphViewDataSource> graphDataSource;

@end
