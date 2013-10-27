//
//  HCRFooterView.m
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFooterView.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kFooterHeight = 30.0;
const CGFloat kFooterHeightForGraphCell = 50.0;
const CGFloat kFooterHeightForTopLine = 0.5;

////////////////////////////////////////////////////////////////////////////////

@interface HCRFooterView ()

@property (nonatomic, readwrite) UIButton *button;
@property (nonatomic, readwrite) HCRFooterButtonType buttonType;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // bottom line
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          CGRectGetWidth(self.bounds),
                                                                          kFooterHeightForTopLine)];
        [self addSubview:bottomLineView];
        
        bottomLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.button removeFromSuperview];
    self.button = nil;
    
}

#pragma mark - Class Methods

+ (CGSize)preferredFooterSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeight);
}

+ (CGSize)preferredFooterSizeWithTopLineForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeightForTopLine);
}

+ (CGSize)preferredFooterSizeWithGraphCellForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeightForGraphCell);
}

#pragma mark - Public Methods

- (void)setButtonType:(HCRFooterButtonType)buttonType withButtonTitle:(NSString *)buttonTitle {
    
    self.buttonType = buttonType;
    
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

@end
