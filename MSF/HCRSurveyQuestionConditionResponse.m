//
//  HCRSurveyQuestionAnswerConditionResponse.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionConditionResponse.h"

@implementation HCRSurveyQuestionConditionResponse

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.question = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsResponseQuestion];
        self.answer = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsResponseAnswer];
        self.answerArray = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsResponseAnswerArray];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.question forKey:HCRPrefKeyQuestionsConditionsResponseQuestion];
    [encoder encodeObject:self.answer forKey:HCRPrefKeyQuestionsConditionsResponseAnswer];
    [encoder encodeObject:self.answerArray forKey:HCRPrefKeyQuestionsConditionsResponseAnswerArray];
}

#pragma mark - Class Methods

+ (HCRSurveyQuestionConditionResponse *)newResponseWithDictionary:(NSDictionary *)dictionary {
    
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    HCRSurveyQuestionConditionResponse *newResponse = [HCRSurveyQuestionConditionResponse new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyQuestionsConditionsResponseQuestion]) {
            newResponse.question = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsResponseAnswer]) {
            NSParameterAssert([object isKindOfClass:[NSNumber class]]);
            newResponse.answer = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsResponseAnswerArray]) {
            NSParameterAssert([object isKindOfClass:[NSArray class]]);
            newResponse.answerArray = object;
        }
        
    }
    
    return newResponse;
    
}

@end
