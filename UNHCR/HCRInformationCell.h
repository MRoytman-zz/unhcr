//
//  HCRInformationCell.h
//  UNHCR
//
//  Created by Sean Conrad on 11/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRInformationCell : HCRCollectionCell

@property (nonatomic, strong) NSArray *stringArray;

@property (nonatomic, readonly) UIButton *hyperlinkButton;

+ (CGSize)sizeForItemInCollectionView:(UICollectionView *)collectionView withStringArray:(NSArray *)stringArray;

@end
