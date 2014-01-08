//
//  HCRSurveyForm.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestion.h"
#import "HCRDataManager.h"

@implementation HCRSurveyQuestion

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.answers = [decoder decodeObjectForKey:HCRPrefKeyQuestionsAnswers];
        self.updatedAt = [decoder decodeObjectForKey:HCRPrefKeyQuestionsUpdated];
        self.questionString = [decoder decodeObjectForKey:HCRPrefKeyQuestionsQuestion];
        self.questionCode = [decoder decodeObjectForKey:HCRPrefKeyQuestionsQuestionCode];
        self.conditions = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditions];
        self.defaultAnswer = [decoder decodeObjectForKey:HCRPrefKeyQuestionsDefaultAnswer];
        self.skip = [decoder decodeObjectForKey:HCRPrefKeyQuestionsSkip];
        self.numberOfAnswersRequired = [decoder decodeObjectForKey:HCRPrefKeyQuestionsRequiredAnswers];
        self.freeformLabel = [decoder decodeObjectForKey:HCRPrefKeyQuestionsFreeformLabel];
        self.keyboard = [decoder decodeObjectForKey:HCRPrefKeyQuestionsKeyboard];
        self.note = [decoder decodeObjectForKey:HCRPrefKeyQuestionsNote];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.answers forKey:HCRPrefKeyQuestionsAnswers];
    [encoder encodeObject:self.updatedAt forKey:HCRPrefKeyQuestionsUpdated];
    [encoder encodeObject:self.questionString forKey:HCRPrefKeyQuestionsQuestion];
    [encoder encodeObject:self.questionCode forKey:HCRPrefKeyQuestionsQuestionCode];
    [encoder encodeObject:self.conditions forKey:HCRPrefKeyQuestionsConditions];
    [encoder encodeObject:self.defaultAnswer forKey:HCRPrefKeyQuestionsDefaultAnswer];
    [encoder encodeObject:self.skip forKey:HCRPrefKeyQuestionsSkip];
    [encoder encodeObject:self.numberOfAnswersRequired forKey:HCRPrefKeyQuestionsRequiredAnswers];
    [encoder encodeObject:self.freeformLabel forKey:HCRPrefKeyQuestionsFreeformLabel];
    [encoder encodeObject:self.keyboard forKey:HCRPrefKeyQuestionsKeyboard];
    [encoder encodeObject:self.note forKey:HCRPrefKeyQuestionsNote];
}

- (NSArray *)propertyList {
    return @[
             NSStringFromSelector(@selector(answers)),
             NSStringFromSelector(@selector(updatedAt)),
             NSStringFromSelector(@selector(questionString)),
             NSStringFromSelector(@selector(questionCode)),
             NSStringFromSelector(@selector(conditions)),
             NSStringFromSelector(@selector(defaultAnswer)),
             NSStringFromSelector(@selector(skip)),
             NSStringFromSelector(@selector(numberOfAnswersRequired)),
             NSStringFromSelector(@selector(freeformLabel)),
             NSStringFromSelector(@selector(keyboard)),
             NSStringFromSelector(@selector(note)),
             ];
}

#pragma mark - Class Methods

+ (HCRSurveyQuestion *)newQuestionWithDictionary:(NSDictionary *)dictionary {
    
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    HCRSurveyQuestion *newQuestion = [HCRSurveyQuestion new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyQuestionsAnswers]) {
            newQuestion.answers = [HCRSurveyQuestionAnswer newAnswersFromArray:object];
        } else if ([key isEqualToString:HCRPrefKeyQuestionsUpdated]) {
            newQuestion.updatedAt = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsQuestion]) {
            newQuestion.questionString = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsQuestionCode]) {
            newQuestion.questionCode = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditions]) {
            newQuestion.conditions = [HCRSurveyQuestionCondition newConditionsArrayFromArray:object];
        } else if ([key isEqualToString:HCRPrefKeyQuestionsDefaultAnswer]) {
            newQuestion.defaultAnswer = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsSkip]) {
            newQuestion.skip = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsRequiredAnswers]) {
            newQuestion.numberOfAnswersRequired = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsFreeformLabel]) {
            newQuestion.freeformLabel = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsKeyboard]) {
            newQuestion.keyboard = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsNote]) {
            newQuestion.note = object;
        }
        
    }
    
    return newQuestion;
    
}

@end
