//
//  UIImage+RMImageManipulation.h
//  ThousandWords
//
//  Created by Sean Conrad on 12/30/12.
//  Copyright (c) 2012 Reverse Method. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

typedef enum {
    RMImageResizingModeExact,
    RMImageResizingModeFitWithin,
    RMImageResizingModeMinimumSize,
    RMImageResizingModeCropToFill
} RMImageResizingMode;

////////////////////////////////////////////////////////////////////////////////

@interface UIImage (RMImageManipulation)

// color
- (UIImage *)colorImage:(UIColor *)color withBlendMode:(CGBlendMode)mode withTransparency:(BOOL)transparent;

// resizing
- (UIImage *)resizeImageToSize:(CGSize)size withResizingMode:(RMImageResizingMode)resizingMode;

@end
