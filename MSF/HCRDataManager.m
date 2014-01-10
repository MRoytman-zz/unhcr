//
//  HCRDataManager.m
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataManager.h"

#import <Parse/Parse.h>

////////////////////////////////////////////////////////////////////////////////

// NSUD KEYS
NSString *const HCRPrefKeySurvey = @"HCRPrefKeySurvey";

NSString *const HCRPrefKeyQuestions = @"HCRPrefKeyQuestions";
NSString *const HCRPrefKeyQuestionsAnswers = @"answers";
NSString *const HCRPrefKeyQuestionsAnswersCode = @"code";
NSString *const HCRPrefKeyQuestionsAnswersString = @"string";
NSString *const HCRPrefKeyQuestionsAnswersFreeform = @"freeform";
NSString *const HCRPrefKeyQuestionsUpdated = @"updated";
NSString *const HCRPrefKeyQuestionsQuestion = @"question";
NSString *const HCRPrefKeyQuestionsQuestionCode = @"questionId";
NSString *const HCRPrefKeyQuestionsConditions = @"conditions";
NSString *const HCRPrefKeyQuestionsConditionsParticipantID = @"participantID";
NSString *const HCRPrefKeyQuestionsConditionsResponse = @"response";
NSString *const HCRPrefKeyQuestionsConditionsResponseQuestion = @"question";
NSString *const HCRPrefKeyQuestionsConditionsResponseAnswer = @"answer";
NSString *const HCRPrefKeyQuestionsConditionsMinParticipants = @"minParticipants";
NSString *const HCRPrefKeyQuestionsDefaultAnswer = @"defaultAnswer";
NSString *const HCRPrefKeyQuestionsSkip = @"skip";
NSString *const HCRPrefKeyQuestionsRequiredAnswers = @"answersRequired";
NSString *const HCRPrefKeyQuestionsFreeformLabel = @"freeformLabel";
NSString *const HCRPrefKeyQuestionsKeyboard = @"keyboard";
NSString *const HCRPrefKeyQuestionsNote = @"note";

NSString *const HCRPrefKeyAnswerSets = @"HCRPrefKeyAnswerSets";
NSString *const HCRPrefKeyAnswerSetsLocalID = @"HCRPrefKeyAnswerSetsLocalID";
NSString *const HCRPrefKeyAnswerSetsUser = @"userId";
NSString *const HCRPrefKeyAnswerSetsHouseholdID = @"householdId";
NSString *const HCRPrefKeyAnswerSetsTeamID = @"teamId";
NSString *const HCRPrefKeyAnswerSetsDuration = @"duration";
NSString *const HCRPrefKeyAnswerSetsConsent = @"consent";
NSString *const HCRPrefKeyAnswerSetsParticipants = @"HCRPrefKeyAnswerSetsParticipants";
NSString *const HCRPrefKeyAnswerSetsParticipantsID = @"participantId";
NSString *const HCRPrefKeyAnswerSetsParticipantsAge = @"participantAge";
NSString *const HCRPrefKeyAnswerSetsParticipantsGender = @"participantGender";
NSString *const HCRPrefKeyAnswerSetsParticipantsResponses = @"HCRPrefKeyAnswerSetsParticipantsResponses";
NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesQuestion = @"HCRPrefKeyAnswerSetsParticipantsResponsesQuestion";
NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesAnswer = @"HCRPrefKeyAnswerSetsParticipantsResponsesAnswer";
NSString *const HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString = @"HCRPrefKeyAnswerSetsParticipantsResponsesAnswerString";

NSString *const HCRPrefKeyAnswerSetsDurationStart = @"HCRPrefKeyAnswerSetsDurationStart";
NSString *const HCRPrefKeyAnswerSetsDurationEnd = @"HCRPrefKeyAnswerSetsDurationEnd";

// PARSE CLASSES
#ifdef DEBUG
NSString *const kSurveyResultClass = @"Test";
#else
#ifdef PRODUCTION
NSString *const kSurveyResultClass = @"SurveyResult";
#else
NSString *const kSurveyResultClass = @"TestFlight";
#endif
#endif

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager ()

@property (nonatomic, strong) HCRSurvey *localSurvey;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataManager

//- (void)exampleAnswerSet {
//
//    @{HCRPrefKeyAnswerSets: @[
//              @{
//                  HCRPrefKeyAnswerSetsLocalID: @"hash",
//                  HCRPrefKeyAnswerSetsUser: @"local user's ID",
//                  HCRPrefKeyAnswerSetsTeamID: @"team id",
//                  HCRPrefKeyAnswerSetsHouseholdID: @"tally number for survey ID", // server issued at completion
//                  HCRPrefKeyAnswerSetsDuration: @"combination of start and end", // set at completion
//                  HCRPrefKeyAnswerSetsDurationStart: @"marked when survey is created", // local only
//                  HCRPrefKeyAnswerSetsDurationEnd: @"marked when survey is completed", // local only, set at completion
//                  HCRPrefKeyAnswerSetsConsent: @"boolean whether consent was given",
//                  HCRPrefKeyAnswerSetsParticipants: @[
//                          @{HCRPrefKeyAnswerSetsParticipantsAge: @"some number",
//                            HCRPrefKeyAnswerSetsParticipantsGender: @"coded response",
//                            HCRPrefKeyAnswerSetsParticipantsID: @"just a tallied number, 1 - n",
//                            HCRPrefKeyAnswerSetsParticipantsResponses: @[
//                                    @{HCRPrefKeyAnswerSetsParticipantsResponsesQuestion: @"question code",
//                                      HCRPrefKeyAnswerSetsParticipantsResponsesAnswer: @"answer code",
//                                    @{HCRPrefKeyAnswerSetsParticipantsResponsesQuestion: @"question 2",
//                                      HCRPrefKeyAnswerSetsParticipantsResponsesAnswer: @"answer 2",
//                                    @{@"etc": @"array of all questions"}
//                                    ]
//                            },
//                          @{@"etc": @"next person - may be many"}
//                          ]
//                  },
//              @{@"etc": @"next survey answer set"},
//              ]
//      };
//};

#pragma mark - Life Cycle

+ (id)sharedManager {
    
    // TODO: make threadsafe
    static HCRDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HCRDataManager alloc] init];
    });
	return manager;
}

- (id)init {
    self = [super init];
    if ( self != nil )
    {
        self.localSurvey = [self _restoreLocalSurveyFromDataStore];
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setLocalSurvey:(HCRSurvey *)localSurvey {
    _localSurvey = localSurvey;
    [self _sync];
}

#pragma mark - Public Methods

- (NSArray *)localQuestionsArray {
    
    return self.localSurvey.questions;
    
}

- (HCRSurveyQuestion *)surveyQuestionWithQuestionID:(NSString *)questionID {
    return [self.localSurvey.questionDictionary objectForKey:questionID ofClass:@"HCRSurveyQuestion" mustExist:NO];
}

- (NSArray *)localAnswerSetsArray {
    
    return self.localSurvey.answerSets;
    
}

- (HCRSurveyAnswerSet *)surveyAnswerSetWithLocalID:(NSString *)localID {
    return [self.localSurvey.answerSetDictionary objectForKey:localID ofClass:@"HCRSurveyAnswerSet" mustExist:NO];
}

- (NSDate *)surveyQuestionsLastUpdated {
    
    // TODO: make more efficient; don't always check whole array (somehow determine 'dirty' status)
    // is this faster than sorting the array and snagging index:0?
    
    NSDate *date; // set date to non-nil inside loop so it returns nil if no survey list
    
    for (HCRSurveyQuestion *question in self.localSurvey.questions) {
        
        if (!date) {
            date = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        date = [date laterDate:question.updatedAt];
    }
    
    return date;
    
}

#pragma mark - Public Methods (Question Management)

// TODO: (remote) get list of possible surveys to work with

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock {
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse withCompletion:nil];
        } else {
            
            HCRDebug(@"Questions found: %d",objects.count);
            
            NSMutableDictionary *newDictionary = @{}.mutableCopy;
            
            for (PFObject *object in objects) {
                
                HCRSurveyQuestion *question = [HCRSurveyQuestion newQuestionWithDictionary:[self _dictionaryFromPFObject:object]];
                
                [newDictionary setObject:question forKey:question.questionCode];
                
            }
            
            self.localSurvey.questionDictionary = newDictionary;
            
        }
        
        completionBlock(error);
        
    }];
    
}

- (void)refreshSurveyResponsesForAllParticipantsWithAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    for (HCRSurveyAnswerSetParticipant *participant in answerSet.participants) {
        
        NSInteger participantID = participant.participantID.integerValue;
        
        [self refreshSurveyResponsesForParticipantID:participantID withAnswerSet:answerSet];
        
    }
    
}

- (void)refreshSurveyResponsesForParticipantID:(NSInteger)participantID withAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    NSArray *questionArray = [NSArray arrayWithArray:self.localSurvey.questions]; // may get manipulated inline
    
    for (HCRSurveyQuestion *question in questionArray) {
        
        if (question.skip.boolValue) {
            
            HCRDebug(@"Skipping question %@",question.questionCode);
            
        } else if (question.conditions) {
            
            // make sure they pass ALL tests!
            BOOL conditionPasses = YES;
            for (HCRSurveyQuestionCondition *condition in question.conditions) {
                
                conditionPasses = [self _passCondition:condition forAnswerSet:answerSet forParticipantID:participantID];
                
                if (conditionPasses == NO) {
                    HCRDebug(@"Condition failed for question %@",question.questionCode);
                    break;
                }
                
            }
            
            if (conditionPasses) {
                [self setAnswerCode:nil withFreeformString:nil forQuestion:question.questionCode withAnswerSetID:answerSet.localID withParticipantID:participantID];
            }
            
        } else {
            HCRDebug(@"No conditions found! Adding question: %@",question);
            [self setAnswerCode:nil withFreeformString:nil forQuestion:question.questionCode withAnswerSetID:answerSet.localID withParticipantID:participantID];
        }
        
    }
    
}

#pragma mark - Public Methods (Answer Management)

- (void)createNewSurveyAnswerSet {
    
    // create new survey
    // store initial vars necessary
    // add to list of local surveys in-process
    
    if (self.localSurvey.answerSetDictionary == nil) {
        self.localSurvey.answerSetDictionary = @{}.mutableCopy;
    }
    
    HCRSurveyAnswerSet *surveyAnswerSet = [HCRSurveyAnswerSet new];
    
    surveyAnswerSet.localID = [NSString stringWithNewUUID];
    surveyAnswerSet.teamID = [[HCRUser currentUser] teamID];
    surveyAnswerSet.userID = [[HCRUser currentUser] objectId];
    surveyAnswerSet.durationStart = [NSDate date];
    
    surveyAnswerSet.participants = @[[HCRSurveyAnswerSetParticipant newParticipantForAnswerSet:surveyAnswerSet]].mutableCopy;
    
    [self.localSurvey.answerSetDictionary setObject:surveyAnswerSet forKey:surveyAnswerSet.localID];
    [self _sync];
    
}

- (void)removeAnswerSetWithID:(NSString *)answerSetID {
    
    [self.localSurvey.answerSetDictionary removeObjectForKey:answerSetID];
    
    if (self.localSurvey.answerSetDictionary.allKeys.count == 0) {
        self.localSurvey.answerSetDictionary = nil;
    }
    
    [self _sync];
    
}

- (void)setAnswerCode:(NSNumber *)answerCode withFreeformString:(NSString *)answerString forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    [self _setAnswer:answerCode
          withString:answerString
         forQuestion:questionCode
     withAnswerSetID:answerSetID
   withParticipantID:participantID
            forceSet:NO];
    
}

- (void)removeAnswerForQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    [self _setAnswer:nil
          withString:nil
         forQuestion:questionCode
     withAnswerSetID:answerSetID
   withParticipantID:participantID
            forceSet:YES];
    
}

#pragma mark - Public Methods

- (NSInteger)percentCompleteForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    // TODO: handle this better - overall questions?
    
    HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:0];
    NSArray *currentQuestions = participant.questions;
    
    NSInteger completedResponses = 0;
    
    for (HCRSurveyAnswerSetParticipantQuestion *question in currentQuestions) {
        if (question.answer || question.answerString) {
            completedResponses++;
        }
    }
    
    return (currentQuestions.count > 0) ? 100 * completedResponses / currentQuestions.count : 0;
    
}

#pragma mark - Private Methods

- (HCRSurvey *)_restoreLocalSurveyFromDataStore {
    
    NSParameterAssert(!self.localSurvey);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:HCRPrefKeySurvey];
    HCRSurvey *survey = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    
    if (!survey) {
        survey = [HCRSurvey new];
    }
    
    return survey;
    
}

- (void)_sync {
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.localSurvey];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:HCRPrefKeySurvey];
    [defaults synchronize];
    
}

- (NSDictionary *)_dictionaryFromPFObject:(PFObject *)object {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    for (NSString *key in [object allKeys]) {
        [dictionary setObject:object[key]
                       forKey:key];
    }
    
    [dictionary setObject:[object updatedAt]
                   forKey:HCRPrefKeyQuestionsUpdated];
    
    return dictionary;
    
}

- (PFObject *)_objectForDictionary:(NSDictionary *)dictionary withClassName:(NSString *)className {
    
    PFObject *object = [PFObject objectWithClassName:className];
    
    for (NSString *key in [dictionary allKeys]) {
        [object setObject:object[key]
                   forKey:key];
    }
    
    return object;
    
}

- (BOOL)_passCondition:(HCRSurveyQuestionCondition *)condition forAnswerSet:(HCRSurveyAnswerSet *)answerSet forParticipantID:(NSInteger)participantID {
    
    if (condition.participantID) {
        
        NSInteger conditionalID = condition.participantID.integerValue;
        
        if (participantID != conditionalID) {
            return NO;
        }
        
    } else if (condition.response) {
        
        HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:participantID];
        HCRSurveyAnswerSetParticipantQuestion *question = [participant questionWithID:condition.response.question];
        NSNumber *answer = question.answer;
        
        if (condition.response.answer != answer) {
            return NO;
        }
        
    } else if (condition.minimumParticipants) {
        
        if (answerSet.participants.count < condition.minimumParticipants.integerValue) {
            return NO;
        }
    
    } else {
        HCRError(@"Unhandled survey question condition: %@",condition);
        NSParameterAssert(NO);
        return NO;
    }
    
    return YES;
    
}

- (void)_setAnswer:(NSNumber *)answerCode withString:(NSString *)answerString forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID forceSet:(BOOL)forceSet {
    
    NSParameterAssert(questionCode);
    
    // must exist
    HCRSurveyAnswerSet *targetAnswerSet = [self.localSurvey.answerSetDictionary objectForKey:answerSetID ofClass:@"HCRSurveyAnswerSet"];
    NSParameterAssert(targetAnswerSet);
    
    // drill down to this particular response
    HCRSurveyAnswerSetParticipant *targetParticipant = [targetAnswerSet participantWithID:participantID];
    HCRSurveyAnswerSetParticipantQuestion *questionData = [targetParticipant questionWithID:questionCode];
    
    if (!questionData) {
        HCRSurveyAnswerSetParticipantQuestion *newQuestion = [HCRSurveyAnswerSetParticipantQuestion new];
        [targetParticipant.questions addObject:newQuestion];
        questionData = newQuestion;
    }
    
    questionData.question = questionCode;
    
    // set default answer & string
    if (answerCode || forceSet) {
        questionData.answer = answerCode;
        questionData.answerString = [[self surveyQuestionWithQuestionID:questionCode] answerForAnswerCode:answerCode].string;
    }
    
    // if 'freeform' string is given, overwrite input answerString
    if (answerString || forceSet) {
        questionData.answerString = answerString;
    }
    
    [self _sync];
    
}

@end
