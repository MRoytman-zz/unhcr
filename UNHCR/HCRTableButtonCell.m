//
//  HCRCampClusterButtonListCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableButtonCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kLargeButtonWidth = 200.0;
static const CGFloat kSharedButtonHeight = 54.0;

static const CGFloat kSharedButtonFontSize = 21.0;

static const CGFloat kYListOffset = 12;
static const CGFloat kYButtonPadding = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableButtonCell ()

@property (nonatomic, readonly) CGSize sharedButtonSize;

@property (nonatomic, readwrite) UIButton *tableButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableButtonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.indentForContent = 0;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.tableButtonTitle = nil;
    self.tableButtonStyle = HCRTableButtonStyleDefault;
    
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

- (void)setTableButtonTitle:(NSString *)tableButtonTitle {
    
    _tableButtonTitle = tableButtonTitle;
    
    if (tableButtonTitle) {
        [self _reloadTableButton];
    }
    
}

- (void)setTableButtonStyle:(HCRTableButtonStyle)tableButtonStyle {
    _tableButtonStyle = tableButtonStyle;
    [self _reloadTableButton];
}

#pragma mark - Private Methods

- (UIButton *)_tableButtonWithTitle:(NSString *)titleString {
    
    UIButton *button;
    
    if (self.tableButtonStyle == HCRTableButtonStyleForward) {
        button = [UIButton buttonWithUNHCRTextStyleWithString:titleString
                                          horizontalAlignment:UIControlContentHorizontalAlignmentLeft
                                                   buttonSize:self.sharedButtonSize
                                                     fontSize:[NSNumber numberWithFloat:kSharedButtonFontSize]];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 0, self.sharedButtonSize.width, self.sharedButtonSize.height);
        
        button.tintColor = [UIColor UNHCRBlue];
        
        [button setTitle:titleString forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton]
                                                 size:kSharedButtonFontSize];
    }
    
    return button;
    
}

- (void)_reloadTableButton {
    
    [self.tableButton removeFromSuperview];
    
    self.tableButton = [self _tableButtonWithTitle:self.tableButtonTitle];
    [self.contentView addSubview:self.tableButton];
    
    // TODO: handle different positions/sizes for various button types
    self.tableButton.center = self.contentView.center;
    
    // workaround; convenience after a refactor
    // buttons don't actually act as buttons - they are just visual on the table cell
    self.tableButton.userInteractionEnabled = NO;
    
}

@end
