//
//  HCRDataManager.h
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HCRUser.h"
#import "HCRSurvey.h"
#import "HCRSurveyQuestion.h"
#import "HCRSurveyQuestionAnswer.h"
#import "HCRSurveyQuestionCondition.h"
#import "HCRSurveyAnswerSet.h"
#import "HCRSurveyAnswerSetParticipant.h"
#import "HCRSurveyAnswerSetParticipantQuestion.h"

////////////////////////////////////////////////////////////////////////////////

// NSUD KEYS
extern NSString *const HCRPrefKeyQuestions;
extern NSString *const HCRPrefKeyQuestionsAnswers;
extern NSString *const HCRPrefKeyQuestionsAnswersCode;
extern NSString *const HCRPrefKeyQuestionsAnswersString;
extern NSString *const HCRPrefKeyQuestionsAnswersFreeform;
extern NSString *const HCRPrefKeyQuestionsUpdated;
extern NSString *const HCRPrefKeyQuestionsQuestion;
extern NSString *const HCRPrefKeyQuestionsQuestionCode;
extern NSString *const HCRPrefKeyQuestionsConditions;
extern NSString *const HCRPrefKeyQuestionsConditionsParticipantID;
extern NSString *const HCRPrefKeyQuestionsConditionsResponse;
extern NSString *const HCRPrefKeyQuestionsConditionsResponseQuestion;
extern NSString *const HCRPrefKeyQuestionsConditionsResponseAnswer;
extern NSString *const HCRPrefKeyQuestionsConditionsMinParticipants;
extern NSString *const HCRPrefKeyQuestionsDefaultAnswer;
extern NSString *const HCRPrefKeyQuestionsSkip;
extern NSString *const HCRPrefKeyQuestionsRequiredAnswers;
extern NSString *const HCRPrefKeyQuestionsFreeformLabel;
extern NSString *const HCRPrefKeyQuestionsKeyboard;
extern NSString *const HCRPrefKeyQuestionsNote;

extern NSString *const HCRPrefKeyAnswerSets;
extern NSString *const HCRPrefKeyAnswerSetsLocalID;
extern NSString *const HCRPrefKeyAnswerSetsUser;
extern NSString *const HCRPrefKeyAnswerSetsHouseholdID;
extern NSString *const HCRPrefKeyAnswerSetsTeamID;
extern NSString *const HCRPrefKeyAnswerSetsDuration;
extern NSString *const HCRPrefKeyAnswerSetsConsent;
extern NSString *const HCRPrefKeyAnswerSetsParticipants;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsID;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsAge;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsGender;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsResponses;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesQuestion;
extern NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesAnswer;

extern NSString *const HCRPrefKeyAnswerSetsDurationStart;
extern NSString *const HCRPrefKeyAnswerSetsDurationEnd;

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager : NSObject

+ (id)sharedManager;

- (NSArray *)localQuestionsArray;
- (NSArray *)localAnswerSetsArray;

- (HCRSurveyQuestion *)surveyQuestionWithQuestionID:(NSString *)questionID;
- (HCRSurveyAnswerSet *)surveyAnswerSetWithLocalID:(NSString *)localID;

// question management
- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;
//- (NSDictionary *)getSurveyQuestionDataForQuestionCode:(NSString *)questionCode;
//- (NSString *)getSurveyQuestionCodeForParticipantResponseData:(NSDictionary *)responseData;
//- (NSArray *)getSurveyAnswerDataArrayForSurveyQuestionCode:(NSString *)questionCode;
//- (NSArray *)getSurveyAnswerStringsForSurveyQuestionCode:(NSString *)questionCode;
//- (BOOL)getSurveyAnswerFreeformStatusFromSurveyAnswerData:(NSDictionary *)answerData;
//- (NSNumber *)getSurveyAnswerDefaultAnswerFromSurveyAnswerData:(NSDictionary *)answerData;

// answer set management
- (void)createNewSurveyAnswerSet;
- (void)removeAnswerSetWithID:(NSString *)answerSetID;
- (void)refreshSurveyResponsesForAllParticipantsWithAnswerSet:(HCRSurveyAnswerSet *)answerSet;
- (void)refreshSurveyResponsesForParticipantID:(NSInteger)participantID withAnswerSet:(HCRSurveyAnswerSet *)answerSet;
- (void)setAnswer:(NSNumber *)answerCode forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID;

//// general
//- (NSDictionary *)getAnswerSetWithID:(NSString *)answerSetID;
//- (NSString *)getIDForAnswerSet:(NSDictionary *)answerSet;
//- (NSDate *)getCreatedDateForAnswerSet:(NSDictionary *)answerSet;
//
//// participants
//- (NSArray *)getParticipantsForAnswerSet:(NSDictionary *)answerSet;
//- (NSDictionary *)getParticipantDataForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID;
//
//// responses
//- (NSArray *)getQuestionsForParticipantID:(NSInteger)participantID withAnswerSet:(NSDictionary *)answerSet;
//- (NSArray *)getQuestionsAndAnswersForParticipantID:(NSInteger)participantID withAnswerSet:(NSDictionary *)answerSet;
//- (NSNumber *)getAnswerForParticipantID:(NSInteger)participantID forQuestionCode:(NSString *)questionCode withAnswerSet:(NSDictionary *)answerSet;
//- (NSDictionary *)getQuestionAndAnswerDictionaryForParticipantID:(NSInteger)participantID withQuestionCode:(NSString *)questionCode withAnswerSet:(NSDictionary *)answerSet;
//
// convenience
- (NSDate *)surveyQuestionsLastUpdated;
- (NSInteger)percentCompleteForAnswerSet:(HCRSurveyAnswerSet *)answerSet;

@end
