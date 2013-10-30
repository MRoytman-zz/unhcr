//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCREmergencyCell : HCRCollectionCell

@property (nonatomic) BOOL showLocation;
@property (nonatomic, strong) NSDictionary *emergencyDictionary;

+ (CGFloat)preferredCellHeight;
+ (CGFloat)preferredCellHeightWithoutLocation;

@end
