//
//  HCRSurveyQuestionFooter.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionFooter.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyQuestionFooter ()

@property UIColor *unansweredBackgroundColor;
@property UIColor *defaultBackgroundColor;

@end

////////////////////////////////////////////////////////////////////////////////


@implementation HCRSurveyQuestionFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.defaultBackgroundColor = [UIColor tableBackgroundColor];
        self.unansweredBackgroundColor = [UIColor headerUnansweredBackgroundColor];
        self.backgroundColor = self.defaultBackgroundColor;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    self.backgroundColor = (self.questionAnswered) ? self.defaultBackgroundColor : self.unansweredBackgroundColor;
    
}

#pragma mark - Getters & Setters

- (void)setQuestionAnswered:(BOOL)questionAnswered {
    _questionAnswered = questionAnswered;
    [self setNeedsLayout];
}

@end
