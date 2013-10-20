//
//  UIColor+HCRColors.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "UIColor+HCRColors.h"

@implementation UIColor (HCRColors)

+ (UIColor *)UNHCRBlue {
    
    return [UIColor colorWithHue:209/360.0
                      saturation:0.92
                      brightness:0.77
                           alpha:1.0];
    
}

+ (UIColor *)HMSPurple {
    return [UIColor colorWithRed:62 / 256.0
                           green:0 / 256.0
                            blue:199 / 256.0
                           alpha:1.0];
}

@end
