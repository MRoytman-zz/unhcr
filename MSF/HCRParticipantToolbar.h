//
//  HCRParticipantToolbar.h
//  UNHCR
//
//  Created by Sean Conrad on 1/9/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCRSurveyAnswerSetParticipant;

@interface HCRParticipantToolbar : UIToolbar
<UIGestureRecognizerDelegate>

@property (nonatomic, strong) HCRSurveyAnswerSetParticipant *currentParticipant;
@property (nonatomic, strong) NSArray *participants;

@property (nonatomic, readonly) UIBarButtonItem *previousParticipant;
@property (nonatomic, readonly) UIBarButtonItem *nextParticipant;
@property (nonatomic, readonly) UIBarButtonItem *addParticipant;
@property (nonatomic, readonly) UIBarButtonItem *removeParticipant;

@property (nonatomic, readonly) UIColor *defaultToolbarColor;

@property (nonatomic, readonly) UIButton *centerButton;

@end
