//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCREmergencyCell : HCRCollectionCell

@property (nonatomic, readonly) UIButton *emailContactButton;
@property (nonatomic, strong) NSDictionary *emergencyDictionary;

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withEmergencyDictionary:(NSDictionary *)emergencyDictionary;

@end
