//
//  HCRCountryCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCountryCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCountryCollectionCell ()

@property UILabel *countryNameLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCountryCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)prepareForReuse {
    self.countryName = nil;
    self.countryNameLabel = nil;
}

#pragma mark - Getters & Setters

- (void)setCountryName:(NSString *)countryName {
    
    _countryName = countryName;
    
    if ( !self.countryNameLabel && countryName ) {
        
        CGFloat xPadding = 8;
        CGFloat yPadding = 8;
        CGRect countryLabelFrame = CGRectMake(xPadding,
                                              yPadding,
                                              CGRectGetWidth(self.bounds) - 2 * xPadding,
                                              CGRectGetHeight(self.bounds) - 2 * yPadding);
        
        self.countryNameLabel = [[UILabel alloc] initWithFrame:countryLabelFrame];
        [self addSubview:self.countryNameLabel];
        
        self.countryNameLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    self.countryNameLabel.text = countryName;
    
}

@end
