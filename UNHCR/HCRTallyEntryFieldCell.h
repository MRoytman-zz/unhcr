//
//  HCRTallyEntryFieldCell.h
//  UNHCR
//
//  Created by Sean Conrad on 11/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryFieldCell.h"

@interface HCRTallyEntryFieldCell : HCRDataEntryFieldCell

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withString:(NSString *)string;

@end
