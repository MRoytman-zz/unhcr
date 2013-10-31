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
static const CGFloat kForwardButtonWidthRatio = 0.75;

static const CGFloat kLabelFontSize = 18.0;

static const CGFloat kDetailLabelMinimumDimension = 22.0;
static const CGFloat kDetailNumberFontSize = 16.0;
static const CGFloat kDetailStringFontSize = 14.0;
static const CGFloat kDetailXPadding = 4.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableCell ()

@property (nonatomic, readonly) CGRect badgeFrame;
@property (nonatomic, readonly) CGRect titleLabelFrame;
@property (nonatomic, readonly) CGRect forwardImageFrame;
@property (nonatomic, readonly) CGRect detailLabelFrame;

@property (nonatomic, readwrite) UIImageView *badgeImageView;
@property (nonatomic, readwrite) UILabel *titleLabel;

@property UILabel *detailLabel;
@property UIImageView *forwardImage;

@property NSNumberFormatter *numberFormatter;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.highlightedColor = [UIColor tableSelectedCellColor];
        self.numberFormatter = [NSNumberFormatter numberFormatterWithFormat:HCRNumberFormatThousandsSeparated];
        
        // label
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:kLabelFontSize];
        
        // 'forward' button
        self.forwardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward-button"]];
        [self.contentView addSubview:self.forwardImage];
        
        self.forwardImage.contentMode = UIViewContentModeScaleAspectFit;
        
        // DEBUG
//        self.titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
//        self.forwardImage.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.badgeImage = nil;
    self.title = nil;
    self.detailString = nil;
    self.detailNumber = nil;
    self.highlightDetail = NO;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.detailLabel.textColor = (self.highlightDetail) ? [UIColor whiteColor] : [UIColor UNHCRBlue];
    self.detailLabel.backgroundColor = (self.highlightDetail) ? [UIColor redColor] : [UIColor clearColor];
    
    // order matters; some objects reference size/frame/position of others
    self.badgeImageView.frame = self.badgeFrame;
    self.forwardImage.frame = self.forwardImageFrame;
    self.detailLabel.frame = self.detailLabelFrame;
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

- (CGRect)forwardImageFrame {
    
    CGFloat forwardWidth = kForwardButtonDimension * kForwardButtonWidthRatio;
    return CGRectMake(CGRectGetWidth(self.contentView.bounds) - forwardWidth - kForwardButtonPadding,
                      0.5 * (CGRectGetHeight(self.contentView.bounds) - kForwardButtonDimension),
                      forwardWidth,
                      kForwardButtonDimension);
    
}

- (CGRect)detailLabelFrame {
    
    CGFloat additionalSize = (self.highlightDetail) ? 0.5 * kDetailLabelMinimumDimension : 0;
    CGFloat labelWidth = MAX(kDetailLabelMinimumDimension,
                             CGRectGetWidth(self.detailLabel.bounds) + additionalSize);
    CGSize detailSize = CGSizeMake(labelWidth,
                                   kDetailLabelMinimumDimension);
    
    return CGRectMake(CGRectGetMinX(self.forwardImage.frame) - detailSize.width - kDetailXPadding,
                      0.5 * (CGRectGetHeight(self.contentView.bounds) - detailSize.height),
                      detailSize.width,
                      detailSize.height);
    
}

- (CGRect)titleLabelFrame {
    
    CGFloat titleOrigin = MAX(CGRectGetMaxX(self.badgeImageView.frame) + kBadgePadding,
                              [HCRCollectionCell preferredIndentForContent]);
    
    CGRect nearestFrame = (self.detailLabel) ? self.detailLabel.frame : self.forwardImage.frame;
    
    return CGRectMake(titleOrigin,
                      0,
                      CGRectGetMinX(nearestFrame) - titleOrigin,
                      CGRectGetHeight(self.contentView.bounds));
    
}

- (void)setTitle:(NSString *)title {
    
    _title = title;
    
    self.titleLabel.text = title;
    
}

- (void)setDetailString:(NSString *)detailString {
    _detailString = detailString;
    
    if (!detailString) {
        [self.detailLabel removeFromSuperview];
        self.detailLabel = nil;
    } else if (!self.detailLabel) {
        [self _createDetailLabelWithFontSize:kDetailStringFontSize];
    }
    
    self.detailLabel.text = detailString;
    [self.detailLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setDetailNumber:(NSNumber *)detailNumber {
    
    _detailNumber = detailNumber;
    
    if (!detailNumber) {
        [self.detailLabel removeFromSuperview];
        self.detailLabel = nil;
    } else if (!self.detailLabel) {
        [self _createDetailLabelWithFontSize:kDetailNumberFontSize];
    }
    
    self.detailLabel.text = [NSString stringWithFormat:@"%@",[self.numberFormatter stringFromNumber:detailNumber]];
    [self.detailLabel sizeToFit];
    
    [self setNeedsLayout];
    
}

- (void)setHighlightDetail:(BOOL)highlightDetail {
    
    _highlightDetail = highlightDetail;
    
    [self setNeedsLayout];
}

- (void)setBadgeImage:(UIImage *)badgeImage {
    
    _badgeImage = badgeImage;
    
    if (!badgeImage) {
        [self.badgeImageView removeFromSuperview];
        self.badgeImageView = nil;
    } else if (!self.badgeImageView) {
        // badge
        self.badgeImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.badgeImageView];
        
        self.badgeImageView.layer.cornerRadius = 5.0;
        self.badgeImageView.clipsToBounds = YES;
    }
    
    self.badgeImageView.image = badgeImage;
    
}

#pragma mark - Private Methods

- (void)_createDetailLabelWithFontSize:(CGFloat)fontSize {
    
    // detail label
    self.detailLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.detailLabel];
    
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.font = [UIFont systemFontOfSize:fontSize];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.layer.cornerRadius = 0.5 * kDetailLabelMinimumDimension;
    
}

@end