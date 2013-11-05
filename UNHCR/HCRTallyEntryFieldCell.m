//
//  HCRTallyEntryFieldCell.m
//  UNHCR
//
//  Created by Sean Conrad on 11/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallyEntryFieldCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kXTrailing = 20.0;
static const CGFloat kInputWidth = 80.0;

static const CGFloat kYOffset = 10.0;
static const CGFloat kYTrailing = 10.0;

static const CGFloat kXLabelPadding = 8.0;

static const CGFloat kFontSize = 16;

static const CGFloat kInputLabelHeight = 25.0;

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallyEntryFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel.numberOfLines = 0;
        self.inputField.textAlignment = NSTextAlignmentRight;
        
        self.titleLabel.font = [HCRTallyEntryFieldCell _preferredFontForTitleLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.inputField.frame = CGRectMake(CGRectGetMaxX(self.contentView.bounds) - kXTrailing - kInputWidth,
                                       kYOffset,
                                       kInputWidth,
                                       kInputLabelHeight);
    
    self.inputField.backgroundColor = self.contentView.backgroundColor;
    
    self.titleLabel.frame = CGRectMake([HCRCollectionCell preferredIndentForContent],
                                       0,
                                       CGRectGetMinX(self.inputField.frame) - [HCRCollectionCell preferredIndentForContent] - kXLabelPadding,
                                       CGRectGetHeight(self.contentView.bounds));
    
    self.titleLabel.backgroundColor = self.contentView.backgroundColor;
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withString:(NSString *)string  {
    
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(collectionView.bounds) - kInputWidth - kXTrailing - [HCRCollectionCell preferredIndentForContent] - kXLabelPadding,
                                     CGRectGetHeight(collectionView.bounds));
    
    CGFloat height = [string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                           withFont:[HCRTallyEntryFieldCell _preferredFontForTitleLabel]
                                                            rounded:YES].height;
    
    height = kYOffset + height + kYTrailing;
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      height);
    
}

#pragma mark - Private Methods

+ (UIFont *)_preferredFontForTitleLabel {
    return [UIFont systemFontOfSize:kFontSize];
}

@end
