//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/22/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRAlertCell : HCRCollectionCell

@property (nonatomic) BOOL read;
@property (nonatomic, strong) HCRAlert *alert;

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withAlert:(HCRAlert *)alert;

@end
