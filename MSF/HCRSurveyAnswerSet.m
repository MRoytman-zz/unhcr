//
//  HCRSurveyResponse.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyAnswerSet.h"
#import "HCRDataManager.h"

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

#pragma mark - Public Methods

- (HCRSurveyAnswerSetParticipant *)participantWithID:(NSInteger)participantID {
    
    if (participantID > self.participants.count - 1 ||
        participantID < 0) {
        return nil;
    }
    
    return [self.participants objectAtIndex:participantID ofClass:@"HCRSurveyAnswerSetParticipant"];
    
}

- (HCRSurveyAnswerSetParticipant *)newParticipant {
    
    return [HCRSurveyAnswerSetParticipant newParticipantForAnswerSet:self];
    
}

@end
