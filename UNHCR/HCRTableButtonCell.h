//
//  HCRCampClusterButtonListCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRTableButtonCell : HCRCollectionCell

@property (nonatomic, readonly) UIButton *tableButton;
@property (nonatomic, strong) NSString *tableButtonTitle;

+ (CGFloat)preferredCellHeight;

@end
