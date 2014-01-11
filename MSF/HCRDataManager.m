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
NSString *const HCRPrefKeyQuestionsConditionsOrArray = @"orArray";
NSString *const HCRPrefKeyQuestionsConditionsParticipantID = @"participantID";
NSString *const HCRPrefKeyQuestionsConditionsMinParticipants = @"minParticipants";
NSString *const HCRPrefKeyQuestionsConditionsMinAge = @"minAge";
NSString *const HCRPrefKeyQuestionsConditionsMaxAge = @"maxAge";
NSString *const HCRPrefKeyQuestionsConditionsGender = @"gender";
NSString *const HCRPrefKeyQuestionsConditionsResponse = @"response";
NSString *const HCRPrefKeyQuestionsConditionsResponseQuestion = @"question";
NSString *const HCRPrefKeyQuestionsConditionsResponseAnswer = @"answer";
NSString *const HCRPrefKeyQuestionsConditionsResponseAnswerArray = @"answers";
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
NSString *const kSurveyResultClass = @"Result";
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

#pragma mark - Public Methods (Participant Management)

- (HCRSurveyAnswerSetParticipant *)createNewParticipantForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    HCRSurveyAnswerSetParticipant *newParticipant = [answerSet newParticipant];
    [answerSet.participants addObject:newParticipant];
    
    [self.localSurvey.answerSetDictionary setObject:answerSet forKey:answerSet.localID];
    [self _sync];
    
    return newParticipant;
    
}

- (void)removeParticipant:(HCRSurveyAnswerSetParticipant *)participant fromAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    [answerSet.participants removeObject:participant];
    
    [self.localSurvey.answerSetDictionary setObject:answerSet forKey:answerSet.localID];
    [self _sync];
    
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
            
            [self _sync];
            
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
    
    NSDate *start = [NSDate date];
    
    HCRSurveyAnswerSetParticipant *targetParticpant = [answerSet participantWithID:participantID];
    
    for (HCRSurveyQuestion *question in self.localSurvey.questions) {
        
        if (question.skip.boolValue) {
            // do nothing
        } else if (question.conditions) {
            
            // make sure they pass ALL tests!
            BOOL conditionPasses = YES;
            for (HCRSurveyQuestionCondition *condition in question.conditions) {
                
                // if $or array exists, make sure they pass ONE test
                // (but continue the loop; there may be non-$or conditions to test
                conditionPasses = [self _passCondition:condition forAnswerSet:answerSet forParticipantID:participantID];
                
                if (conditionPasses == NO) {
                    break;
                }
                
            }
            
            if (conditionPasses) {
                
                [self _setAnswer:nil
                      withString:nil
                     forQuestion:question.questionCode
                 forParticipant:targetParticpant
                        forceSet:NO
                            sort:NO
                            sync:NO];
                
            } else {
                [self _removeQuestionWithCode:question.questionCode
                              withParticipant:targetParticpant
                                         sync:NO];
            }
            
        } else {
            HCRError(@"No conditions found!");
            NSAssert(NO, @"All questions must have conditions; even if just an empty array in database.");
        }
        
    }
    
    [self _sortQuestionsForParticipant:[answerSet participantWithID:participantID]
                                  sync:YES];
    
    HCRDebug(@"refresh time: %.2f",-1 * start.timeIntervalSinceNow);
    
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
    
    HCRSurveyAnswerSet *targetAnswerSet = [self.localSurvey.answerSetDictionary objectForKey:answerSetID ofClass:@"HCRSurveyAnswerSet"];
    NSParameterAssert(targetAnswerSet);
    
    // drill down to this particular response
    HCRSurveyAnswerSetParticipant *targetParticipant = [targetAnswerSet participantWithID:participantID];
    
    [self _setAnswer:answerCode
          withString:answerString
         forQuestion:questionCode
      forParticipant:targetParticipant
            forceSet:NO
                sort:YES
                sync:YES];
    
}

- (void)removeAnswerForQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    HCRSurveyAnswerSet *targetAnswerSet = [self.localSurvey.answerSetDictionary objectForKey:answerSetID ofClass:@"HCRSurveyAnswerSet"];
    NSParameterAssert(targetAnswerSet);
    
    // drill down to this particular response
    HCRSurveyAnswerSetParticipant *targetParticipant = [targetAnswerSet participantWithID:participantID];
    
    [self _setAnswer:nil
          withString:nil
         forQuestion:questionCode
      forParticipant:targetParticipant
            forceSet:YES
                sort:YES
                sync:YES];
    
}

- (void)removeQuestionWithCode:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    HCRSurveyAnswerSetParticipant *participant = [[self surveyAnswerSetWithLocalID:answerSetID] participantWithID:participantID];
    
    [self _removeQuestionWithCode:questionCode withParticipant:participant sync:YES];
    
}

#pragma mark - Public Methods

- (void)save {
    [self _sync];
}

- (NSInteger)percentCompleteForAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    NSInteger totalQuestions = 0;
    NSInteger completedResponses = 0;
    
    for (HCRSurveyAnswerSetParticipant *participant in answerSet.participants) {
        
        NSArray *currentQuestions = participant.questions;
        
        for (HCRSurveyAnswerSetParticipantQuestion *question in currentQuestions) {
            
            totalQuestions++;
            
            if (question.answer || question.answerString) {
                completedResponses++;
            }
        }
        
    }
    
    return (totalQuestions > 0) ? 100 * completedResponses / totalQuestions : 0;
    
}

- (NSInteger)percentCompleteForParticipantID:(NSInteger)participantID withAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    NSInteger totalQuestions = 0;
    NSInteger completedResponses = 0;
    
    NSArray *currentQuestions = [answerSet participantWithID:participantID].questions;
    
    for (HCRSurveyAnswerSetParticipantQuestion *question in currentQuestions) {
        
        totalQuestions++;
        
        if (question.answer || question.answerString) {
            completedResponses++;
        }
    }
    
    return (totalQuestions > 0) ? 100 * completedResponses / totalQuestions : 0;
    
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
    
    if (condition.orArray) {
        
        BOOL anyPass = NO;
        for (HCRSurveyQuestionCondition *innerCondition in condition.orArray) {
            
            anyPass = [self _passCondition:innerCondition forAnswerSet:answerSet forParticipantID:participantID];
            
            if (anyPass) {
                break;
            }
            
        }
        
        // if NONE pass, break it
        if (!anyPass) {
            return NO;
        }
        
    } else if (condition.participantID) {
        
        NSInteger conditionalID = condition.participantID.integerValue;
        
        if (participantID != conditionalID) {
            return NO;
        }
        
    } else if (condition.response) {
        
        HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:participantID];
        HCRSurveyAnswerSetParticipantQuestion *question = [participant questionWithID:condition.response.question];
        NSNumber *answer = question.answer;
        NSString *answerString = question.answerString;
        
        if (!answer && !answerString) {
            return NO;
        }
        
        // TODO: on server migrate everything to array and only accept one answer.. maybe..
        
        // fails if answer does not match answer
        id conditionalAnswer = condition.response.answer;
        if (conditionalAnswer &&
            ![answer isEqualToNumber:(NSNumber *)conditionalAnswer] &&
            ![answerString isEqualToString:(NSString *)conditionalAnswer]) {
            
            return NO;
        }
        
        // fails if NONE of the answers match answer
        NSArray *conditionalAnswers = condition.response.answerArray;
        if (conditionalAnswers) {
            
            BOOL matches = NO;
            
            for (id conditionalAnswer in conditionalAnswers) {
                
                if ([answer isEqualToNumber:(NSNumber *)conditionalAnswer] ||
                    [answerString isEqualToString:(NSString *)[NSString stringWithFormat:@"%@",conditionalAnswer]]) {
                    matches = YES;
                    break;
                }
            }
            
            if (!matches) {
                return NO;
            }
        }
        
        
        
    } else if (condition.minimumParticipants) {
        
        if (answerSet.participants.count < condition.minimumParticipants.integerValue) {
            return NO;
        }
    
    } else if (condition.minimumAge) {
        
        HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:participantID];
        
        if (!participant.age ||
            participant.age.integerValue < condition.minimumAge.integerValue) {
            return NO;
        }
        
    } else if (condition.maximumAge) {
        
        HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:participantID];
        
        if (!participant.age ||
            participant.age.integerValue > condition.maximumAge.integerValue) {
            return NO;
        }
        
    } else if (condition.gender) {
        
        HCRSurveyAnswerSetParticipant *participant = [answerSet participantWithID:participantID];
        
        if (!participant.gender ||
            ![participant.gender isEqualToNumber:condition.gender]) {
            return NO;
        }
        
    } else {
        HCRError(@"Unhandled survey question condition: %@",condition);
        NSParameterAssert(NO);
        return NO;
    }
    
    return YES;
    
}

- (void)_setAnswer:(NSNumber *)answerCode withString:(NSString *)answerString forQuestion:(NSString *)questionCode forParticipant:(HCRSurveyAnswerSetParticipant *)targetParticipant forceSet:(BOOL)forceSet sort:(BOOL)sort sync:(BOOL)sync {
    
    NSParameterAssert(questionCode);
    
    // must exist
    
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
    
    // set age and gender
    // TODO: get this dynamic from the server somehow
    if ([questionCode isEqualToString:@"6"]) {
        targetParticipant.age = (questionData.answerString) ? @(questionData.answerString.integerValue) : nil;
    } else if ([questionCode isEqualToString:@"7"]) {
        targetParticipant.gender = questionData.answer;
    }
    
    if (sort) {
        [self _sortQuestionsForParticipant:targetParticipant sync:NO];
    }
    
    if (sync) {
        [self _sync];
    }
    
}

- (void)_removeQuestionWithCode:(NSString *)questionCode withParticipant:(HCRSurveyAnswerSetParticipant *)participant sync:(BOOL)sync {
    
    HCRSurveyAnswerSetParticipantQuestion *question = [participant questionWithID:questionCode];
    
    [participant.questions removeObject:question];
    
    if (sync) {
        [self _sync];
    }
    
}

- (void)_sortQuestionsForParticipant:(HCRSurveyAnswerSetParticipant *)targetParticipant sync:(BOOL)sync {
    
    [targetParticipant.questions sortUsingSelector:@selector(compareToParticipantQuestion:)];
    
    if (sync) {
        [self _sync];
    }
    
}

@end
