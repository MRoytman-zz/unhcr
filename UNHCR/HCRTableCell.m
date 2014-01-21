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

static const CGFloat kFontSizeLabel = 18.0;

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
@property (nonatomic, readwrite) UIImageView *forwardImage;
@property (nonatomic, readwrite) UISwipeGestureRecognizer *deleteGestureRecognizer;

@property UILabel *detailLabel;

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
        self.numberFormatter = [NSNumberFormatter numberFormatterWithFormat:HCRNumberFormatThousandsSeparated forceEuropeanFormat:YES];
        
        // label
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [HCRTableCell preferredFontForTitleLabel];
        
        // 'forward' button
        self.forwardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forward-button"]];
        [self.contentView addSubview:self.forwardImage];
        
        self.forwardImage.contentMode = UIViewContentModeScaleAspectFit;
        
        // delete gesture recognizer
        self.deleteGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:nil action:NULL];
        self.deleteGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:self.deleteGestureRecognizer];
        
        self.trailingSpaceForContent = [HCRTableCell preferredTrailingSpaceForContent];
        
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
    
    [self.deleteGestureRecognizer removeTarget:nil action:NULL];
    
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

+ (CGSize)sizeForCollectionView:(UICollectionView *)collectionView withAnswerString:(NSString *)answerString {
    
    CGFloat height = 0;
    
    // initial/minimum padding
    static CGFloat kTopPadding = 12;
    static CGFloat kBottomPadding = 12;
    height += kTopPadding + kBottomPadding;
    
    // the maximum dimensions the label can be
    CGSize finalBounding = [HCRTableCell _boundingSizeForContainingView:collectionView];
    
    // then add height of label
    CGSize preferredSize = [answerString sizeforMultiLineStringWithBoundingSize:finalBounding
                                                                       withFont:[HCRTableCell preferredFontForTitleLabel]
                                                                        rounded:YES];
    
    height += preferredSize.height;
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      MAX(height,
                          [HCRCollectionCell preferredSizeForCollectionView:collectionView].height));
    
}

+ (CGFloat)preferredIndentForContentWithBadgeImage {
    
    return 2 * kBadgePadding + kBadgeDimension;
    
}

+ (UIFont *)preferredFontForTitleLabel {
    return [UIFont systemFontOfSize:kFontSizeLabel];
}

+ (CGFloat)preferredTrailingSpaceForContent {
    
    return (kForwardButtonDimension * kForwardButtonWidthRatio) + kForwardButtonPadding;
    
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
    
    // TODO: refactor - don't nil out labels unless actually needed
    _detailString = detailString;
    
    if (!self.detailLabel && detailString) {
        [self _createDetailLabelWithFontSize:kDetailStringFontSize];
    }
    
    self.detailLabel.text = detailString;
    [self.detailLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setDetailNumber:(NSNumber *)detailNumber {
    
    // TODO: refactor - don't nil out labels unless actually needed
    _detailNumber = detailNumber;
    
    if (!self.detailLabel && detailNumber) {
        [self _createDetailLabelWithFontSize:kDetailNumberFontSize];
    } else if (!detailNumber) {
        [self.detailLabel removeFromSuperview];
        self.detailLabel = nil;
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
    
    // TODO: refactor - don't nil out labels unless actually needed
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

+ (CGSize)_boundingSizeForContainingView:(UIView *)containingView {
    
    return CGSizeMake(CGRectGetWidth(containingView.bounds) - [HCRCollectionCell preferredIndentForContent] - [HCRCollectionCell preferredTrailingSpaceForContent],
                      HUGE_VALF);
    
}

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