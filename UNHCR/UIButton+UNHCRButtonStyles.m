//
//  UIButton+UNHCRButtonStyles.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIButton+UNHCRButtonStyles.h"

@implementation UIButton (UNHCRButtonStyles)

+ (CGFloat)preferredHeightForUNHCRButtonWithWidth:(CGFloat)width {
    return width * 0.3157;
}

+ (UIButton *)buttonWithUNHCRStyleWithSize:(CGSize)buttonSize {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.tintColor = [UIColor UNHCRBlue];
    
    button.layer.borderColor = [UIColor UNHCRBlue].CGColor;
    button.layer.borderWidth = buttonSize.width / 63.4;
    button.layer.cornerRadius = buttonSize.width / 19.0;
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                             size:buttonSize.width / 6.8];
    
    return button;
    
}

@end
