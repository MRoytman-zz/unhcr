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

+ (UIColor *)midGrayColor {
    return [UIColor colorWithWhite:0.4 alpha:1.0];
}

+ (UIColor *)tableBackgroundColor {
    
    return [UIColor colorWithRed:239/255.0
                           green:239/255.0
                            blue:244/255.0
                           alpha:1.0];
    
}

+ (UIColor *)tableDividerColor {
    
    return [UIColor colorWithWhite:0.6 alpha:0.7];
    
}

+ (UIColor *)tableSelectedCellColor {
    return [UIColor colorWithRed:217/255.0
                           green:217/255.0
                            blue:217/255.0
                           alpha:1.0];
}

+ (UIColor *)tableHeaderTitleColor {
    return [UIColor colorWithRed:109/255.0
                           green:109/255.0
                            blue:114/255.0
                           alpha:1.0];
}

@end
