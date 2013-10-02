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
const CGFloat kFooterHeight = 30;

////////////////////////////////////////////////////////////////////////////////

@interface HCRFlowLayout ()

@property (nonatomic, readwrite) BOOL displayHeader;
@property (nonatomic, readwrite) BOOL displayFooter;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRFlowLayout

#pragma mark - Public Methods

+ (CGFloat)preferredHeaderHeight {
    return kHeaderHeight;
}

+ (CGFloat)preferredFooterHeight {
    return kFooterHeight;
}

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size {
    
    _displayHeader = displayHeader;
    
    if (displayHeader) {
        self.headerReferenceSize = size;
    } else {
        self.headerReferenceSize = CGSizeZero;
    }
    
}

- (void)setDisplayFooter:(BOOL)displayFooter withSize:(CGSize)size {
    
    _displayFooter = displayFooter;
    
    if (displayFooter) {
        self.footerReferenceSize = size;
    } else {
        self.footerReferenceSize = CGSizeZero;
    }
    
}

@end
