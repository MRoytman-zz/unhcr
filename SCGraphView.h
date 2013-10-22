/*
     File: SimpleStockView.h
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

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class SCGraphView;

////////////////////////////////////////////////////////////////////////////////

extern NSString *SCGraphTipDateKey;
extern NSString *SCGraphTipValueKey;

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, SCGraphIndexRoundingMode) {
    SCGraphIndexRoundingModeNormal,
    SCGraphIndexRoundingModeFloor,
    SCGraphIndexRoundingModeCeiling
};

typedef NS_ENUM(NSInteger, SCGraphAxis) {
    SCGraphAxisX,
    SCGraphAxisY
};

typedef NS_ENUM(NSInteger, SCDataTimePeriod) {
    SCDataTimePeriod30Days,
    SCDataTimePeriod7Days,
    SCDataTimePeriodYesterday
};

////////////////////////////////////////////////////////////////////////////////

@protocol SCGraphViewDelegate <NSObject>
@optional
- (void)graphViewBeganTouchingData:(SCGraphView *)graphView withTouches:(NSSet *)touches;
- (void)graphViewStoppedTouchingData:(SCGraphView *)graphView;
@end

////////////////////////////////////////////////////////////////////////////////

@protocol SCGraphViewDataSource <NSObject>
// Y value must be a number, likely a count of something
// X value is what's being counted; the label is fully dynamic
@required
- (CGFloat)graphViewMaxYValue:(SCGraphView *)graphView;
- (CGFloat)graphViewMinYValue:(SCGraphView *)graphView;
- (NSNumber *)graphView:(SCGraphView *)graphView dataPointForIndex:(NSInteger)index;
- (NSInteger)numberOfDataPointsInGraphView:(SCGraphView *)graphView;
- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index;
- (NSDictionary *)graphView:(SCGraphView *)graphView dictionaryForDataPointAtIndex:(NSInteger)index;
@end
                                                                           
////////////////////////////////////////////////////////////////////////////////

/*
 * The view that draws the stock info.
 */
@interface SCGraphView : UIView

@property (nonatomic, weak) id<SCGraphViewDelegate> delegate;
@property (nonatomic, weak) id<SCGraphViewDataSource> dataSource;

@property (nonatomic) SCDataTimePeriod displayedTimePeriod;
@property (nonatomic) SCGraphIndexRoundingMode roundingMode;

@property (nonatomic, strong) UIColor *dataLineColor;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, strong) UIColor *horizontalGuideLineColor;
@property (nonatomic, strong) UIColor *labelColor;

- (NSInteger)indexOfDataAtPoint:(CGPoint)point;

@end

