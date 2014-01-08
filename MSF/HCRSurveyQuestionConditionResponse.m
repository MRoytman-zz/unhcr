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
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.question forKey:HCRPrefKeyQuestionsConditionsResponseQuestion];
    [encoder encodeObject:self.answer forKey:HCRPrefKeyQuestionsConditionsResponseAnswer];
}

- (NSArray *)propertyList {
    return @[
             NSStringFromSelector(@selector(question)),
             NSStringFromSelector(@selector(answer))
             ];
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
            newResponse.answer = object;
        }
        
    }
    
    return newResponse;
    
}

@end
