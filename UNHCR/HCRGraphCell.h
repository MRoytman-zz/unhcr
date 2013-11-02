//
//  HCRGraphCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

#import "SCGraphView.h"

@interface HCRGraphCell : HCRCollectionCell

+ (CGFloat)preferredHeightForGraphCell;

@property (nonatomic) CGFloat xGraphOffset;
@property (nonatomic) CGFloat yGraphOffset;

@property (nonatomic) CGFloat xGraphPadding;
@property (nonatomic) CGFloat yGraphPadding;

@property (nonatomic) CGFloat xGraphTrailingSpace;
@property (nonatomic) CGFloat yGraphTrailingSpace;

@property (nonatomic, weak) id<SCGraphViewDelegate> graphDelegate;
@property (nonatomic, weak) id<SCGraphViewDataSource> graphDataSource;

@property (nonatomic, readonly) SCGraphView *graphView;

@property (nonatomic, strong) NSString *dataLabel;

@end
