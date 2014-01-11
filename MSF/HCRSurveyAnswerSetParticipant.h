//
//  HCRSurveyResponseParticipant.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@class HCRSurveyAnswerSet;
@class HCRSurveyAnswerSetParticipantQuestion;

@interface HCRSurveyAnswerSetParticipant : HCRArchivalObject

@property (nonatomic, strong) NSNumber *participantID;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSMutableArray *questions;

+ (HCRSurveyAnswerSetParticipant *)newParticipantForAnswerSet:(HCRSurveyAnswerSet *)answerSet;

- (HCRSurveyAnswerSetParticipantQuestion *)questionWithID:(NSString *)questionID;
- (HCRSurveyAnswerSetParticipantQuestion *)firstUnansweredQuestion;

- (NSString *)localizedParticipantName;

@end
