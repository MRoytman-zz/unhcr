//
//  UIButton+UNHCRButtonStyles.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UNHCRButtonStyles)

+ (CGFloat)preferredHeightForUNHCRButtonWithWidth:(CGFloat)width;

+ (UIButton *)buttonWithUNHCRStyleWithSize:(CGSize)buttonSize;

@end
