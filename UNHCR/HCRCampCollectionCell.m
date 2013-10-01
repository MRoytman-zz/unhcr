//
//  HCRCampCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampCollectionCell ()

@property UILabel *campNameLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampCollectionCell

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
    self.campDictionary = nil;
    self.campNameLabel = nil;
}

#pragma mark - Getters & Setters

- (void)setCampDictionary:(NSDictionary *)campDictionary {
    
    _campDictionary = campDictionary;
    
    if ( !self.campNameLabel && campDictionary ) {
        
        CGFloat xPadding = 8;
        CGFloat yPadding = 8;
        CGRect campLabelFrame = CGRectMake(xPadding,
                                           yPadding,
                                           CGRectGetWidth(self.bounds) - 2 * xPadding,
                                           CGRectGetHeight(self.bounds) - 2 * yPadding);
        
        self.campNameLabel = [[UILabel alloc] initWithFrame:campLabelFrame];
        [self addSubview:self.campNameLabel];
        
        self.campNameLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    self.campNameLabel.text = [campDictionary objectForKey:@"Name"];
    
}

@end
