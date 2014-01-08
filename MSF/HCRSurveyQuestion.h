//
//  HCRSurveyForm.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@interface HCRSurveyQuestion : HCRArchivalObject

@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *questionString;
@property (nonatomic, strong) NSString *questionCode;
@property (nonatomic, strong) NSArray *conditions;
@property (nonatomic, strong) NSNumber *defaultAnswer;
@property (nonatomic, strong) NSNumber *skip;
@property (nonatomic, strong) NSNumber *numberOfAnswersRequired;
@property (nonatomic, strong) NSString *freeformLabel;
@property (nonatomic, strong) NSString *keyboard;
@property (nonatomic, strong) NSString *note;

+ (HCRSurveyQuestion *)newQuestionWithDictionary:(NSDictionary *)dictionary;

@end
