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

// question management
- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;
- (void)refreshSurveyResponsesForAllParticipantsWithAnswerSet:(NSDictionary *)answerSet;
- (void)refreshSurveyResponsesForParticipantID:(NSInteger)participantID withAnswerSet:(NSDictionary *)answerSet;
- (NSDictionary *)getSurveyQuestionDataForQuestionCode:(NSString *)questionCode;
- (NSString *)getSurveyQuestionForResponseData:(NSDictionary *)responseData;
- (NSArray *)getSurveyAnswersForResponseData:(NSDictionary *)responseData;

// answer set management
- (void)createNewSurveyAnswerSet;
- (void)removeAnswerSetWithID:(NSString *)answerSetID;
- (void)setAnswer:(NSString *)answerCode forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID;

// general
- (NSDictionary *)getAnswerSetWithID:(NSString *)answerSetID;
- (NSString *)getIDForAnswerSet:(NSDictionary *)answerSet;
- (NSDate *)getCreatedDateForAnswerSet:(NSDictionary *)answerSet;

// participants
- (NSArray *)getParticipantsForAnswerSet:(NSDictionary *)answerSet;
- (NSDictionary *)getParticipantDataForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;

// responses
- (NSArray *)getResponsesForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;
- (NSDictionary *)getResponseDataFromParticipantResponses:(NSArray *)responses withQuestionCode:(NSString *)questionCode;
- (NSNumber *)getAnswerFromAnswerSet:(NSDictionary *)answerSet forParticipantID:(NSInteger)participantID forQuestionCode:(NSString *)questionCode;

// convenience
- (NSInteger)getPercentCompleteForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;

@end
