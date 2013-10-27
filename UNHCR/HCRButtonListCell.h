//
//  HCRCampClusterButtonListCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRButtonListCell : HCRCollectionCell

@property (nonatomic, readonly) UIButton *listButton;
@property (nonatomic, strong) NSString *listButtonTitle;

@property (nonatomic) BOOL showCellDivider;

+ (CGFloat)preferredCellHeight;

@end
