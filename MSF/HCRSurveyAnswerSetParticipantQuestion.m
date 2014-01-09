//
//  HCRSurveyResponseParticipantEntry.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerSetParticipantQuestion.h"
#import "HCRDataManager.h"

@implementation HCRSurveyAnswerSetParticipantQuestion

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.question = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion];
        self.answer = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer];
        self.answerString = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.question forKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion];
    [encoder encodeObject:self.answer forKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer];
    [encoder encodeObject:self.answerString forKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString];
}

//- (NSArray *)propertyList {
//    return @[
//             NSStringFromSelector(@selector(question)),
//             NSStringFromSelector(@selector(answer))
//             ];
//}

#pragma mark - Class Methods

+ (HCRSurveyAnswerSetParticipantQuestion *)newQuestionWithDictionary:(NSDictionary *)dictionary {
    
    NSParameterAssert([dictionary isKindOfClass:[NSDictionary class]]);
    
    HCRSurveyAnswerSetParticipantQuestion *newQuestion = [HCRSurveyAnswerSetParticipantQuestion new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion]) {
            newQuestion.question = object;
        } else if ([key isEqualToString:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer]) {
            newQuestion.answer = object;
        } else if ([key isEqualToString:HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString]) {
            newQuestion.answerString = object;
        }
        
    }
    
    return newQuestion;
}

@end
