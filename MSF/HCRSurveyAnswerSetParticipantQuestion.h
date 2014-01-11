//
//  HCRSurveyResponseParticipantEntry.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@interface HCRSurveyAnswerSetParticipantQuestion : HCRArchivalObject

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic, strong) NSString *answerString;

+ (HCRSurveyAnswerSetParticipantQuestion *)newQuestionWithDictionary:(NSDictionary *)dictionary;

- (NSComparisonResult)compareToParticipantQuestion:(HCRSurveyAnswerSetParticipantQuestion *)question;

@end
