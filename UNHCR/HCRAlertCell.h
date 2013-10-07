//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRAlertCell : UICollectionViewCell

@property (nonatomic) BOOL showLocation;
@property (nonatomic, strong) NSDictionary *alertDictionary;

+ (CGFloat)preferredCellHeight;
+ (CGFloat)preferredCellHeightWithoutLocation;

@end
