//
//  HCRHeaderTallyView.h
//  UNHCR
//
//  Created by Sean Conrad on 11/3/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHeaderView.h"

@interface HCRHeaderTallyView : HCRHeaderView

+ (CGSize)sizeForTallyHeaderInCollectionView:(UICollectionView *)collectionView withStringArray:(NSArray *)stringArray;

@property (nonatomic, strong) NSArray *stringArray;

@end
