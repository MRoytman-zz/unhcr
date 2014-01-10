//
//  HCRSurveyFormConditions.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"
#import "HCRSurveyQuestionConditionResponse.h"

@interface HCRSurveyQuestionCondition : HCRArchivalObject

@property (nonatomic, strong) NSNumber *participantID;
@property (nonatomic, strong) NSNumber *minimumParticipants;
@property (nonatomic, strong) HCRSurveyQuestionConditionResponse *response;
@property (nonatomic, strong) NSNumber *minimumAge;
@property (nonatomic, strong) NSNumber *maximumAge;
@property (nonatomic, strong) NSNumber *gender;

+ (HCRSurveyQuestionCondition *)newConditionWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)newConditionsArrayFromArray:(NSArray *)array;

@end
