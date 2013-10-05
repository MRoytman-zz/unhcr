//
//  HCRCampClusterResourcesCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterResourcesCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterResourcesCell ()

@property (nonatomic, readwrite) UIButton *requestSuppliesButton;
@property (nonatomic, readwrite) UIButton *sitRepsButton;
@property (nonatomic, readwrite) UIButton *tallySheetsButton;

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
    
}

#pragma mark - Getters & Setters

- (UIButton *)tallySheetsButton {
    
    if ( _tallySheetsButton == nil ) {
        
        _tallySheetsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_tallySheetsButton setTitle:@"Tally Sheets" forState:UIControlStateNormal];
        
        

    }
    
    return _tallySheetsButton;
    
}

- (void)setShowTallySheetsButton:(BOOL)showTallySheetsButton {
    
    _showTallySheetsButton = showTallySheetsButton;
    
    [self setNeedsLayout];
    
}

@end
