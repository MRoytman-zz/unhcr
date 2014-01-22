//
//  HCRTableCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRTableCell : HCRCollectionCell

+ (CGSize)sizeForCollectionView:(UICollectionView *)collectionView withAnswerString:(NSString *)answerString;
+ (CGSize)preferredSizeForString:(NSString *)string inCollectionView:(UIView *)collectionView;
+ (CGFloat)preferredIndentForContentWithBadgeImage;
+ (UIFont *)preferredFontForTitleLabel;

@property (nonatomic, readonly) UISwipeGestureRecognizer *deleteGestureRecognizer;

@property (nonatomic, strong) UIImage *badgeImage;
@property (nonatomic, readonly) UIImageView *badgeImageView;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, readonly) UILabel *titleLabel;

@property (nonatomic) BOOL highlightDetail;
@property (nonatomic, strong) NSString *detailString;
@property (nonatomic, strong) NSNumber *detailNumber;

@property (nonatomic, readonly) UIImageView *forwardImage;

@end
