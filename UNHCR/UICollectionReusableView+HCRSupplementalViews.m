//
//  UICollectionReusableView+HCRSupplementalViews.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "UICollectionReusableView+HCRSupplementalViews.h"

@implementation UICollectionReusableView (HCRSupplementalViews)

+ (UICollectionReusableView *)headerForUNHCRCollectionView:(UICollectionView *)collectionView identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath title:(NSString *)title {
    
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:identifier
                                                                                 forIndexPath:indexPath];
    
    if (header.subviews.count > 0) {
        NSArray *subviews = [NSArray arrayWithArray:header.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
    }
    
    header.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.7];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
    [header addSubview:headerLabel];
    
    headerLabel.text = title;
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    return header;
    
}

+ (UICollectionReusableView *)footerForUNHCRGraphCellWithCollectionCollection:(UICollectionView *)collectionView identifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                          withReuseIdentifier:identifier
                                                                                 forIndexPath:indexPath];
    
    if (footer.subviews.count > 0) {
        NSArray *subviews = [NSArray arrayWithArray:footer.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
    }
    
    return footer;
    
}

@end
