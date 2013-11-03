//
//  SCGraphView.h
//  UNHCR
//
//  Created by Sean Conrad on 10/22/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

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
- (void)graphView:(SCGraphView *)graphView didChangeSelectedIndex:(NSInteger)selectedIndex;
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
- (NSString *)graphView:(SCGraphView *)graphView labelForDataPointAtIndex:(NSInteger)index withTimeStamp:(BOOL)showTimeStamp;
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

@property (nonatomic, strong) NSString *dataLabelString;

@property (nonatomic, strong) UIColor *dataLineColor;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, strong) UIColor *horizontalGuideLineColor;
@property (nonatomic, strong) UIColor *labelColor;

- (NSInteger)indexOfDataAtPoint:(CGPoint)point;

@end

