//
//  HCRFooterView.m
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFooterView.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kFooterHeight = 14.0;
const CGFloat kFooterHeightForGraphCell = 50.0;
const CGFloat kFooterHeightForTopLine = 0.5;

const CGFloat kLabelHeight = 30.0;
const CGFloat kXLabelPadding = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRFooterView ()

@property (nonatomic, readwrite) UIButton *button;
@property (nonatomic, readwrite) HCRFooterButtonType buttonType;

@property UILabel *titleLabel;

@property UIView *footerTopLineView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor tableBackgroundColor];
        
        // bottom line
        self.footerTopLineView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.footerTopLineView];
        
        self.footerTopLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.button removeFromSuperview];
    self.button = nil;
    
    self.titleString = nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.footerTopLineView.frame = CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.bounds),
                                              kFooterHeightForTopLine);
    
}

#pragma mark - Class Methods

+ (CGSize)preferredFooterSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeight);
}

+ (CGSize)preferredFooterSizeWithBottomLineOnlyForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeightForTopLine);
}

+ (CGSize)preferredFooterSizeWithGraphCellForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeightForGraphCell);
}

+ (CGSize)preferredFooterSizeWithTitleForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeight + kLabelHeight);
}

#pragma mark - Public Methods

- (void)setButtonType:(HCRFooterButtonType)buttonType withButtonTitle:(NSString *)buttonTitle {
    
    _buttonType = buttonType;
    
    // set new button
    switch (buttonType) {
        case HCRFooterButtonTypeRawData:
        {
            self.button = [UIButton buttonWithUNHCRTextStyleWithString:buttonTitle
                                                   horizontalAlignment:UIControlContentHorizontalAlignmentRight
                                                            buttonSize:[UIButton preferredSizeForUNHCRGraphCellFooterButton]
                                                              fontSize:nil];
            [self addSubview:self.button];
            
            static const CGFloat xButtonPadding = 8;
            self.button.center = CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetMidX(self.button.bounds) - xButtonPadding,
                                              CGRectGetMidY(self.bounds));
        }
            break;
            
    }
    
}

- (void)setTitleString:(NSString *)titleString {
    
    _titleString = titleString;
    
    NSString *newString = titleString;
    
    if (!titleString) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    } else if (!self.titleLabel) {
        
        CGRect labelRect = CGRectMake(kXLabelPadding,
                                      0,
                                      CGRectGetWidth(self.bounds) - 2 * kXLabelPadding,
                                      kLabelHeight);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:labelRect];
        [self addSubview:self.titleLabel];
        
        self.titleLabel.textColor = [UIColor tableHeaderTitleColor];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        
    }
    
    self.titleLabel.text = newString;
    
}

@end
