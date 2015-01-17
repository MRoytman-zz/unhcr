//
//  HCRSurveyAnswerFreeformCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerFreeformCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyAnswerFreeformCell ()

@property UIColor *answeredColor;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyAnswerFreeformCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.answeredColor = [UIColor cellAnsweredBackgroundColor];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.answered = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.backgroundColor = (self.answered) ? [UIColor cellAnsweredBackgroundColor] : self.defaultBackgroundColor;
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.inputTextField.backgroundColor = [UIColor clearColor];
    
}

#pragma mark - Getters & Setters

- (void)setAnswered:(BOOL)answered {
    _answered = answered;
    [self setNeedsLayout];
}

@end
