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
extern NSString *const HCRPrefKeyQuestionsConditionsMinParticipants;
extern NSString *const HCRPrefKeyQuestionsConditionsMinAge;
extern NSString *const HCRPrefKeyQuestionsConditionsMaxAge;
extern NSString *const HCRPrefKeyQuestionsConditionsGender;
extern NSString *const HCRPrefKeyQuestionsConditionsResponse;
extern NSString *const HCRPrefKeyQuestionsConditionsResponseQuestion;
extern NSString *const HCRPrefKeyQuestionsConditionsResponseAnswer;
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
extern NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString;

extern NSString *const HCRPrefKeyAnswerSetsDurationStart;
extern NSString *const HCRPrefKeyAnswerSetsDurationEnd;

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager : NSObject

+ (id)sharedManager;

- (NSArray *)localQuestionsArray;
- (NSArray *)localAnswerSetsArray;

- (HCRSurveyQuestion *)surveyQuestionWithQuestionID:(NSString *)questionID;
- (HCRSurveyAnswerSet *)surveyAnswerSetWithLocalID:(NSString *)localID;

- (void)save;

// participants
- (HCRSurveyAnswerSetParticipant *)createNewParticipantForAnswerSet:(HCRSurveyAnswerSet *)answerSet;

// question management
- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;

// answer set management
- (void)createNewSurveyAnswerSet;
- (void)removeAnswerSetWithID:(NSString *)answerSetID;
- (void)refreshSurveyResponsesForAllParticipantsWithAnswerSet:(HCRSurveyAnswerSet *)answerSet;
- (void)refreshSurveyResponsesForParticipantID:(NSInteger)participantID withAnswerSet:(HCRSurveyAnswerSet *)answerSet;

// answer set answers
- (void)setAnswerCode:(NSNumber *)answerCode withFreeformString:(NSString *)answerString forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID;
- (void)removeAnswerForQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID;

// convenience
- (NSDate *)surveyQuestionsLastUpdated;
- (NSInteger)percentCompleteForAnswerSet:(HCRSurveyAnswerSet *)answerSet;

@end
