//
//  HCRHeaderView.h
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

@interface HCRHeaderView : UICollectionReusableView

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *subtitleString;
@property (nonatomic, strong) NSString *thirdTitleString;

+ (CGSize)preferredHeaderSizeForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredHeaderSizeWithoutTitleForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredHeaderSizeWithoutTitleSmallForCollectionView:(UICollectionView *)collectionView;

@end
