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
            
//            NSMutableArray *newArray = [NSMutableArray new];
            
            NSMutableDictionary *newDictionary = @{}.mutableCopy;
            
            for (PFObject *object in objects) {
                
                HCRSurveyQuestion *question = [HCRSurveyQuestion newQuestionWithDictionary:[self _dictionaryFromPFObject:object]];
                
                [newDictionary setObject:question forKey:question.questionCode];
                
//                [newArray addObject:question];
                
            }
            
//            // sort it!
//            // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html#//apple_ref/doc/uid/20001845-BAJEAIEE
//            // http://stackoverflow.com/questions/8633932/how-to-sort-an-array-with-alphanumeric-values
//            
//            NSSortDescriptor *questionCodeDescriptor = [[NSSortDescriptor alloc] initWithKey:HCRPrefKeyQuestionsQuestionCode ascending:YES selector:@selector(localizedStandardCompare:)];
//            
//            NSArray *sortedArray = [newArray sortedArrayUsingDescriptors:@[questionCodeDescriptor]];
//            
//            self.localSurvey.questions = sortedArray;
//            
//            for (NSDictionary *sortedObject in sortedArray) {
//                HCRSurveyQuestion *question = [HCRSurveyQuestion newQuestionWithDictionary:sortedObject];
//                [survey setObject:question forKey:question.questionCode];
//            }
            
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

//- (NSDictionary *)getSurveyQuestionDataForQuestionCode:(NSString *)questionCode {
//    
//    NSDictionary *questionDictionary;
//    
//    for (NSDictionary *question in self.localSurvey.questions) {
//        
//        if ([question[HCRPrefKeyQuestionsQuestionCode] isEqualToString:questionCode]) {
//            questionDictionary = question;
//            break;
//        }
//        
//    }
//    
//    return questionDictionary;
//    
//}
//
//- (NSString *)getSurveyQuestionCodeForParticipantResponseData:(NSDictionary *)responseData {
//    
//    NSString *targetCode = [responseData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion ofClass:@"NSString"];
//    
//    NSString *questionString;
//    
//    for (NSDictionary *questionData in self.localSurvey.questions) {
//        NSString *questionCode = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
//        if ([questionCode isEqualToString:targetCode]) {
//            questionString = questionCode;
//            break;
//        }
//    }
//    
//    return questionString;
//    
//}
//
//- (NSArray *)getSurveyAnswerDataArrayForSurveyQuestionCode:(NSString *)questionCode {
//    
//    NSArray *answersArray;
//    
//    for (NSDictionary *questionData in self.localSurvey.questions) {
//        NSString *innerCode = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
//        if ([innerCode isEqualToString:questionCode]) {
//            answersArray = [questionData objectForKey:HCRPrefKeyQuestionsAnswers ofClass:@"NSArray" mustExist:NO];
//            break;
//        }
//    }
//    
//    return answersArray;
//    
//}
//
//- (NSArray *)getSurveyAnswerStringsForSurveyQuestionCode:(NSString *)questionCode {
//    
//    NSArray *surveyAnswers = [self getSurveyAnswerDataArrayForSurveyQuestionCode:questionCode];
//    
//    NSMutableArray *answerStrings = @[].mutableCopy;
//    
//    for (NSDictionary *answer in surveyAnswers) {
//        NSString *answerString = [answer objectForKey:HCRPrefKeyQuestionsAnswersString ofClass:@"NSString"];
//        [answerStrings addObject:answerString];
//    }
//    
//    return (answerStrings.count > 0) ? [NSArray arrayWithArray:answerStrings] : nil;
//    
//}
//
//- (BOOL)getSurveyAnswerFreeformStatusFromSurveyAnswerData:(NSDictionary *)answerData {
//    return [[answerData objectForKey:HCRPrefKeyQuestionsAnswersFreeform ofClass:@"NSNumber" mustExist:NO] boolValue];
//}
//
//- (NSNumber *)getSurveyAnswerDefaultAnswerFromSurveyAnswerData:(NSDictionary *)answerData {
//    return [answerData objectForKey:HCRPrefKeyQuestionsDefaultAnswer ofClass:@"NSNumber" mustExist:NO];
//}

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

//#pragma mark - Public Methods (Answer Data)
//
//- (NSDictionary *)getAnswerSetWithID:(NSString *)answerSetID {
//
//    NSNumber *index = [self _indexForAnswerSetWithID:answerSetID];
//
//    if (index) {
//        return [self.localSurveyAnswerSetsArray objectAtIndex:index.integerValue];
//    } else {
//        return nil;
//    }
//    
//}
//
//- (NSString *)getIDForAnswerSet:(NSDictionary *)answerSet {
//    return [answerSet objectForKey:HCRPrefKeyAnswerSetsLocalID ofClass:@"NSString"];
//}
//
//- (NSDate *)getCreatedDateForAnswerSet:(NSDictionary *)answerSet {
//    return [answerSet objectForKey:HCRPrefKeyAnswerSetsDurationStart ofClass:@"NSDate"];
//}
//
//- (NSArray *)getParticipantsForAnswerSet:(NSDictionary *)answerSet {
//    return [answerSet objectForKey:HCRPrefKeyAnswerSetsParticipants ofClass:@"NSArray"];
//}
//
//- (NSInteger)getParticipantIDForParticipantData:(NSDictionary *)participant {
//    
//}
//
//- (NSDictionary *)getParticipantDataForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID {
//    
//    NSDictionary *participantDictionary;
//    
//    for (NSDictionary *dictionary in [self getParticipantsForAnswerSet:answerSet]) {
//        NSNumber *partyID = [dictionary objectForKey:HCRPrefKeyAnswerSetsParticipantsID ofClass:@"NSNumber"];
//        if (partyID.integerValue == participantID) {
//            participantDictionary = dictionary;
//            break;
//        }
//    }
//    
//    return participantDictionary;
//    
//}
//
//- (NSArray *)getQuestionsAndAnswersForParticipantID:(NSInteger)participantID withAnswerSet:(NSDictionary *)answerSet {
//    
//    NSDictionary *participantData = [self getParticipantDataForAnswerSet:answerSet
//                                                       withParticipantID:participantID];
//    
//    NSArray *totalResponses = [participantData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponses
//                                                    ofClass:@"NSArray"
//                                                  mustExist:NO];
//    
//    return totalResponses;
//    
//}
//
//- (NSDictionary *)getAnswerDictionaryFromParticipantResponses:(NSArray *)responses withQuestionCode:(NSString *)questionCode {
//    
//    NSDictionary *responseData;
//    
//    for (NSDictionary *questionData in responses) {
//        NSString *code = [questionData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion ofClass:@"NSString"];
//        if ([code isEqualToString:questionCode]) {
//            responseData = questionData;
//            break;
//        }
//    }
//    
//    return responseData;
//    
//}
//
//- (NSNumber *)getAnswerForParticipantID:(NSInteger)participantID forQuestionCode:(NSString *)questionCode withAnswerSet:(NSDictionary *)answerSet {
//    
//    NSArray *responses = [self getQuestionsAndAnswersForParticipantID:participantID withAnswerSet:answerSet];
//    
//    NSDictionary *responseData = [self getAnswerDictionaryFromParticipantResponses:responses withQuestionCode:questionCode];
//    
//    return [responseData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer ofClass:@"NSNumber" mustExist:NO];
//    
//}
//

// (local) save array of people for each survey
// (local) save answers given per participant for survey
// (local) check conditions - per participant per question check of coded response
// (remote) get survey ID (gets current value + increments it)
// (remote) submit survey with ID, users, durection (updatedAt - createdAt), etc (relatively complex)

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

//- (NSNumber *)_indexForAnswerSetWithID:(NSString *)answerSetID {
//    
//    NSNumber *index; // is this OK? will it delete index 0 if none found?
//    
//    for (NSDictionary *answerSet in self.localSurveyAnswerSetsArray) {
//        
//        if ([[answerSet objectForKey:HCRPrefKeyAnswerSetsLocalID ofClass:@"NSString"] isEqualToString:answerSetID]) {
//            index = @([self.localSurveyAnswerSetsArray indexOfObject:answerSet]);
//            break;
//        }
//        
//    }
//    
//    if (!index) {
//        HCRWarning(@"No local answer set found with ID: %@",answerSetID);
//    }
//    
//    return index;
//    
//}

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
