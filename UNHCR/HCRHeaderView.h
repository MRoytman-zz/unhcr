//
//  HCRHeaderView.h
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRHeaderTitleStyle) {
    HCRHeaderTitleStyleDefault,
    HCRHeaderTitleStyleSubtitle,
    HCRHeaderTitleStyleThreeLine
};

////////////////////////////////////////////////////////////////////////////////

@interface HCRHeaderView : UICollectionReusableView

@property (nonatomic) HCRHeaderTitleStyle titleStyle;

@property (nonatomic, strong) NSString *titleString;

+ (CGSize)preferredHeaderSizeForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredHeaderSizeWithoutTitleForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredHeaderSizeWithoutTitleSmallForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredHeaderSizeWithLineOnlyForCollectionView:(UICollectionView *)collectionView;

@end
