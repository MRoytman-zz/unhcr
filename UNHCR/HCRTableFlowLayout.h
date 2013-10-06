//
//  HCRTableFlowLayout.h
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFlowLayout.h"

@interface HCRTableFlowLayout : HCRFlowLayout

+ (CGSize)preferredTableFlowCellSizeForCollectionView:(UICollectionView *)collectionView;

+ (CGSize)preferredTableFlowSingleLineCellSizeForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredTableFlowDoubleLineCellSizeForCollectionView:(UICollectionView *)collectionView;

@end
