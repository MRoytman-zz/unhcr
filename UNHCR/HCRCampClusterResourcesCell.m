//
//  HCRCampClusterResourcesCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterResourcesCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kLargeButtonWidth = 200.0;
static const CGFloat kSmallButtonWidth = 120.0;
static const CGFloat kSharedButtonHeight = 50.0;
static const CGFloat kSharedButtonFontSize = 20.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterResourcesCell ()

@property (nonatomic, readwrite) UIButton *requestSuppliesButton;
@property (nonatomic, readwrite) UIButton *sitRepsButton;
@property (nonatomic, readwrite) UIButton *tallySheetsButton;

@property (nonatomic, readonly) UIFont *sharedButtonFont;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterResourcesCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    
    static const CGFloat yOffset = 20;
    static const CGFloat yPadding = 10;
    
    self.requestSuppliesButton.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                    yOffset + CGRectGetMidY(self.requestSuppliesButton.bounds));
    
    self.sitRepsButton.center = CGPointMake(CGRectGetMidX(self.bounds),
                                            CGRectGetMaxY(self.requestSuppliesButton.frame) + yPadding + CGRectGetMidY(self.sitRepsButton.bounds));
    
    
    if (self.showTallySheetsButton) {
        
        self.tallySheetsButton.center = CGPointMake(CGRectGetMidX(self.bounds),
                                                    CGRectGetMaxY(self.sitRepsButton.frame) + yPadding + CGRectGetMidY(self.tallySheetsButton.bounds));
        
    }
    
}

#pragma mark - Getters & Setters

- (UIFont *)sharedButtonFont {
    return [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton]
                           size:kSharedButtonFontSize];
}

- (UIButton *)requestSuppliesButton {
    
    if ( !_requestSuppliesButton ) {
        _requestSuppliesButton = [UIButton buttonWithUNHCRStandardStyleWithSize:CGSizeMake(kLargeButtonWidth,
                                                                                           kSharedButtonHeight)];
        [self addSubview:_requestSuppliesButton];
        
        _requestSuppliesButton.titleLabel.font = self.sharedButtonFont;
        [_requestSuppliesButton setTitle:@"Request Supplies" forState:UIControlStateNormal];
        
    }
    
    return _requestSuppliesButton;
    
}

- (UIButton *)sitRepsButton {
    
    if ( !_sitRepsButton ) {
        _sitRepsButton = [UIButton buttonWithUNHCRStandardStyleWithSize:CGSizeMake(kLargeButtonWidth,
                                                                                   kSharedButtonHeight)];
        [self addSubview:_sitRepsButton];
        
        _sitRepsButton.titleLabel.font = self.sharedButtonFont;
        [_sitRepsButton setTitle:@"Situation Reports" forState:UIControlStateNormal];
        
    }
    
    return _sitRepsButton;
    
}

- (UIButton *)tallySheetsButton {
    
    if ( !_tallySheetsButton ) {
        
        _tallySheetsButton = [UIButton buttonWithUNHCRStandardStyleWithSize:CGSizeMake(kLargeButtonWidth,
                                                                                       kSharedButtonHeight)];
        [self addSubview:_tallySheetsButton];
        
        _tallySheetsButton.titleLabel.font = self.sharedButtonFont;
        [_tallySheetsButton setTitle:@"Tally Sheets" forState:UIControlStateNormal];

    }
    
    return _tallySheetsButton;
    
}

- (void)setShowTallySheetsButton:(BOOL)showTallySheetsButton {
    
    _showTallySheetsButton = showTallySheetsButton;
    
    [self setNeedsLayout];
    
}

@end
