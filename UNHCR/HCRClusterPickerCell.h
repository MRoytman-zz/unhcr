//
//  HCRClusterCollectionCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRClusterPickerCell : UICollectionViewCell

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView;

@property (nonatomic, strong) NSDictionary *clusterDictionary;

@end
