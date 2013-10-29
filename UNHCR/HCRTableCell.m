//
//  HCRTableCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kBadgePadding = 18.0;
static const CGFloat kBadgeDimension = 29.0;

static const CGFloat kForwardButtonPadding = 10.0;
static const CGFloat kForwardButtonDimension = 20.0;
static const CGFloat kForwardButtonWidthRatio = 1.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableCell ()

@property (nonatomic, readonly) CGRect badgeFrame;
@property (nonatomic, readonly) CGRect titleLabelFrame;
@property (nonatomic, readonly) CGRect forwardImageFrame;

@property (nonatomic, readwrite) UIImageView *badgeImageView;
@property (nonatomic, readwrite) UILabel *titleLabel;

@property UIImageView *forwardImage;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.highlightedColor = [UIColor tableSelectedCellColor];
        
        // label
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:18];
        
        // 'forward' button
        self.forwardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward-button"]];
        [self.contentView addSubview:self.forwardImage];
        
        self.forwardImage.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.badgeImage = nil;
    self.title = nil;
    
}

- (void)layoutSubviews {
    
    // order matters; some objects reference size/frame/position of others
    self.badgeImageView.frame = self.badgeFrame;
    self.forwardImage.frame = self.forwardImageFrame;
    self.titleLabel.frame = self.titleLabelFrame;
    
    self.indentForContent = CGRectGetMinX(self.titleLabel.frame);
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredIndentForContentWithBadgeImage {
    
    return 2 * kBadgePadding + kBadgeDimension;
    
}

+ (CGFloat)preferredTrailingSpaceForContent {
    return kForwardButtonPadding;
}

#pragma mark - Getters & Setters

- (CGRect)badgeFrame {
    
    return CGRectMake(kBadgePadding,
                      0.5 * (CGRectGetHeight(self.contentView.bounds) - kBadgeDimension),
                      kBadgeDimension,
                      kBadgeDimension);
    
}

- (CGRect)titleLabelFrame {
    
    CGFloat baseImageViewIndent = CGRectGetMaxX(self.badgeImageView.frame);
    CGFloat titleOrigin = MAX(baseImageViewIndent + kBadgePadding,[HCRCollectionCell preferredIndentForContent]);
    return CGRectMake(titleOrigin,
                      0,
                      CGRectGetWidth(self.contentView.bounds) - baseImageViewIndent - CGRectGetMinX(self.forwardImage.bounds) - 2 * kForwardButtonPadding,
                      CGRectGetHeight(self.contentView.bounds));
    
}

- (CGRect)forwardImageFrame {
    
    CGFloat forwardWidth = kForwardButtonDimension * kForwardButtonWidthRatio;
    return CGRectMake(CGRectGetWidth(self.contentView.bounds) - forwardWidth - kForwardButtonPadding,
                      0.5 * (CGRectGetHeight(self.contentView.bounds) - kForwardButtonDimension),
                      forwardWidth,
                      kForwardButtonDimension);
    
}

- (void)setTitle:(NSString *)title {
    
    _title = title;
    
    self.titleLabel.text = title;
    
}

- (void)setBadgeImage:(UIImage *)badgeImage {
    
    _badgeImage = badgeImage;
    
    if (!self.badgeImageView && badgeImage) {
        // badge
        self.badgeImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.badgeImageView];
        
        self.badgeImageView.layer.cornerRadius = 5.0;
        self.badgeImageView.clipsToBounds = YES;
    }
    
    self.badgeImageView.image = badgeImage;
    
}

@end