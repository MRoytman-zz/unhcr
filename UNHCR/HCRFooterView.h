//
//  HCRFooterView.h
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRFooterButtonType) {
    HCRFooterButtonTypeRawData
};

////////////////////////////////////////////////////////////////////////////////

@interface HCRFooterView : UICollectionReusableView

+ (CGSize)preferredFooterSizeForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredFooterSizeWithGraphCellForCollectionView:(UICollectionView *)collectionView;
+ (CGSize)preferredFooterSizeWithTopLineForCollectionView:(UICollectionView *)collectionView;

@property (nonatomic, readonly) HCRFooterButtonType buttonType;
@property (nonatomic, readonly) UIButton *button;

- (void)setButtonType:(HCRFooterButtonType)buttonType withButtonTitle:(NSString *)buttonTitle;

@end
