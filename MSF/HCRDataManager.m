//
//  HCRDataManager.m
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataManager.h"
#import "HCRSurveySubmission.h"

#import <Parse/Parse.h>

////////////////////////////////////////////////////////////////////////////////

// NSUD KEYS
NSString *const HCRPrefKeyAlerts = @"HCRPrefKeyAlerts";

NSString *const HCRPrefKeySurvey = @"HCRPrefKeySurvey";
NSString *const HCRPrefKeySurveyLocalID = @"objectId";
NSString *const HCRPrefKeySurveyTitle = @"description";
NSString *const HCRPrefKeySurveyAgeQuestion = @"ageQuestion";
NSString *const HCRPrefKeySurveyGenderQuestion = @"genderQuestion";
NSString *const HCRPrefKeySurveyParticipantsQuestion = @"participantsQuestion";

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
NSString *const HCRPrefKeyQuestionsConditionsConsent = @"consent";
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

// INCREMENTOR
#ifdef PRODUCTION
NSString *const kSurveyIDField = @"householdId";
#else
NSString *const kSurveyIDField = @"testId";
#endif

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager ()

@property (nonatomic, strong) NSMutableArray *localAlerts;
@property (nonatomic, readonly) NSArray *encodedAlerts;

@property (nonatomic, strong) HCRSurvey *localSurvey;
@property (nonatomic, strong) NSArray *localSurveys;

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
        self.localAlerts = [self _restoreLocalAlertsFromDataStore];
        self.localSurvey = [self _restoreLocalSurveyFromDataStore];
        self.localSurveys = @[self.localSurvey];
    }
    return self;
}

#pragma mark - Getters & Setters

- (NSString *)currentEnvironment {
    
    HCRUser *currentUser = [HCRUser currentUser];
    if (currentUser.testUser) {
        return HCREnvironmentDebug;
    }
    
#ifdef DEBUG
    return HCREnvironmentDebug;
#else
#ifdef PRODUCTION
    return HCREnvironmentProduction;
#else
    return HCREnvironmentTestFlight;
#endif
#endif
    
}

- (void)setLocalSurvey:(HCRSurvey *)localSurvey {
    _localSurvey = localSurvey;
    [self _sync];
}

- (NSArray *)encodedAlerts {
    NSMutableArray *alerts = @[].mutableCopy;
    
    for (HCRAlert *alert in self.localAlerts) {
        [alerts addObject:[NSKeyedArchiver archivedDataWithRootObject:alert]];
    }
    
    return [NSArray arrayWithArray:alerts];
}

#pragma mark - Public Methods

- (void)saveData {
    [self _sync];
}

#pragma mark - Public Methods (Alerts)

- (NSArray *)localAlertsArray {
    return self.localAlerts;
}

- (NSArray *)unreadAlerts {
    
    NSMutableArray *unreadAlerts = @[].mutableCopy;
    
    for (HCRAlert *alert in self.localAlerts) {
        if (!alert.read) {
            [unreadAlerts addObject:alert];
        }
    }
    
    return [NSArray arrayWithArray:unreadAlerts];
}

- (HCRAlert *)alertWithID:(NSString *)objectID {
    
    // TODO: build this
    NSParameterAssert(NO);
    return nil;
    
}

- (void)refreshAlertsWithCompletion:(void (^)(NSError *))completionBlock {
    
    PFQuery *questionsQuery = [HCRAlert query];
    
    [questionsQuery whereKey:@"environment" containsString:[[HCRDataManager sharedManager] currentEnvironment]];
    
    questionsQuery.limit = 1000;
    
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            HCRDebug(@"Alerts found: %d",objects.count);
            
            // check each object..
            // if something in the local array is no longer in the new list, kill it!
            // OR if duplicate, also delete it
            NSMutableArray *duplicateArray = @[].mutableCopy;
            NSArray *safeIterator = [NSArray arrayWithArray:self.localAlertsArray];
            for (HCRAlert *alert in safeIterator) {
                if ([duplicateArray containsObject:alert]) {
                    HCRDebug(@"Deleting duplicate Alert!");
                    [self.localAlerts removeObject:alert];
                } else if (![objects containsObject:alert]) {
                    HCRDebug(@"Deleting legacy Alert!");
                    [self.localAlerts removeObject:alert];
                } else {
                    [duplicateArray addObject:alert];
                }
            }
            
            // if it's not in the local array, add it
            for (PFObject *object in objects) {
                if (![self.localAlerts containsObject:object]) {
                    HCRDebug(@"Adding new Alert!");
                    HCRAlert *newAlert = [HCRAlert localAlertCopyFromPFObject:object];
                    [self.localAlerts addObject:newAlert];
                }
            }
            
            [self.localAlerts sortUsingSelector:@selector(compareUsingCreatedDate:)];
            
            [self _sync];
            
        }
        
        completionBlock(error);
        
    }];
    
}

- (void)markAllAlertsAsRead {
    
    for (HCRAlert *alert in self.localAlerts) {
        alert.read = YES;
    }
    
    [self _sync];
    
}

#pragma mark - Public Methods (Surveys)

- (NSArray *)localSurveysArray {
    return self.localSurveys;
}

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

- (void)submitAnswerSet:(HCRSurveyAnswerSet *)answerSet withCompletion:(void (^)(NSError *))completionBlock {
    
    // set and increment household ID (e.g. testId or householdId)
    // create new Parse object for proper class (e.g. Test or Result)
    // fill in answer set details in new parse object in CSV columns
    PFQuery *householdIDQuery = [PFQuery queryWithClassName:@"Survey"];
    
    householdIDQuery.limit = 1000;
    
    [householdIDQuery getObjectInBackgroundWithId:self.localSurvey.localID block:^(PFObject *object, NSError *error) {
        
        if (error) {
            completionBlock(error);
        } else {
            
            NSNumber *surveyID = object[kSurveyIDField];
            NSInteger participantCount = answerSet.participants.count;
            
            __block BOOL failed = NO;
            __block NSInteger completedCount = 0;
            
            BOOL consented = [answerSet.consent isEqualToNumber:@1];
            NSNumber *householdID = (consented) ? surveyID : @0;
            
            for (HCRSurveyAnswerSetParticipant *participant in answerSet.participants) {
                
                HCRSurveySubmission *surveySubmission = [HCRSurveySubmission new];
                surveySubmission.teamID = [HCRUser currentUser].teamID;
                surveySubmission.userID = [HCRUser currentUser].objectId;
                surveySubmission.consent = answerSet.consent;
                surveySubmission.householdID = householdID;
                surveySubmission.participantID = participant.participantID;
                surveySubmission.age = participant.age;
                surveySubmission.gender = participant.gender;
                surveySubmission.duration = answerSet.duration;
                
                // answer codes & strings
                NSMutableDictionary *codeDictionary = @{}.mutableCopy;
                NSMutableDictionary *stringDictionary = @{}.mutableCopy;
                
                for (HCRSurveyAnswerSetParticipantQuestion *question in participant.questions) {
                    
                    if (question.answer) {
                        codeDictionary[question.question] = question.answer;
                    }
                    
                    if (question.answerString) {
                        stringDictionary[question.question] = question.answerString;
                    }
                    
                }
                
                surveySubmission.answerCodes = codeDictionary;
                surveySubmission.answerStrings = stringDictionary;
                
                [surveySubmission saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    // check for last participant
                    completedCount++;
                    
                    if (!failed &&
                        completedCount != participantCount) {
                        // if not failed but not completed, do nothing, just wait for the next
                    } else if (!failed &&
                               (error || !succeeded)) {
                        
                        failed = YES;
                        completionBlock(error);
                        
                    } else if (!failed &&
                               completedCount == participantCount) {
                        
                        // if consent was given, increment
                        // TODO: get this value from server, i.e. dynamic
                        if (consented) {
                            // this is the final completed block, and all have succceeeded
                            answerSet.householdID = surveyID;
                            [self _sync];
                            
                            [object incrementKey:kSurveyIDField];
                            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                
                                completionBlock(error);
                                
                            }];
                        } else {
                            
                            // else don't increment
                            answerSet.householdID = householdID;
                            [self _sync];
                            
                            completionBlock(error);
                        }
                        
                    }
                    
                }];
                
            }
        }
        
    }];
    
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

#pragma mark - Public Methods (Survey Management)

- (void)refreshSurveysWithCompletion:(void (^)(NSError *))completionBlock {
    
    // TODO: also refresh questions as part of this method, potentially, or at least refactor to be Parse driven
    
    PFQuery *surveysQuery = [PFQuery queryWithClassName:@"Survey"];
    
    surveysQuery.limit = 1000;
    
    [surveysQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse withCompletion:nil];
        } else {
            
            HCRDebug(@"Surveys found: %d",objects.count);
            
            for (PFObject *object in objects) {
                
                self.localSurvey.localID = object.objectId;
                
                self.localSurvey.title = [object objectForKey:HCRPrefKeySurveyTitle
                                                      ofClass:@"NSString"
                                                    mustExist:NO];
                
                self.localSurvey.ageQuestion = [object objectForKey:HCRPrefKeySurveyAgeQuestion
                                                            ofClass:@"NSString"
                                                          mustExist:NO];
                
                self.localSurvey.genderQuestion = [object objectForKey:HCRPrefKeySurveyGenderQuestion
                                                               ofClass:@"NSString"
                                                             mustExist:NO];
                
                self.localSurvey.participantsQuestion = [object objectForKey:HCRPrefKeySurveyParticipantsQuestion
                                                                     ofClass:@"NSString"
                                                                   mustExist:NO];
                
            }
            
            [self _sync];
            
        }
        
        completionBlock(error);
        
    }];
    
}

#pragma mark - Public Methods (Question Management)

// TODO: (remote) get list of possible surveys to work with

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock {
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    
    questionsQuery.limit = 1000;
    
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
                    forAnswerSet:answerSet
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
    
}

#pragma mark - Public Methods (Answer Management)

- (void)createNewSurveyAnswerSet {
    
    // create new survey
    // store initial vars necessary
    // add to list of local surveys in-process
    
    HCRSurveyAnswerSet *surveyAnswerSet = [HCRSurveyAnswerSet newAnswerSet];
    
    [self.localSurvey addAnswerSet:surveyAnswerSet];
    [self _sync];
    
}

- (void)removeAllAnswerSets {
    
    [self.localSurvey removeAllAnswerSets];
    [self _sync];
    
}

- (void)removeAnswerSetWithID:(NSString *)answerSetID {
    
    [self.localSurvey removeAnswerSetWithLocalID:answerSetID];
    
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
        forAnswerSet:targetAnswerSet
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
        forAnswerSet:targetAnswerSet
            forceSet:YES
                sort:YES
                sync:YES];
    
}

- (void)removeQuestionWithCode:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    HCRSurveyAnswerSetParticipant *participant = [[self surveyAnswerSetWithLocalID:answerSetID] participantWithID:participantID];
    
    [self _removeQuestionWithCode:questionCode withParticipant:participant sync:YES];
    
}

#pragma mark - Private Methods

- (void)_sync {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *encodedSurvey = [NSKeyedArchiver archivedDataWithRootObject:self.localSurvey];
    [defaults setObject:encodedSurvey forKey:HCRPrefKeySurvey];
    
    [defaults setObject:self.encodedAlerts forKey:HCRPrefKeyAlerts];
    
    [defaults synchronize];
    
}

#pragma mark - Private Methods (Surveys)

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
        
    } else if (condition.consent) {
        
        if (!answerSet.consent) {
            // fail if local consent has no response and the condition is non-NULL
            if (![condition.consent isEqual:[NSNull null]]) {
                return NO;
            }
            
        } else {
            // fail if consent is NULL OR if values don't equal
            if ([condition.consent isEqual:[NSNull null]]) {
                return NO;
            } else if (![answerSet.consent isEqualToNumber:condition.consent]) {
                return NO;
            }
        }
        
    } else {
        HCRError(@"Unhandled survey question condition: %@",condition);
        NSParameterAssert(NO);
        return NO;
    }
    
    return YES;
    
}

- (void)_setAnswer:(NSNumber *)answerCode withString:(NSString *)answerString forQuestion:(NSString *)questionCode forParticipant:(HCRSurveyAnswerSetParticipant *)targetParticipant forAnswerSet:(HCRSurveyAnswerSet *)answerSet forceSet:(BOOL)forceSet sort:(BOOL)sort sync:(BOOL)sync {
    
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
    
    // set age and gender and consent
    // TODO: get this dynamic from the server somehow
    if ([questionCode isEqualToString:@"0"]) {
        answerSet.consent = (questionData.answer) ? @(questionData.answer && questionData.answer.integerValue == 1) : nil;
    } else if ([questionCode isEqualToString:self.localSurvey.ageQuestion]) {
        targetParticipant.age = (questionData.answerString) ? @(questionData.answerString.integerValue) : nil;
    } else if ([questionCode isEqualToString:self.localSurvey.genderQuestion]) {
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

#pragma mark - Private Methods (Alerts)

- (NSMutableArray *)_restoreLocalAlertsFromDataStore {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *encodedArray = [defaults objectForKey:HCRPrefKeyAlerts ofClass:@"NSArray" mustExist:NO];
    
    if (!encodedArray) {
        encodedArray = @[].mutableCopy;
    }
    
    NSMutableArray *localAlerts = @[].mutableCopy;
    for (NSData *encodedAlert in encodedArray) {
        [localAlerts addObject:[NSKeyedUnarchiver unarchiveObjectWithData:encodedAlert]];
    }
    
    return localAlerts;
    
}

@end
