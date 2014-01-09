//
//  HCRAnswerSetCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/8/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAnswerSetCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRAnswerSetCell ()

@property UIView *percentCompleteView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAnswerSetCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.percentCompleteView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.percentCompleteView];
        
        self.percentCompleteView.backgroundColor = [UIColor cellAnsweredBackgroundColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.percentComplete = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.percentCompleteView.frame = CGRectMake(0,
                                                0,
                                                (self.percentComplete / 100.0) * CGRectGetWidth(self.contentView.bounds),
                                                CGRectGetHeight(self.contentView.bounds));
    
}

#pragma mark - Getters & Setters

- (void)setPercentComplete:(NSInteger)percentComplete {
    _percentComplete = percentComplete;
    [self setNeedsLayout];
}

@end
