//
//  HCRAlertCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/22/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRTableCell.h"

@interface HCRAlertCell : HCRTableCell

@property (nonatomic, strong) HCRAlert *alert;

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withAlert:(HCRAlert *)alert;

@end
