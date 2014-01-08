//
//  HCRSurveyFormConditions.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionCondition.h"

@implementation HCRSurveyQuestionCondition

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.participantID = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsParticipantID];
        self.minimumParticipants = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsMinParticipants];
        self.response = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsResponse];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.participantID forKey:HCRPrefKeyQuestionsConditionsParticipantID];
    [encoder encodeObject:self.minimumParticipants forKey:HCRPrefKeyQuestionsConditionsMinParticipants];
    [encoder encodeObject:self.response forKey:HCRPrefKeyQuestionsConditionsResponse];
}

//- (NSArray *)propertyList {
//    return @[
//             NSStringFromSelector(@selector(participantID)),
//             NSStringFromSelector(@selector(minimumParticipants)),
//             NSStringFromSelector(@selector(response))
//             ];
//}

#pragma mark - Class Methods

+ (HCRSurveyQuestionCondition *)newConditionWithDictionary:(NSDictionary *)dictionary {
    
    HCRSurveyQuestionCondition *newCondition = [HCRSurveyQuestionCondition new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyQuestionsConditionsParticipantID]) {
            newCondition.participantID = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsMinParticipants]) {
            newCondition.minimumParticipants = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsResponse]) {
            newCondition.response = [HCRSurveyQuestionConditionResponse newResponseWithDictionary:object];
        }
        
    }
    
    return newCondition;
    
}

+ (NSArray *)newConditionsArrayFromArray:(NSArray *)array {
    
    NSParameterAssert([array isKindOfClass:[NSArray class]]);
    
    NSMutableArray *newConditions = @[].mutableCopy;
    
    for (NSDictionary *dictionary in array) {
        HCRSurveyQuestionCondition *newCondition = [HCRSurveyQuestionCondition newConditionWithDictionary:dictionary];
        
        [newConditions addObject:newCondition];
    }
    
    return newConditions;
    
}

@end
