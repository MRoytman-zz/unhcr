//
//  HCRSurveyQuestionAnswerConditionResponse.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@interface HCRSurveyQuestionConditionResponse : HCRArchivalObject

@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSNumber *answer;
@property (nonatomic, strong) NSArray *answerArray;

+ (HCRSurveyQuestionConditionResponse *)newResponseWithDictionary:(NSDictionary *)dictionary;

@end
