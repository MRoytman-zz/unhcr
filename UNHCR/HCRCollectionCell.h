//
//  HCRCollectionCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/27/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRCollectionCell : UICollectionViewCell

@property (nonatomic) BOOL showCellDivider;
@property (nonatomic, readonly) UIView *bottomLineView;

+ (CGFloat)preferredIndentForContent;
+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredSizeForAppDescriptionCollectionCellForCollectionView:(UICollectionView *)collectionView;

- (void)setBottomLineStatusForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath;

@end
