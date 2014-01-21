//
//  HCRSurveyResponse.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerSet.h"

@implementation HCRSurveyAnswerSet

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.localID = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsLocalID];
        self.userID = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsUser];
        self.householdID = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsHouseholdID];
        self.teamID = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsTeamID];
        self.consent = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsConsent];
        self.duration = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsDuration];
        self.durationStart = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsDurationStart];
        self.durationEnd = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsDurationEnd];
        self.participants = [decoder decodeObjectForKey:HCRPrefKeyAnswerSetsParticipants];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.localID forKey:HCRPrefKeyAnswerSetsLocalID];
    [encoder encodeObject:self.userID forKey:HCRPrefKeyAnswerSetsUser];
    [encoder encodeObject:self.householdID forKey:HCRPrefKeyAnswerSetsHouseholdID];
    [encoder encodeObject:self.teamID forKey:HCRPrefKeyAnswerSetsTeamID];
    [encoder encodeObject:self.consent forKey:HCRPrefKeyAnswerSetsConsent];
    [encoder encodeObject:self.duration forKey:HCRPrefKeyAnswerSetsDuration];
    [encoder encodeObject:self.durationStart forKey:HCRPrefKeyAnswerSetsDurationStart];
    [encoder encodeObject:self.durationEnd forKey:HCRPrefKeyAnswerSetsDurationEnd];
    [encoder encodeObject:self.participants forKey:HCRPrefKeyAnswerSetsParticipants];
}

#pragma mark - Class Methods

+ (HCRSurveyAnswerSet *)newAnswerSet {
    
    HCRSurveyAnswerSet *answerSet = [HCRSurveyAnswerSet new];
    
    answerSet.localID = [NSString stringWithNewUUID];
    answerSet.teamID = [[HCRUser currentUser] teamID];
    answerSet.userID = [[HCRUser currentUser] objectId];
    answerSet.durationStart = [NSDate date];
    
    answerSet.participants = @[[HCRSurveyAnswerSetParticipant newParticipantForAnswerSet:answerSet]].mutableCopy;
    
    return answerSet;
    
}

#pragma mark - Public Methods

- (HCRSurveyAnswerSetParticipant *)participantWithID:(NSInteger)participantID {
    
    for (HCRSurveyAnswerSetParticipant *participant in self.participants) {
        if (participant.participantID.integerValue == participantID) {
            return participant;
        }
    }
    
    return nil;
    
}

- (HCRSurveyAnswerSetParticipant *)newParticipant {
    
    return [HCRSurveyAnswerSetParticipant newParticipantForAnswerSet:self];
    
}

- (NSComparisonResult)compareStartedDateToAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    return [self.durationStart compare:answerSet.durationStart];
    
}

@end
