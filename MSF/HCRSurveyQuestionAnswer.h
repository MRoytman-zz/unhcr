//
//  HCRSurveyFormAnswers.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@interface HCRSurveyQuestionAnswer : HCRArchivalObject

@property (nonatomic, strong) NSNumber *code;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *freeform;

+ (HCRSurveyQuestionAnswer *)newAnswerWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)newAnswersFromArray:(NSArray *)array;

@end
