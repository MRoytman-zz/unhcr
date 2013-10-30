//
//  HCRHeaderView.m
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHeaderView.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kXLabelPadding = 20.0;
static const CGFloat kLabelHeight = 39.0;

static const CGFloat kTitleLabelDefaultFontSize = 15.0;

static const CGFloat kTitleLabelFontSize = 18.0;
static const CGFloat kSubtitleLabelFontSize = 15.0;

static const CGFloat kHeaderHeightDefault = 64.0;
static const CGFloat kHeaderHeightNoText = 34.0;
static const CGFloat kHeaderHeightNoTextSmall = 8.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRHeaderView ()

@property UILabel *titleLabel;
@property UILabel *subtitleLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor tableBackgroundColor];
        
        // bottom line
        static const CGFloat kLineHeight = 0.5;
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                          CGRectGetHeight(self.bounds) - kLineHeight,
                                                                          CGRectGetWidth(self.bounds),
                                                                          kLineHeight)];
        [self addSubview:bottomLineView];
        
        bottomLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.backgroundColor = [UIColor tableBackgroundColor];
    self.titleString = nil;
    
}

#pragma mark - Class Methods

+ (CGSize)preferredHeaderSizeForCollectionView:(UICollectionView *)collectionView {
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kHeaderHeightDefault);
    
}

+ (CGSize)preferredHeaderSizeWithoutTitleForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kHeaderHeightNoText);
}

+ (CGSize)preferredHeaderSizeWithoutTitleSmallForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kHeaderHeightNoTextSmall);
}

#pragma mark - Getters & Setters

- (void)setTitleString:(NSString *)titleString {
    
    _titleString = titleString;
    
    NSString *newString = titleString;
    
    if (!titleString) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    } else if (!self.titleLabel) {
        
        CGRect labelRect = CGRectMake(kXLabelPadding,
                                      CGRectGetHeight(self.bounds) - kLabelHeight,
                                      CGRectGetWidth(self.bounds) - 2 * kXLabelPadding,
                                      kLabelHeight);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:labelRect];
        [self addSubview:self.titleLabel];
        
        if (self.titleStyle == HCRHeaderTitleStyleDefault) {
            self.titleLabel.font = [UIFont helveticaNeueFontOfSize:kTitleLabelDefaultFontSize];
            newString = [newString uppercaseString];
        } else {
            self.titleLabel.font = [UIFont helveticaNeueFontOfSize:kTitleLabelFontSize];
        }
        
        self.titleLabel.textColor = [UIColor tableHeaderTitleColor];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    self.titleLabel.text = newString;
    
}

@end
