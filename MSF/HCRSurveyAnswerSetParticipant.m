//
//  HCRSurveyResponseParticipant.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerSetParticipant.h"
#import "HCRSurveyAnswerSet.h"
#import "HCRSurveyAnswerSetParticipantQuestion.h"

@implementation HCRSurveyAnswerSetParticipant

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.participantID = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsID];
        self.age = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsAge];
        self.gender = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsGender];
        self.questions = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipantsResponses];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.participantID forKey:HCRPrefKeyAnswerSetsParticipantsID];
    [encoder encodeObject:self.age forKey:HCRPrefKeyAnswerSetsParticipantsAge];
    [encoder encodeObject:self.gender forKey:HCRPrefKeyAnswerSetsParticipantsGender];
    [encoder encodeObject:self.questions forKey:HCRPrefKeyAnswerSetsParticipantsResponses];
}

#pragma mark - Class Methods

+ (HCRSurveyAnswerSetParticipant *)newParticipantForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    HCRSurveyAnswerSetParticipant *participant = [HCRSurveyAnswerSetParticipant new];
    
    HCRSurveyAnswerSetParticipant *lastParticipant = (HCRSurveyAnswerSetParticipant *)[answerSet.participants lastObject];
    participant.participantID = (lastParticipant) ? @(lastParticipant.participantID.integerValue + 1) : @(0);
    
    participant.questions = @[].mutableCopy;
    
    return participant;
    
}

#pragma mark - Public Methods

- (HCRSurveyAnswerSetParticipantQuestion *)questionWithID:(NSString *)questionID {
    
    for (HCRSurveyAnswerSetParticipantQuestion *questionObject in self.questions) {
        if ([questionObject.question isEqualToString:questionID]) {
            return questionObject;
        }
    }
    
    return nil;
    
}

- (HCRSurveyAnswerSetParticipantQuestion *)firstUnansweredQuestion {
    
    for (HCRSurveyAnswerSetParticipantQuestion *questionObject in self.questions) {
        if (!questionObject.answer &&
            !questionObject.answerString) {
            return questionObject;
        }
    }
    
    return nil;
    
}

- (NSString *)localizedParticipantName {
    
    NSMutableString *participantString = (self.participantID.integerValue == 0) ? @"Head of Household".mutableCopy : [NSString stringWithFormat:@"Participant %@",self.participantID].mutableCopy;
    
    if (self.age && self.gender) {
        [participantString appendString:[NSString stringWithFormat:@" (%@/%@)",
                                         self.age,
                                         (self.gender.integerValue == 0) ? @"m" : @"f"]];
    }
    
    return participantString;
    
}

@end
