//
//  HCRCampClusterButtonListCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRButtonListCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kLargeButtonWidth = 200.0;
static const CGFloat kSharedButtonHeight = 54.0;

static const CGFloat kSharedButtonFontSize = 23.0;

static const CGFloat kXListOffset = 20;
static const CGFloat kYListOffset = 12;
static const CGFloat kYButtonPadding = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRButtonListCell ()

@property (nonatomic, readonly) CGSize sharedButtonSize;
@property (nonatomic, readwrite) UIButton *listButton;
@property (nonatomic, strong) UIView *cellDivider;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRButtonListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

#pragma mark - Class Methods

+ (CGFloat)preferredCellHeight {
    return kSharedButtonHeight;
}

#pragma mark - Getters & Setters

- (CGSize)sharedButtonSize {
    return CGSizeMake(CGRectGetWidth(self.bounds),
                      kSharedButtonHeight);
}

- (void)setListButtonTitle:(NSString *)listButtonTitle {
    
    _listButtonTitle = listButtonTitle;
    
    [self.listButton removeFromSuperview];
    
    if (listButtonTitle) {
        
        self.listButton = [self _listCellButtonWithTitle:listButtonTitle];
        [self addSubview:self.listButton];
        
        self.listButton.center = CGPointMake(kXListOffset + CGRectGetMidX(self.listButton.bounds),
                                             CGRectGetMidY(self.bounds));
        
        // workaround; convenience after a refactor
        self.listButton.userInteractionEnabled = NO;
        
    }
    
}

- (void)setShowCellDivider:(BOOL)showCellDivider {
    
    _showCellDivider = showCellDivider;
    
    if (showCellDivider && !self.cellDivider) {
        
        static const CGFloat kXLineOffset = 12.0;
        static const CGFloat kLineWidth = 1.0;
        self.cellDivider = [[UIView alloc] initWithFrame:CGRectMake(kXLineOffset,
                                                                    CGRectGetHeight(self.bounds) - kLineWidth,
                                                                    CGRectGetWidth(self.bounds) - kXLineOffset,
                                                                    kLineWidth)];
        [self addSubview:self.cellDivider];
        
        self.cellDivider.backgroundColor = [UIColor lightGrayColor];
    }
    
}

#pragma mark - Private Methods

- (UIButton *)_listCellButtonWithTitle:(NSString *)titleString {
    
    return [UIButton buttonWithUNHCRTextStyleWithString:titleString
                                    horizontalAlignment:UIControlContentHorizontalAlignmentLeft
                                             buttonSize:self.sharedButtonSize
                                               fontSize:[NSNumber numberWithFloat:kSharedButtonFontSize]];
    
}

@end
