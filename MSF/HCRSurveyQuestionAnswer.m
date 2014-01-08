//
//  HCRSurveyFormAnswers.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionAnswer.h"
#import "HCRDataManager.h"

@implementation HCRSurveyQuestionAnswer

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.code = [decoder decodeObjectForKey:HCRPrefKeyQuestionsAnswersCode];
        self.string = [decoder decodeObjectForKey:HCRPrefKeyQuestionsAnswersString];
        self.freeform = [decoder decodeObjectForKey:HCRPrefKeyQuestionsAnswersFreeform];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.code forKey:HCRPrefKeyQuestionsAnswersCode];
    [encoder encodeObject:self.string forKey:HCRPrefKeyQuestionsAnswersString];
    [encoder encodeObject:self.freeform forKey:HCRPrefKeyQuestionsAnswersFreeform];
}

//- (NSArray *)propertyList {
//    return @[
//             NSStringFromSelector(@selector(code)),
//             NSStringFromSelector(@selector(string)),
//             NSStringFromSelector(@selector(freeform)),
//             ];
//}

#pragma mark - Class Methods

+ (HCRSurveyQuestionAnswer *)newAnswerWithDictionary:(NSDictionary *)dictionary {
    
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    HCRSurveyQuestionAnswer *newAnswer = [HCRSurveyQuestionAnswer new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyQuestionsAnswersCode]) {
            newAnswer.code = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsAnswersString]) {
            newAnswer.string = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsAnswersFreeform]) {
            newAnswer.freeform = object;
        }
        
    }
    
    return newAnswer;
}

+ (NSArray *)newAnswersFromArray:(NSArray *)array {
    
    NSParameterAssert([array isKindOfClass:[NSArray class]]);
    
    NSMutableArray *newAnswers = @[].mutableCopy;
    
    for (NSDictionary *dictionary in array) {
        HCRSurveyQuestionAnswer *newAnswer = [HCRSurveyQuestionAnswer newAnswerWithDictionary:dictionary];
        [newAnswers addObject:newAnswer];
    }
    
    return newAnswers;
    
}

@end
