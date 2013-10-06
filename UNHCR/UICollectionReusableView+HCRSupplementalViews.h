//
//  UICollectionReusableView+HCRSupplementalViews.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionReusableView (HCRSupplementalViews)

+ (UICollectionReusableView *)headerForUNHCRCollectionView:(UICollectionView *)collectionView
                                                identifier:(NSString *)identifier
                                                 indexPath:(NSIndexPath *)indexPath
                                                     title:(NSString *)title;

+ (UICollectionReusableView *)footerForUNHCRGraphCellWithCollectionCollection:(UICollectionView *)collectionView
                                                                   identifier:(NSString *)identifier
                                                                    indexPath:(NSIndexPath *)indexPath;

@end
