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

- (void)setTableButtonTitle:(NSString *)tableButtonTitle {
    
    _tableButtonTitle = tableButtonTitle;
    
    [self.tableButton removeFromSuperview];
    
    if (tableButtonTitle) {
        
        self.tableButton = [self _tableButtonWithTitle:tableButtonTitle];
        [self.contentView addSubview:self.tableButton];
        
        CGFloat preferredOffset = [HCRCollectionCell preferredIndentForContent];
        self.tableButton.center = CGPointMake(preferredOffset + CGRectGetMidX(self.tableButton.bounds),
                                             CGRectGetMidY(self.bounds));
        
        // workaround; convenience after a refactor
        // buttons don't actually act as buttons - they are just visual on the table cell
        self.tableButton.userInteractionEnabled = NO;
        
    }
    
}

#pragma mark - Private Methods

- (UIButton *)_tableButtonWithTitle:(NSString *)titleString {
    
    return [UIButton buttonWithUNHCRTextStyleWithString:titleString
                                    horizontalAlignment:UIControlContentHorizontalAlignmentLeft
                                             buttonSize:self.sharedButtonSize
                                               fontSize:[NSNumber numberWithFloat:kSharedButtonFontSize]];
    
}

@end
