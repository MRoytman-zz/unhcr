//
//  HCRCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/27/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kBottomLineOffset = 14.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCollectionCell ()

@property (nonatomic, readwrite) UIView *bottomLineView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // bottom line
        static const CGFloat kLineHeight = 0.5;
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(kBottomLineOffset,
                                                                          CGRectGetHeight(self.bounds) - kLineHeight,
                                                                          CGRectGetWidth(self.bounds) - kBottomLineOffset,
                                                                          kLineHeight)];
        [self addSubview:self.bottomLineView];
        
        self.bottomLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bottomLineView.hidden = NO;
}

@end
