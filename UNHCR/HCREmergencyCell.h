//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCREmergencyCell : HCRCollectionCell

@property (nonatomic) BOOL showEmergencyBanner;
@property (nonatomic, strong) NSDictionary *emergencyDictionary;

+ (CGSize)preferredSizeWithEmergencyBannerForCollectionView:(UICollectionView *)collectionView;

@end
