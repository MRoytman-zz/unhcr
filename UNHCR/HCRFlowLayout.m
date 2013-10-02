//
//  HCRFlowLayout.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kHeaderHeight = 44;

////////////////////////////////////////////////////////////////////////////////

@interface HCRFlowLayout ()

@property (nonatomic, readwrite) BOOL displayHeader;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRFlowLayout

#pragma mark - Public Methods

+ (CGFloat)preferredHeaderHeight {
    return kHeaderHeight;
}

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size {
    
    _displayHeader = displayHeader;
    
    if (displayHeader) {
        self.headerReferenceSize = size;
    } else {
        self.headerReferenceSize = CGSizeZero;
    }
    
}

@end
