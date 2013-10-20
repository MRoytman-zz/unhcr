/*
     File: SimpleStockView.m 
 Abstract: This is the graph view where the drawing is done. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "SCGraphView.h"

////////////////////////////////////////////////////////////////////////////////

@interface SCGraphView ()

@property CGPoint initialDataPointLocation;
@property NSNumberFormatter *numberFormatter;

@property CGGradientRef backgroundGradientRef;
@property CGGradientRef blueGradientRef;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation SCGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberFormatter = [[NSNumberFormatter alloc] init];
    }
    return self;
}

- (void)dealloc {
    CGGradientRelease(self.backgroundGradientRef);
    CGGradientRelease(self.blueGradientRef);
}

#pragma mark - Drawing Methods

/*
 * The instigating method for drawing the graph
 * clips to the rounded rect
 * draws the components
 */
- (void)drawRect:(CGRect)rect {
    
    CGRect dataRect = self.bounds;
    
    // clip to the rounded rect
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(16.0, 16.0)];
    [path addClip];
    [self _drawBackgroundGradient];
    [self _drawVerticalGridInRect:dataRect];
    [self _drawHorizontalGridInRect:dataRect clip:YES];
    [self _drawPatternArtUnderClosingData:dataRect clip:YES];
    [self _drawPatternLinesUnderDataPoints:dataRect clip:YES];
    [self _drawLineForDataPointsInRect:dataRect];
    [self _drawLabelsUnderDataRect:dataRect];
}


#pragma mark -
#pragma mark Clipping Paths

/*
 * Creates and returns a path that can be used to clip drawing to the top
 * of the data graph.
 */
- (UIBezierPath *)topClipPathFromDataInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[self _linePathForDataPointsInRect:rect]];
    CGPoint currentPoint = [path currentPoint];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), currentPoint.y)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), self.initialDataPointLocation.y)];
    [path addLineToPoint:CGPointMake(self.initialDataPointLocation.x, self.initialDataPointLocation.y)];
    [path closePath];
    return path;
}

/*
 * Creates and returns a path that can be used to clip drawing to the bottom
 * of the data graph.
 */
- (UIBezierPath *)bottomClipPathFromDataInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[self _linePathForDataPointsInRect:rect]];
    CGPoint currentPoint = [path currentPoint];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), currentPoint.y)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), self.initialDataPointLocation.y)];
    [path addLineToPoint:CGPointMake(self.initialDataPointLocation.x, self.initialDataPointLocation.y)];
    [path closePath];
    return path;
}


#pragma mark -
#pragma mark Draw Month Names

/*
 * Draws the month names, reterived from the NSDateFormatter.
 */
- (void)_drawLabelsUnderDataRect:(CGRect)dataRect {
    NSInteger dataCount = [[self dataSource] numberOfDataPointsInGraphView:self];

    [[UIColor whiteColor] setFill];
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGFloat shadowHeight = 2.0;
    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, -shadowHeight), 0.0, [[UIColor darkGrayColor] CGColor]);
    for(int i = 0; i < dataCount; i++) {
        
        CGFloat linePosition = i * ( CGRectGetWidth(self.bounds) / dataCount );
        CGContextTranslateCTM(ctx, linePosition, 0.0);
        NSString *labelString = [self.dataSource graphView:self labelForDataPointAtIndex:i];
        CGSize labelSize = [labelString sizeWithAttributes:@{NSFontAttributeName: font}];
        CGRect labelRect = CGRectMake(0.0,
                                      CGRectGetMaxY(dataRect) + shadowHeight,
                                      labelSize.width,
                                      labelSize.height);
        [labelString drawInRect:labelRect withAttributes:@{NSFontAttributeName: font}];
    }
    CGContextRestoreGState(ctx);
}


#pragma mark -
#pragma mark Draw Line for Data Points

/*
 * Draws the path for the closing price data set.
 */
- (void)_drawLineForDataPointsInRect:(CGRect)rect {
    [[UIColor whiteColor] setStroke];
    UIBezierPath *path = [self _linePathForDataPointsInRect:rect];
    [path stroke];
}

/*
 * The path for the closing data, this is used to draw the graph, and as part of the 
 * top and bottom clip paths.
 */
- (UIBezierPath *)_linePathForDataPointsInRect:(CGRect)rect {
    CGFloat maxY = [self.dataSource graphViewMaxYValue:self];
    CGFloat minY = [self.dataSource graphViewMinYValue:self];
    NSInteger dataCount = [self.dataSource numberOfDataPointsInGraphView:self];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // even though this lineWidth is odd, we don't do any offset because its not going to
    // ever line up with any pixels, just think geometrically
    CGFloat lineWidth = 2.0;
    [path setLineWidth:lineWidth];
    [path setLineJoinStyle:kCGLineJoinRound];
    [path setLineCapStyle:kCGLineCapRound];
    // inset so the path does not ever go beyond the frame of the graph
    rect = CGRectInset(rect, lineWidth / 2.0, lineWidth);
    CGFloat horizontalSpacing = CGRectGetWidth(rect) / dataCount;
    CGFloat verticalScale = CGRectGetHeight(rect) / (maxY - minY);
    for(int i = 0; i < dataCount; i++) {
        
        NSNumber *dataPointNumber = [self.dataSource graphView:self dataPointForIndex:i];
        NSParameterAssert(dataPointNumber);
        
        CGFloat dataPoint = [dataPointNumber floatValue];
        CGFloat baseline = CGRectGetMinY(rect);
        CGFloat topline = CGRectGetMaxY(rect);
        CGFloat yValue = topline - (baseline + (dataPoint - minY) * verticalScale);
        
        if (i == 1) {
            self.initialDataPointLocation = CGPointMake(lineWidth / 2.0,
                                                        yValue);
            [path moveToPoint:self.initialDataPointLocation];
        }
        
        [path addLineToPoint:CGPointMake((i + 1) * horizontalSpacing,
                                         yValue)];
        
    }
    
    return path;
}

#pragma mark -
#pragma mark Draw Patterns Beneath Line

/*
 * Draws the line pattern, slowly changing the alpha of the stroke color
 * from 0.8 to 0.2.
 */
- (void)_drawPatternLinesUnderDataPoints:(CGRect)rect clip:(BOOL)shouldClip {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(shouldClip) {
        CGContextSaveGState(ctx);
        UIBezierPath *clipPath = [self bottomClipPathFromDataInRect:rect];
        [clipPath addClip];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat lineWidth = 1.0;
    [path setLineWidth:lineWidth];
    // because the line width is odd, offset the horizontal lines by 0.5 points
    [path moveToPoint:CGPointMake(0.0, rint(CGRectGetMinY(rect)) + 0.5)];
    [path addLineToPoint:CGPointMake(rint(CGRectGetMaxX(rect)), rint(CGRectGetMinY(rect)) + 0.5)];
    CGFloat alpha = 0.8;
    UIColor *startColor = [UIColor colorWithWhite:1.0 alpha:alpha];
    [startColor setStroke];
    CGFloat step = 4.0;
    CGFloat stepCount = CGRectGetHeight(rect) / step;
    // alpha starts at 0.8, ends at 0.2
    CGFloat alphaStep = (0.8 - 0.2) / stepCount;
    CGContextSaveGState(ctx);
    CGFloat translation = CGRectGetMinY(rect);
    while(translation < CGRectGetMaxY(rect)) {
        [path stroke];
        CGContextTranslateCTM(ctx, 0.0, lineWidth * step);
        translation += lineWidth * step;
        alpha -= alphaStep;
        startColor = [startColor colorWithAlphaComponent:alpha];
        [startColor setStroke];
    }
    CGContextRestoreGState(ctx);
    if(shouldClip) {
        CGContextRestoreGState(ctx);
    }
}

/*
 * This method creates the blue gradient used behind the 'programmer art' pattern
 */
- (CGGradientRef)blueBlendGradient {
    if(NULL == self.blueGradientRef) {
        CGFloat colors[8] = {0.0, 80.0 / 255.0, 89.0 / 255.0, 1.0,
            0.0, 50.0f / 255.0, 64.0 / 255.0, 1.0};
        CGFloat locations[2] = {0.0, 0.90};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        self.blueGradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
        CGColorSpaceRelease(colorSpace);
    }
    return self.blueGradientRef;
}

/*
 * This method draws the line used behind the 'programmer art' pattern
 */
- (void)drawLineFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:2.0];
    [path moveToPoint:start];
    [path addLineToPoint:end];
    [path stroke];
}

/*
 * This method draws the blue gradient used behind the 'programmer art' pattern
 */
- (void)drawRadialGradientInSize:(CGSize)size centeredAt:(CGPoint)center {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat startRadius = 0.0;
    CGFloat endRadius = 0.85 * pow(floor(size.width / 2.0) * floor(size.width / 2.0) +
                                   floor(size.height / 2.0) * floor(size.height / 2.0), 0.5);
    CGContextDrawRadialGradient(ctx, [self blueBlendGradient],  center, startRadius, center,
                                endRadius, kCGGradientDrawsAfterEndLocation);
}

/*
 * This method creates a UIImage from the 'programmer art' pattern
 */
- (UIImage *)patternImageOfSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    CGPoint center = CGPointMake(floor(size.width / 2.0), floor(size.height / 2.0));
    [self drawRadialGradientInSize:size centeredAt:center];
    UIColor *lineColor = [UIColor colorWithRed:211.0 / 255.0 
                                         green:218.0 / 255.0
                                          blue:182.0 / 255.0
                                         alpha:1.0];
    [lineColor setStroke];
    
    CGPoint start = CGPointMake(0.0, 0.0);
    CGPoint end = CGPointMake(floor(size.width), floor(size.height));
    [self drawLineFromPoint:start toPoint:end];
    
    start = CGPointMake(0.0, floor(size.height));
    end = CGPointMake(floor(size.width), 0.0);
    [self drawLineFromPoint:start toPoint:end];
    
    UIImage *patternImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return patternImage;
}

/*
 * draws the 'programmer art' pattern under the closing data graph
 */
- (void)_drawPatternArtUnderClosingData:(CGRect)rect clip:(BOOL)shouldClip {
    [[UIColor colorWithPatternImage:[self patternImageOfSize:CGSizeMake(32.0, 32.0)]] setFill];
    if(shouldClip) {
        UIBezierPath *path = [self bottomClipPathFromDataInRect:rect];
        [path fill];
    } else {
        UIRectFill(rect);
    }
}


#pragma mark -
#pragma mark Draw Horizontal Grid

/*
 * draws the horizontal lines that make up the grid
 * if shouldClip then it will clip to the data
 * if not then it won't
 * shouldClip is a debugging tool, pass YES most of the time
 */
- (void)_drawHorizontalGridInRect:(CGRect)dataRect clip:(BOOL)shouldClip {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(shouldClip) {
        CGContextSaveGState(ctx);
        UIBezierPath *clipPath = [self topClipPathFromDataInRect:dataRect];
        [clipPath addClip];
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:1.0];
    [path moveToPoint:CGPointMake(rint(CGRectGetMinX(dataRect)),
                                  rint(CGRectGetMinY(dataRect)) + 0.5)];
    [path addLineToPoint:CGPointMake(rint(CGRectGetMaxX(dataRect)),
                                     rint(CGRectGetMinY(dataRect)) + 0.5)];
    CGFloat dashPatern[2] = {1.0, 1.0};
    [path setLineDash:dashPatern count:2 phase:0.0];
    UIColor *gridColor = [UIColor colorWithRed:74.0 / 255.0 green:86.0 / 255.0 
                                          blue:126.0 / 266.0 alpha:1.0];
    [gridColor setStroke];
    
    CGContextSaveGState(ctx);
    [path stroke];
    for(int i = 0;i < 5;i++) {
        CGContextTranslateCTM(ctx, 0.0, rint(CGRectGetHeight(dataRect) / 5.0));
        [path stroke];
    }
    CGContextRestoreGState(ctx);
    if(shouldClip) {
        CGContextRestoreGState(ctx);
    }
}


#pragma mark -
#pragma mark Draw Vertical Grid

/*
 * Draws the vertical grid that sits behind the data
 * makes sure not to step into the space needed by the
 * volume graph and the price labels
 */
- (void)_drawVerticalGridInRect:(CGRect)dataRect {
    UIColor *gridColor = [UIColor colorWithRed:74.0 / 255.0 green:86.0 / 255.0 
                                          blue:126.0 / 266.0 alpha:1.0];
    [gridColor setStroke];
    
    NSInteger dataCount = [[self dataSource] numberOfDataPointsInGraphView:self];
    
    UIBezierPath *gridLinePath = [UIBezierPath bezierPath];
    [gridLinePath moveToPoint:CGPointMake(rint(CGRectGetMinX(dataRect)), CGRectGetMinY(dataRect))];
    [gridLinePath addLineToPoint:CGPointMake(rint(CGRectGetMinX(dataRect)), CGRectGetMaxY(dataRect))];
    [gridLinePath setLineWidth:2.0];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    for(int i = 0; i < dataCount; i++) {
        CGFloat linePosition = i * ( CGRectGetWidth(self.bounds) / dataCount );
        CGContextTranslateCTM(ctx, rint(linePosition), 0.0);
        [gridLinePath stroke];
    }
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, rint(CGRectGetMaxX(dataRect)), 0.0);
    [gridLinePath stroke];
    CGContextRestoreGState(ctx);
    
//    UIBezierPath *horizontalLine = [UIBezierPath bezierPath];
//    [horizontalLine moveToPoint:CGPointMake(rint(CGRectGetMinX(dataRect)), rint(CGRectGetMaxY(dataRect)))];
//    [horizontalLine addLineToPoint:CGPointMake(rint(CGRectGetMaxX(dataRect)), rint(CGRectGetMaxY(dataRect)))];
//    [horizontalLine setLineWidth:2.0];
//    [horizontalLine stroke];
//    CGContextSaveGState(ctx);
//    [horizontalLine stroke];
//    CGContextRestoreGState(ctx);
}


#pragma mark -
#pragma mark Background Gradient

/*
 * Creates the blue background gradient
 */
- (CGGradientRef)backgroundGradient {
    if(NULL == self.backgroundGradientRef) {
        // lazily create the gradient, then reuse it
        CGFloat colors[16] = {48.0 / 255.0, 61.0 / 255.0, 114.0 / 255.0, 1.0,
            33.0 / 255.0, 47.0 / 255.0, 113.0 / 255.0, 1.0,
            20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0,
            20.0 / 255.0, 33.0 / 255.0, 104.0 / 255.0, 1.0 };
        CGFloat colorStops[4] = {0.0, 0.5, 0.5, 1.0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        self.backgroundGradientRef = CGGradientCreateWithColorComponents(colorSpace, colors, colorStops, 4);
        CGColorSpaceRelease(colorSpace);
    }
    return self.backgroundGradientRef;
}

/*
 * draws the blue background gradient
 */
- (void)_drawBackgroundGradient {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint startPoint = {0.0, 0.0};
    CGPoint endPoint = {0.0, self.bounds.size.height};
    CGContextDrawLinearGradient(ctx, [self backgroundGradient], startPoint, endPoint,0);
}


#pragma mark -
#pragma mark Layout Calculations

- (CGFloat)_labelWidth {
    // tweaked till it looked good
    CGFloat minimum = 32.0;
    CGFloat maximum = 54.0;
    NSNumber *number = [NSNumber numberWithDouble:[[self dataSource] graphViewMaxYValue:self]];
    CGSize size = [[self.numberFormatter stringFromNumber:number] sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    CGFloat width = minimum;
    if(size.width < maximum && size.width > minimum) {
        width = size.width;
    }
    return width;
}

@end

@implementation SCGraphView (Extras)

/*
 * call this method after drawVolumeDataInRect: in the drawRect: method
 * and see what exciting drawing results.
 */
- (void)drawBeachUnderDataInRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    UIBezierPath *clipPath = [self bottomClipPathFromDataInRect:rect];
    [clipPath addClip];
    UIImage *image = [UIImage imageNamed:@"Beach.png"];
    [image drawInRect:rect];
}

/*
 * used to get the shadowed circles shown in the preso
 * not called as part of this sample, but here for your illumination 
 */
- (void)drawShadowedCirclesInRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGFloat shadowHeight = 16.0;
    CGFloat radius = CGRectGetHeight(rect) / 2.5;
    CGContextSetShadowWithColor(ctx, CGSizeMake(shadowHeight, shadowHeight), 5.0,
                                [[[UIColor purpleColor] colorWithAlphaComponent:0.7] CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                                                        radius:radius startAngle:0.0
                                                      endAngle:2.0 * M_PI clockwise:YES];
    UIColor *color1 = [UIColor colorWithRed:99.0 / 255.0 green:66.0 / 255.0
                                       blue:58.0 / 255.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:149.0 / 255.0 green:64.0 / 255.0
                                       blue:73.0 / 255.0 alpha:1.0];
    UIColor *color3 = [UIColor colorWithRed:195.0 / 255.0 green:111.0 / 255.0
                                       blue:97.0 / 255.0 alpha:1.0];
    CGContextBeginTransparencyLayer(ctx, NULL);
    [color1 setFill];
    CGContextTranslateCTM(ctx, -radius / 2.0, 0.0);
    [path fill];
    [color2 setFill];
    CGContextTranslateCTM(ctx, 1.25 * radius, 0.75 * radius);
    [path fill];
    [color3 setFill];
    CGContextTranslateCTM(ctx, 0.0, -1.5 * radius);
    [path fill];
    CGContextEndTransparencyLayer(ctx);
    CGContextRestoreGState(ctx);
}

@end
