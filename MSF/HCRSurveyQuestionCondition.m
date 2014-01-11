//
//  HCRSurveyFormConditions.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionCondition.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyQuestionCondition ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyQuestionCondition

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.orArray = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsOrArray];
        
        HCRDebug(@"orArray: %@",self.orArray);
        
        self.participantID = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsParticipantID];
        self.minimumParticipants = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsMinParticipants];
        self.response = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsResponse];
        self.minimumAge = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsMinAge];
        self.maximumAge = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsMaxAge];
        self.gender = [decoder decodeObjectForKey:HCRPrefKeyQuestionsConditionsGender];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.orArray forKey:HCRPrefKeyQuestionsConditionsOrArray];
    [encoder encodeObject:self.participantID forKey:HCRPrefKeyQuestionsConditionsParticipantID];
    [encoder encodeObject:self.minimumParticipants forKey:HCRPrefKeyQuestionsConditionsMinParticipants];
    [encoder encodeObject:self.response forKey:HCRPrefKeyQuestionsConditionsResponse];
    [encoder encodeObject:self.minimumAge forKey:HCRPrefKeyQuestionsConditionsMinAge];
    [encoder encodeObject:self.maximumAge forKey:HCRPrefKeyQuestionsConditionsMaxAge];
    [encoder encodeObject:self.gender forKey:HCRPrefKeyQuestionsConditionsGender];
}

#pragma mark - Class Methods

+ (HCRSurveyQuestionCondition *)newConditionWithDictionary:(NSDictionary *)dictionary {
    
    HCRSurveyQuestionCondition *newCondition = [HCRSurveyQuestionCondition new];
    
    for (NSString *key in dictionary.allKeys) {
        
        id object = [dictionary objectForKey:key];
        
        if ([key isEqualToString:HCRPrefKeyQuestionsConditionsOrArray]) {
            newCondition.orArray = [HCRSurveyQuestionCondition newConditionsArrayFromArray:object];
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsParticipantID]) {
            newCondition.participantID = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsMinParticipants]) {
            newCondition.minimumParticipants = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsResponse]) {
            newCondition.response = [HCRSurveyQuestionConditionResponse newResponseWithDictionary:object];
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsMinAge]) {
            newCondition.minimumAge = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsMaxAge]) {
            newCondition.maximumAge = object;
        } else if ([key isEqualToString:HCRPrefKeyQuestionsConditionsGender]) {
            newCondition.gender = object;
        } else {
            HCRError(@"Unhandled condition detected! %@",dictionary);
            NSAssert(NO, @"Unhandled condition detected!");
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
    
    return [NSArray arrayWithArray:newConditions];
    
}

@end
