//
//  HCRTableTallyCell.m
//  UNHCR
//
//  Created by Sean Conrad on 11/3/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableTallyCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kYHeaderPaddingTotal = 34.0;

static const CGFloat kYForwardImageOffset = 0.5 * kYHeaderPaddingTotal;

static const CGFloat kXTitleLabelPadding = 8.0;

static const CGFloat kCustomTrailingSpace = 20.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableTallyCell ()

@property (nonatomic, readonly) CGRect forwardImageFrame;
@property (nonatomic, readonly) CGRect titleLabelFrame;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableTallyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.trailingSpaceForContent = kCustomTrailingSpace;
        
        self.forwardImage.image = [[UIImage imageNamed:@"tap-here"] colorImage:[UIColor UNHCRBlue]
                                                                 withBlendMode:kCGBlendModeNormal
                                                              withTransparency:YES];
        
        self.forwardImage.alpha = 0.4;
        
        self.titleLabel.numberOfLines = 0;
        
    }
    return self;
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withString:(NSString *)string {
    
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(collectionView.bounds) - [HCRCollectionCell preferredIndentForContent] - kCustomTrailingSpace,
                                     CGRectGetHeight(collectionView.bounds));
    
    CGFloat height = [string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                           withFont:[HCRTableTallyCell preferredFontForTitleLabel]
                                                            rounded:YES].height;
    
    height = height + kYHeaderPaddingTotal;
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      height);
    
}

#pragma mark - Getters & Setters

- (CGRect)forwardImageFrame {
    
    CGFloat yPosition = MIN(0.5 * (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(self.forwardImage.bounds)),
                            kYForwardImageOffset);
    
    return CGRectMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.forwardImage.bounds) - self.trailingSpaceForContent,
                      yPosition,
                      CGRectGetWidth(self.forwardImage.bounds),
                      CGRectGetHeight(self.forwardImage.bounds));
    
}

- (CGRect)titleLabelFrame {
    
    CGFloat titleOrigin = self.indentForContent;
    return CGRectMake(titleOrigin,
                      0,
                      CGRectGetMinX(self.forwardImage.frame) - titleOrigin - kXTitleLabelPadding,
                      CGRectGetHeight(self.contentView.bounds));
    
}

@end
