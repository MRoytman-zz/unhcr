//
//  UIImage+RMImageManipulation.m
//  ThousandWords
//
//  Created by Sean Conrad on 12/30/12.
//  Copyright (c) 2012 Reverse Method. All rights reserved.
//

#import "UIImage+RMImageManipulation.h"

@implementation UIImage (RMImageManipulation)

#pragma mark -
#pragma mark Extention Methods

- (UIImage *)colorImage:(UIColor *)color withBlendMode:(CGBlendMode)mode withTransparency:(BOOL)transparent {
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(self.size, !transparent, 0.0);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode, and the original image
    CGContextSetBlendMode(context, mode); // change this value to manipulate how color is changed
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);
    
    // set a mask that matches the shape of the image, then draw a colored rectangle
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)resizeImageToSize:(CGSize)size withResizingMode:(RMImageResizingMode)resizingMode {
    
    // calculate scaling ratio
    CGFloat scaleRatio = 1.0;
    
    // get the new size
    CGSize newSize;
    
    switch (resizingMode) {
        case RMImageResizingModeExact:
            newSize = size;
            break;
            
        case RMImageResizingModeFitWithin:
            scaleRatio = MIN(size.width / self.size.width,
                             size.height / self.size.height);
            newSize.width = scaleRatio * self.size.width;
            newSize.height = scaleRatio * self.size.height;
            break;
            
        case RMImageResizingModeMinimumSize:
        case RMImageResizingModeCropToFill:
            
            scaleRatio = MAX(size.width / self.size.width,
                             size.height / self.size.height);
            
            CGFloat newWidth = scaleRatio * self.size.width;
            CGFloat newHeight = scaleRatio * self.size.height;
            
            newSize.width = MIN(newWidth,newHeight);
            newSize.height = newSize.width;
            
            break;
            
        default:
            break;
    }
    
//    DebugLog(@"image size: %@\ninput size: %@\nproviding scaleRatio @ %.2f",
//             NSStringFromCGSize(self.size),
//             NSStringFromCGSize(size),
//             scaleRatio);
    
//    DebugLog(@"target size: %@",NSStringFromCGSize(newSize));
    
    // Create a transparent bitmapcontext with a scaling factor equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    // The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    switch (resizingMode) {
        case RMImageResizingModeExact:
        case RMImageResizingModeFitWithin:
        case RMImageResizingModeMinimumSize:
            // Draw the image on it
            [self drawInRect:newRect];
            break;
            
        case RMImageResizingModeCropToFill:
        {
            // Create a path that is a rounded rectangle
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:newRect];
            
            // Make all subsequent drawing clip to this rounded rectangle
            [path addClip];
            
            // Center the image in the thumbnail rectangle
            CGRect projectRect;
            projectRect.size.width = scaleRatio * self.size.width;
            projectRect.size.height = scaleRatio * self.size.height;
            projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
            projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
            
            // Draw the image on it
            [self drawInRect:projectRect];
        }
            break;
            
        default:
            break;
    }
    
    
    
    // Get the image from the image context, keep it as our thumbnail
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cleanup image context resources; we're done!
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

@end
