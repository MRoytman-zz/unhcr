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

+ (NSString *)preferredFontNameForUNHCRButton {
    return @"HelveticaNeue-Light";
}

+ (UIButton *)buttonWithUNHCRStandardStyleWithSize:(CGSize)buttonSize {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    button.backgroundColor = [UIColor whiteColor];
    button.tintColor = [UIColor UNHCRBlue];
    
    button.layer.borderColor = [UIColor UNHCRBlue].CGColor;
    button.layer.borderWidth = buttonSize.width / 63.4;
    button.layer.cornerRadius = buttonSize.width / 19.0;
    
    button.titleLabel.font = [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton]
                                             size:buttonSize.width / 6.8];
    
    return button;
    
}

+ (UIButton *)buttonWithUNHCRTextStyleWithString:(NSString *)titleString horizontalAlignment:(UIControlContentHorizontalAlignment)horizontalAlignment size:(CGSize)buttonSize {
    
    // TODO: weird bug with center alignment - providing too much width with a short string separates the image and the label
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    button.contentHorizontalAlignment = horizontalAlignment;
    
    button.tintColor = [UIColor UNHCRBlue];
    
    [button setTitle:titleString forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton]
                                             size:buttonSize.height * 0.65];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"forward-button"];
    [button setImage:backgroundImage forState:UIControlStateNormal];
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                              -1 * backgroundImage.size.width,
                                              0,
                                              backgroundImage.size.width);
    
    button.imageEdgeInsets = UIEdgeInsetsMake(5,
                                              CGRectGetMaxX(button.titleLabel.frame),
                                              0,
                                              0);
    
//    button.imageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
//    button.titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
    
    return button;
    
}

@end
