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
        [self.contentView insertSubview:self.percentCompleteView belowSubview:self.titleLabel];
        
        self.percentCompleteView.backgroundColor = [UIColor cellAnsweredBackgroundColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.submitted = NO;
    self.percentComplete = 0;
    self.answerSetID = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // if the survey is completed, but not submitted, color yellow - else green
    self.percentCompleteView.backgroundColor = (!self.submitted) ? [[UIColor flatYellowColor] colorWithAlphaComponent:0.5] : [UIColor cellAnsweredBackgroundColor];
    
    self.percentCompleteView.frame = CGRectMake(0,
                                                0,
                                                (self.percentComplete / 100.0) * CGRectGetWidth(self.contentView.bounds),
                                                CGRectGetHeight(self.contentView.bounds));
    
    self.percentCompleteView.alpha = (self.processingAction) ? 0.5 : 1.0;
    self.titleLabel.alpha = (self.processingAction) ? 0.5 : 1.0;
    
}

#pragma mark - Getters & Setters

- (void)setPercentComplete:(NSInteger)percentComplete {
    _percentComplete = percentComplete;
    [self setNeedsLayout];
}

- (void)setSubmitted:(BOOL)submitted {
    _submitted = submitted;
    [self setNeedsLayout];
}

- (void)setProcessingAction:(BOOL)processingAction {
    [super setProcessingAction:processingAction];
    [self setNeedsLayout];
}

@end
