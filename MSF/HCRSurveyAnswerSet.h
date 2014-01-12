//
//  HCRSurveyResponse.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@class HCRSurveyAnswerSetParticipant;

@interface HCRSurveyAnswerSet : HCRArchivalObject

@property (nonatomic, strong) NSString *localID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *householdID;
@property (nonatomic, strong) NSString *teamID;
@property (nonatomic, strong) NSNumber *consent;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSDate *durationStart;
@property (nonatomic, strong) NSDate *durationEnd;
@property (nonatomic, strong) NSMutableArray *participants;

+ (HCRSurveyAnswerSet *)newAnswerSet;

- (HCRSurveyAnswerSetParticipant *)participantWithID:(NSInteger)participantID;
- (HCRSurveyAnswerSetParticipant *)newParticipant;

@end
