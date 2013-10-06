//
//  UIButton+UNHCRButtonStyles.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIButton+UNHCRButtonStyles.h"
#import "UIImage+RMImageManipulation.h"

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

+ (UIButton *)buttonWithUNHCRTextStyleWithString:(NSString *)titleString horizontalAlignment:(UIControlContentHorizontalAlignment)horizontalAlignment buttonSize:(CGSize)buttonSize fontSize:(NSNumber *)fontSize {
    
    // TODO: weird bug with center alignment - providing too much width with a short string separates the image and the label
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    button.contentHorizontalAlignment = horizontalAlignment;
    
    button.tintColor = [UIColor UNHCRBlue];
    
    [button setTitle:titleString forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton]
                                             size:(fontSize) ? [fontSize floatValue] : buttonSize.height * 0.65];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"forward-button"];
    
    CGFloat backgroundImageRatio = 0.77;
    BOOL backgroundImageTooLarge = (backgroundImage.size.height > CGRectGetHeight(button.titleLabel.bounds) * backgroundImageRatio);
    if (backgroundImageTooLarge) {
        backgroundImage = [backgroundImage resizeImageToSize:CGSizeMake(button.titleLabel.bounds.size.width * backgroundImageRatio,
                                                                        button.titleLabel.bounds.size.height * backgroundImageRatio)
                                            withResizingMode:RMImageResizingModeFitWithin];
    }
    
    [button setImage:backgroundImage forState:UIControlStateNormal];
    
//    button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
//    button.imageView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
//    button.titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
//    NSLog(@"button.imageView.frame: %@",NSStringFromCGRect(button.imageView.frame));
//    NSLog(@"button.titleLabel.frame: %@",NSStringFromCGRect(button.titleLabel.frame));
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                              -1 * backgroundImage.size.width,
                                              0,
                                              backgroundImage.size.width);
    
    button.imageEdgeInsets = UIEdgeInsetsMake(CGRectGetHeight(button.titleLabel.bounds) * 0.91 - backgroundImage.size.height,
                                              CGRectGetMaxX(button.titleLabel.frame),
                                              0,
                                              0);
    
    return button;
    
}

@end
