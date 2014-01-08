//
//  HCRSurveyResponseParticipant.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerSetParticipant.h"
#import "HCRDataManager.h"
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

- (NSArray *)propertyList {
    return @[
             NSStringFromSelector(@selector(participantID)),
             NSStringFromSelector(@selector(age)),
             NSStringFromSelector(@selector(gender)),
             NSStringFromSelector(@selector(questions))
             ];
}

#pragma mark - Class Methods

+ (HCRSurveyAnswerSetParticipant *)newParticipantForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    HCRSurveyAnswerSetParticipant *participant = [HCRSurveyAnswerSetParticipant new];
    
    NSInteger targetID = answerSet.participants.count;
    
    participant.participantID = @(targetID);
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

@end
