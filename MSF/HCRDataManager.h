//
//  HCRDataManager.h
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCRDataManager : NSObject

+ (id)sharedManager;

- (NSArray *)surveyQuestionsArray;
- (NSArray *)surveyAnswerSetsArray;
- (NSDate *)surveyLastUpdated;

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;

- (NSDictionary *)createNewSurveyAnswerSet;
- (void)removeAnswerSetWithID:(NSString *)answerSetID;

- (NSDictionary *)getAnswerSetWithID:(NSString *)answerSetID;
- (NSString *)getIDForAnswerSet:(NSDictionary *)answerSet;
- (NSDate *)getCreatedDateForAnswerSet:(NSDictionary *)answerSet;
- (NSArray *)getParticipantsForAnswerSet:(NSDictionary *)answerSet;
- (NSDictionary *)getParticipantDataForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;
- (NSInteger)getPercentCompleteForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;

@end
