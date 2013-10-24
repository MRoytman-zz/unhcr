//
//  HCRGraphCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRGraphCell.h"
#import "SCGraphView.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRGraphCell ()

@property (nonatomic, readwrite) SCGraphView *graphView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRGraphCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        static const CGFloat kGraphOffset = 0.0;
        CGRect graphFrame = CGRectMake(kGraphOffset,
                                       kGraphOffset,
                                       CGRectGetWidth(self.bounds) - 2 * kGraphOffset,
                                       CGRectGetHeight(self.bounds) - 2 * kGraphOffset);
        
        self.graphView = [[SCGraphView alloc] initWithFrame:graphFrame];
        [self addSubview:self.graphView];
        
    }
    return self;
}

- (void)prepareForReuse {
    self.graphDataSource = nil;
    self.graphDelegate = nil;
}

#pragma mark - Class Methods

+ (CGFloat)preferredHeightForGraphCell {
    return 200;
}

#pragma mark - Getters & Setters

- (void)setGraphDelegate:(id<SCGraphViewDelegate>)graphDelegate {
    
    _graphDelegate = graphDelegate;
    
    self.graphView.delegate = graphDelegate;
    
    [self.graphView setNeedsDisplay];
    
}

- (void)setGraphDataSource:(id<SCGraphViewDataSource>)graphDataSource {
    
    _graphDataSource = graphDataSource;
    
    self.graphView.dataSource = graphDataSource;
    
    [self.graphView setNeedsDisplay];
    
}

@end
