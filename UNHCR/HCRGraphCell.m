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

static const CGFloat kDefaultGraphPadding = 0.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRGraphCell ()

@property (nonatomic, readonly) CGRect graphViewFrame;

@property (nonatomic, readwrite) SCGraphView *graphView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRGraphCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.bottomLineView.hidden = YES;
        
        self.xGraphPadding = kDefaultGraphPadding;
        self.yGraphPadding = kDefaultGraphPadding;
        
        self.graphView = [[SCGraphView alloc] initWithFrame:self.graphViewFrame];
        [self.contentView addSubview:self.graphView];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bottomLineView.hidden = YES;
    self.graphDataSource = nil;
    self.graphDelegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.graphView.frame = self.graphViewFrame;
    [self.graphView setNeedsDisplay];
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredHeightForGraphCell {
    return 200;
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      [HCRGraphCell preferredHeightForGraphCell]);
    
}

#pragma mark - Getters & Setters

- (CGRect)graphViewFrame {
    return CGRectMake(self.indentForContent + self.xGraphOffset + self.xGraphPadding,
                      self.yGraphOffset + self.yGraphPadding,
                      CGRectGetWidth(self.bounds) - self.indentForContent - self.xGraphOffset - 2 * self.xGraphPadding - self.xGraphTrailingSpace,
                      CGRectGetHeight(self.bounds) - self.yGraphOffset - 2 * self.yGraphPadding - self.yGraphTrailingSpace);
}

- (void)setIndentForContent:(CGFloat)indentForContent {
    [super setIndentForContent:indentForContent];
    [self setNeedsLayout];
}

- (void)setXGraphOffset:(CGFloat)xGraphOffset {
    _xGraphOffset = xGraphOffset;
    [self setNeedsLayout];
}

- (void)setYGraphOffset:(CGFloat)yGraphOffset {
    _yGraphOffset = yGraphOffset;
    [self setNeedsLayout];
}

- (void)setXGraphPadding:(CGFloat)xGraphPadding {
    _xGraphPadding = xGraphPadding;
    [self setNeedsLayout];
}

- (void)setYGraphPadding:(CGFloat)yGraphPadding {
    _yGraphPadding = yGraphPadding;
    [self setNeedsLayout];
}

- (void)setXGraphTrailingSpace:(CGFloat)xGraphTrailingSpace {
    _xGraphTrailingSpace = xGraphTrailingSpace;
    [self setNeedsLayout];
}

- (void)setYGraphTrailingSpace:(CGFloat)yGraphTrailingSpace {
    _yGraphTrailingSpace = yGraphTrailingSpace;
    [self setNeedsLayout];
}

- (void)setDataLabel:(NSString *)dataLabel {
    _dataLabel = dataLabel;
    
    self.graphView.dataLabelString = dataLabel;
    [self setNeedsLayout];
    
}

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
