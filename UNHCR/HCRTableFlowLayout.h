//
//  HCRTableFlowLayout.h
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFlowLayout.h"

@interface HCRTableFlowLayout : HCRFlowLayout

+ (CGSize)preferredTableFlowCellSizeForCollectionView:(UICollectionView *)collectionView numberOfLines:(NSNumber *)numberOfLines;

@end
