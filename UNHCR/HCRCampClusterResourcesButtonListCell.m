//
//  HCRCampClusterResourcesCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterResourcesButtonListCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterResourcesButtonListCell ()

@property (nonatomic, readwrite) UIButton *requestSuppliesButton;
@property (nonatomic, readwrite) UIButton *sitRepsButton;
@property (nonatomic, readwrite) UIButton *tallySheetsButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterResourcesButtonListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _resetButtonsArray];
    }
    return self;
}

- (void)prepareForReuse {
    
    self.showTallySheetsButton = NO;
    
    [self.requestSuppliesButton removeFromSuperview];
    self.requestSuppliesButton = nil;
    
    [self.sitRepsButton removeFromSuperview];
    self.sitRepsButton = nil;
    
    [self.tallySheetsButton removeFromSuperview];
    self.tallySheetsButton = nil;
    
    [self _resetButtonsArray];
    
}

#pragma mark - Getters & Setters

- (UIButton *)requestSuppliesButton {
    
    if ( !_requestSuppliesButton ) {
        _requestSuppliesButton = [self buttonListCellButtonWithTitle:@"Request Supplies"];
        [self addSubview:_requestSuppliesButton];
        
    }
    
    return _requestSuppliesButton;
    
}

- (UIButton *)sitRepsButton {
    
    if ( !_sitRepsButton ) {
        _sitRepsButton = [self buttonListCellButtonWithTitle:@"Situation Reports"];
        [self addSubview:_sitRepsButton];
        
    }
    
    return _sitRepsButton;
    
}

- (UIButton *)tallySheetsButton {
    
    if ( !_tallySheetsButton ) {
        
        _tallySheetsButton = [self buttonListCellButtonWithTitle:@"Tally Sheets"];
        [self addSubview:_tallySheetsButton];

    }
    
    return _tallySheetsButton;
    
}

- (void)setShowTallySheetsButton:(BOOL)showTallySheetsButton {
    
    _showTallySheetsButton = showTallySheetsButton;
    
    if (showTallySheetsButton) {
        [self.buttonsArray addObject:self.tallySheetsButton];
    } else {
        [self.buttonsArray removeObject:self.tallySheetsButton];
        [self.tallySheetsButton removeFromSuperview];
    }
    
    [self setNeedsLayout];
    
}

#pragma mark - Private Methods

- (void)_resetButtonsArray {
    self.buttonsArray = @[
                          self.requestSuppliesButton,
                          self.sitRepsButton
                          ].mutableCopy;
}

@end
