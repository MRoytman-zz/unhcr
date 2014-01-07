//
//  HCRDataManager.m
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataManager.h"
#import "HCRUser.h"

#import <Parse/Parse.h>

////////////////////////////////////////////////////////////////////////////////

// condition keys
NSString *const kSurveyQuestionConditionKeyParticipantID = @"participantID";
NSString *const kSurveyQuestionConditionKeyResponse = @"response";
NSString *const kSurveyQuestionConditionKeyResponseQuestion = @"question";
NSString *const kSurveyQuestionConditionKeyResponseAnswer = @"answer";
NSString *const kSurveyQuestionConditionKeyMinParticipants = @"minParticipants";

// NSUD KEYS
NSString *const HCRPrefKeyQuestions = @"HCRPrefKeyQuestions";
NSString *const HCRPrefKeyQuestionsAnswers = @"answers";
NSString *const HCRPrefKeyQuestionsUpdated = @"updated";
NSString *const HCRPrefKeyQuestionsQuestion = @"question";
NSString *const HCRPrefKeyQuestionsQuestionCode = @"questionId";
NSString *const HCRPrefKeyQuestionsConditions = @"conditions";
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

@property (nonatomic) NSArray *localSurveyQuestionsArray;
@property (nonatomic) NSMutableArray *localSurveyAnswerSetsArray;

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        self.localSurveyQuestionsArray = [defaults objectForKey:HCRPrefKeyQuestions ofClass:@"NSArray" mustExist:NO];
        self.localSurveyAnswerSetsArray = [[defaults objectForKey:HCRPrefKeyAnswerSets ofClass:@"NSArray" mustExist:NO] mutableCopy];
        
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setLocalSurveyQuestionsArray:(NSArray *)localSurveyQuestionsArray {
    _localSurveyQuestionsArray = localSurveyQuestionsArray;
    [self _sync];
}

#pragma mark - Public Methods

- (NSArray *)surveyQuestionsArray {
    
    return self.localSurveyQuestionsArray;
    
}

- (NSArray *)surveyAnswerSetsArray {
    
    return self.localSurveyAnswerSetsArray;
    
}

- (NSDate *)surveyLastUpdated {
    
    // TODO: make more efficient; don't always check whole array (somehow determine 'dirty' status)
    // is this faster than sorting the array and snagging index:0?
    
    NSDate *date; // set date to non-nil inside loop so it returns nil if no survey list
    
    for (NSDictionary *question in [self surveyQuestionsArray]) {
        
        if (!date) {
            date = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        date = [date laterDate:question[HCRPrefKeyQuestionsUpdated]];
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
            
            NSMutableArray *newArray = [NSMutableArray new];
            
            for (PFObject *object in objects) {
                
                [newArray addObject:[self _dictionaryFromPFObject:object]];
                
            }
            
            // sort it!
            // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html#//apple_ref/doc/uid/20001845-BAJEAIEE
            // http://stackoverflow.com/questions/8633932/how-to-sort-an-array-with-alphanumeric-values
            
            NSSortDescriptor *questionCodeDescriptor = [[NSSortDescriptor alloc] initWithKey:HCRPrefKeyQuestionsQuestionCode ascending:YES selector:@selector(localizedStandardCompare:)];
            
            NSArray *sortedArray = [newArray sortedArrayUsingDescriptors:@[questionCodeDescriptor]];
            
            self.localSurveyQuestionsArray = sortedArray;
        }
        
        completionBlock(error);
        
    }];
    
}

- (void)refreshSurveyResponsesForAllParticipantsWithAnswerSet:(NSDictionary *)answerSet {
    
    NSArray *participants = [self getParticipantsForAnswerSet:answerSet];
    
    for (NSDictionary *participantData in participants) {
        
        NSInteger participantID = [[participantData objectForKey:HCRPrefKeyAnswerSetsParticipantsID ofClass:@"NSNumber"] integerValue];
        
        [self refreshSurveyResponsesForParticipantID:participantID withAnswerSet:answerSet];
        
    }
    
}

- (void)refreshSurveyResponsesForParticipantID:(NSInteger)participantID withAnswerSet:(NSDictionary *)answerSet {
    
    for (NSDictionary *questionData in self.localSurveyQuestionsArray) {
        
        NSString *questionCode = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
        NSArray *conditions = [questionData objectForKey:HCRPrefKeyQuestionsConditions
                                                 ofClass:@"NSArray"
                                               mustExist:NO];
        
        BOOL skip = [[questionData objectForKey:HCRPrefKeyQuestionsSkip] boolValue];
        
        if (skip) {
            HCRDebug(@"Skipping question %@",questionCode);
        } else if (conditions) {
            
            // make sure they pass ALL tests!
            BOOL conditionPasses = YES;
            for (NSDictionary *condition in conditions) {
                
                for (NSString *key in condition.allKeys) {
                    
                    conditionPasses = [self _passCondition:condition withKey:key forAnswerSet:answerSet forParticipantID:participantID];
                    
                }
                
                if (conditionPasses == NO) {
                    HCRWarning(@"Condition failed: %@",condition);
                    break;
                }
                
            }
            
            if (conditionPasses) {
                NSString *answerSetID = [self getIDForAnswerSet:answerSet];
                [self setAnswer:nil forQuestion:questionCode withAnswerSetID:answerSetID withParticipantID:participantID];
            }
            
        } else {
            HCRDebug(@"No conditions found! Adding question: %@",questionData);
            NSString *answerSetID = [self getIDForAnswerSet:answerSet];
            [self setAnswer:nil forQuestion:questionCode withAnswerSetID:answerSetID withParticipantID:participantID];
        }
        
    }
    
}

- (NSDictionary *)getSurveyQuestionDataForQuestionCode:(NSString *)questionCode {
    
    NSDictionary *questionDictionary;
    
    for (NSDictionary *question in self.localSurveyQuestionsArray) {
        
        if ([question[HCRPrefKeyQuestionsQuestionCode] isEqualToString:questionCode]) {
            questionDictionary = question;
            break;
        }
        
    }
    
    return questionDictionary;
    
}

- (NSString *)getSurveyQuestionForResponseData:(NSDictionary *)responseData {
    
    NSString *targetCode = [responseData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion ofClass:@"NSString"];
    
    NSString *questionString;
    
    for (NSDictionary *questionData in self.localSurveyQuestionsArray) {
        NSString *questionCode = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
        if ([questionCode isEqualToString:targetCode]) {
            questionString = questionCode;
            break;
        }
    }
    
    return questionString;
    
}

- (NSArray *)getSurveyAnswersForResponseData:(NSDictionary *)responseData {
    
    NSString *targetCode = [responseData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion ofClass:@"NSString"];
    
    NSArray *answersArray;
    
    for (NSDictionary *questionData in self.localSurveyQuestionsArray) {
        NSString *questionCode = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
        if ([questionCode isEqualToString:targetCode]) {
            answersArray = [questionData objectForKey:HCRPrefKeyQuestionsAnswers ofClass:@"NSArray" mustExist:NO];
            break;
        }
    }
    
    return answersArray;
}

#pragma mark - Public Methods (Answer Management)

- (void)createNewSurveyAnswerSet {
    
    // create new survey
    // store initial vars necessary
    // add to list of local surveys in-process
    
    if (self.localSurveyAnswerSetsArray == nil) {
        self.localSurveyAnswerSetsArray = @[].mutableCopy;
    }
    
    NSMutableDictionary *surveyAnswerSet = [NSMutableDictionary new];
    
    surveyAnswerSet[HCRPrefKeyAnswerSetsLocalID] = [NSString stringWithNewUUID];
    surveyAnswerSet[HCRPrefKeyAnswerSetsTeamID] = [[HCRUser currentUser] teamID];
    surveyAnswerSet[HCRPrefKeyAnswerSetsUser] = [[HCRUser currentUser] objectId];
    surveyAnswerSet[HCRPrefKeyAnswerSetsDurationStart] = [NSDate date];
    surveyAnswerSet[HCRPrefKeyAnswerSetsParticipants] = @[@{HCRPrefKeyAnswerSetsParticipantsID: @0}];
    
    [self.localSurveyAnswerSetsArray addObject:surveyAnswerSet];
    [self _sync];
    
}

- (void)removeAnswerSetWithID:(NSString *)answerSetID {
    
    NSNumber *index = [self _indexForAnswerSetWithID:answerSetID];
    
    if (index) {
        [self.localSurveyAnswerSetsArray removeObjectAtIndex:index.integerValue];
        
        if (self.localSurveyAnswerSetsArray.count == 0) {
            self.localSurveyAnswerSetsArray = nil;
            [self _syncUnsafe];
        } else {
            [self _sync];
        }
        
    } else {
        // do nothing
        HCRWarning(@"No local answer set found with ID: %@",answerSetID);
    }
    
}

- (void)setAnswer:(NSString *)answerCode forQuestion:(NSString *)questionCode withAnswerSetID:(NSString *)answerSetID withParticipantID:(NSInteger)participantID {
    
    NSParameterAssert(questionCode);
    
    NSDictionary *targetAnswerSet;
    
    for (NSDictionary *answerSet in self.localSurveyAnswerSetsArray) {
        NSString *setID = [self getIDForAnswerSet:answerSet];
        if ([setID isEqualToString:answerSetID]) {
            targetAnswerSet = answerSet;
            break;
        }
    }
    
    if (targetAnswerSet) {
    
        // drill down to this particular response
        NSUInteger indexOfAnswerSet = [self.localSurveyAnswerSetsArray indexOfObject:targetAnswerSet];
        NSMutableDictionary *newAnswerSet = targetAnswerSet.mutableCopy;
        
        NSMutableArray *newParticipants = [[newAnswerSet objectForKey:HCRPrefKeyAnswerSetsParticipants
                                                             ofClass:@"NSArray"] mutableCopy];
        
        NSMutableDictionary *newParticipant = [[newParticipants objectAtIndex:participantID
                                                                     ofClass:@"NSDictionary"] mutableCopy];
        
        NSMutableArray *newResponses = [[newParticipant objectForKey:HCRPrefKeyAnswerSetsParticipantsResponses
                                                            ofClass:@"NSArray"
                                                          mustExist:NO] mutableCopy];
        
        NSString *existingAnswer;
        if (newResponses) {
            
            // if present, store old answer value and remove existing value
            NSDictionary *questionData = [self getResponseDataFromParticipantResponses:newResponses
                                                                      withQuestionCode:questionCode];
            
            existingAnswer = [questionData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer
                                                ofClass:@"NSString"
                                              mustExist:NO];
            
            [newResponses removeObject:questionData];
            
        } else {
            // make new set if no responses exist at all!
            newResponses = @[].mutableCopy;
        }
        
        // make new response
        NSMutableDictionary *newResponse = @{}.mutableCopy;
        
        [newResponse setObject:questionCode forKey:HCRPrefKeyAnswerSetsParticipantsResponsesQuestion];
        
        if (answerCode || existingAnswer) {
            // if answerCode is given, switch to that; if not, fall back to existing answer
            [newResponse setObject:(answerCode) ? answerCode : existingAnswer
                            forKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer];
        }
        
        // now re-add and back out
        [newResponses addObject:newResponse];
        
        [newParticipant setObject:newResponses forKey:HCRPrefKeyAnswerSetsParticipantsResponses];
        
        [newParticipants replaceObjectAtIndex:participantID withObject:newParticipant];
        
        [newAnswerSet setObject:newParticipants forKey:HCRPrefKeyAnswerSetsParticipants];
        
        [self.localSurveyAnswerSetsArray replaceObjectAtIndex:indexOfAnswerSet withObject:newAnswerSet];
        [self _sync];
        
    } else {
        HCRError(@"Logic error! Answer attempting to be set for set that does not exist in data manager.");
        NSParameterAssert(NO);
    }
    
}

#pragma mark - Public Methods (Answer Data)

- (NSDictionary *)getAnswerSetWithID:(NSString *)answerSetID {
    
    NSNumber *index = [self _indexForAnswerSetWithID:answerSetID];
    
    if (index) {
        return [self.localSurveyAnswerSetsArray objectAtIndex:index.integerValue];
    } else {
        return nil;
    }
    
}

- (NSString *)getIDForAnswerSet:(NSDictionary *)answerSet {
    return [answerSet objectForKey:HCRPrefKeyAnswerSetsLocalID ofClass:@"NSString"];
}

- (NSDate *)getCreatedDateForAnswerSet:(NSDictionary *)answerSet {
    return [answerSet objectForKey:HCRPrefKeyAnswerSetsDurationStart ofClass:@"NSDate"];
}

- (NSArray *)getParticipantsForAnswerSet:(NSDictionary *)answerSet {
    return [answerSet objectForKey:HCRPrefKeyAnswerSetsParticipants ofClass:@"NSArray"];
}

- (NSDictionary *)getParticipantDataForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID {
    
    NSDictionary *participantDictionary;
    
    for (NSDictionary *dictionary in [self getParticipantsForAnswerSet:answerSet]) {
        NSNumber *partyID = [dictionary objectForKey:HCRPrefKeyAnswerSetsParticipantsID ofClass:@"NSNumber"];
        if (partyID.integerValue == participantID) {
            participantDictionary = dictionary;
            break;
        }
    }
    
    return participantDictionary;
    
}

- (NSArray *)getResponsesForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID {
    
    NSDictionary *participantData = [self getParticipantDataForAnswerSet:answerSet
                                                       withParticipantID:participantID];
    
    NSArray *totalResponses = [participantData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponses
                                                    ofClass:@"NSArray"
                                                  mustExist:NO];
    
    return totalResponses;
    
}

- (NSDictionary *)getResponseDataFromParticipantResponses:(NSArray *)responses withQuestionCode:(NSString *)questionCode {
    
    NSDictionary *responseData;
    
    for (NSDictionary *questionData in self.localSurveyQuestionsArray) {
        NSString *code = [questionData objectForKey:HCRPrefKeyQuestionsQuestionCode ofClass:@"NSString"];
        if ([code isEqualToString:questionCode]) {
            responseData = questionData;
            break;
        }
    }
    
    return responseData;
    
}

- (NSNumber *)getAnswerFromAnswerSet:(NSDictionary *)answerSet forParticipantID:(NSInteger)participantID forQuestionCode:(NSString *)questionCode {
    
    NSArray *responses = [self getResponsesForAnswerSet:answerSet withParticipantID:participantID];
    
    NSDictionary *responseData = [self getResponseDataFromParticipantResponses:responses withQuestionCode:questionCode];
    
    return [responseData objectForKey:HCRPrefKeyAnswerSetsParticipantsResponsesAnswer ofClass:@"NSNumber" mustExist:NO];
    
}

- (NSInteger)getPercentCompleteForAnswerSet:(NSDictionary *)answerSet withParticipantID:(NSInteger)participantID {
    
    NSArray *totalResponses = [self getResponsesForAnswerSet:answerSet
                                           withParticipantID:participantID];
    
    return (totalResponses) ? 100 * totalResponses.count / self.localSurveyQuestionsArray.count : 0;
}

// (local) save array of people for each survey
// (local) save answers given per participant for survey
// (local) check conditions - per participant per question check of coded response
// (remote) get survey ID (gets current value + increments it)
// (remote) submit survey with ID, users, durection (updatedAt - createdAt), etc (relatively complex)

#pragma mark - Private Methods

- (void)_sync {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (self.localSurveyAnswerSetsArray) {
        [defaults setObject:self.localSurveyAnswerSetsArray
                     forKey:HCRPrefKeyAnswerSets];
    }
    
    if (self.localSurveyQuestionsArray) {
        [defaults setObject:self.localSurveyQuestionsArray
                     forKey:HCRPrefKeyQuestions];
    }
    
    [defaults synchronize];
    
}

- (void)_syncUnsafe {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.localSurveyAnswerSetsArray
                 forKey:HCRPrefKeyAnswerSets];
    
    [defaults setObject:self.localSurveyQuestionsArray
                 forKey:HCRPrefKeyQuestions];
    
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

- (NSNumber *)_indexForAnswerSetWithID:(NSString *)answerSetID {
    
    NSNumber *index; // is this OK? will it delete index 0 if none found?
    
    for (NSDictionary *answerSet in self.localSurveyAnswerSetsArray) {
        
        if ([[answerSet objectForKey:HCRPrefKeyAnswerSetsLocalID ofClass:@"NSString"] isEqualToString:answerSetID]) {
            index = @([self.localSurveyAnswerSetsArray indexOfObject:answerSet]);
            break;
        }
        
    }
    
    if (!index) {
        HCRWarning(@"No local answer set found with ID: %@",answerSetID);
    }
    
    return index;
    
}

- (BOOL)_passCondition:(NSDictionary *)condition withKey:(NSString *)key forAnswerSet:(NSDictionary *)answerSet forParticipantID:(NSInteger)participantID {
    
    if ([key isEqualToString:kSurveyQuestionConditionKeyParticipantID]) {
        
        NSInteger conditionalID = [[condition objectForKey:kSurveyQuestionConditionKeyParticipantID
                                                   ofClass:@"NSNumber"] integerValue];
        if (participantID != conditionalID) {
            return NO;
        }
        
    } else if ([key isEqualToString:kSurveyQuestionConditionKeyResponse]) {
        
        NSDictionary *targetResponse = [condition objectForKey:kSurveyQuestionConditionKeyResponse ofClass:@"NSDictionary"];
        
        NSString *targetQuestion = [targetResponse objectForKey:kSurveyQuestionConditionKeyResponseQuestion ofClass:@"NSString"];
        NSNumber *targetAnswer = [targetResponse objectForKey:kSurveyQuestionConditionKeyResponseAnswer ofClass:@"NSNumber"];
        
        NSNumber *answer = [self getAnswerFromAnswerSet:answerSet forParticipantID:participantID forQuestionCode:targetQuestion];
        
        if (targetAnswer != answer) {
            return NO;
        }
        
    } else if ([key isEqualToString:kSurveyQuestionConditionKeyMinParticipants]) {
        
        NSInteger targetParticipants = [[condition objectForKey:kSurveyQuestionConditionKeyMinParticipants ofClass:@"NSNumber"] integerValue];
        
        NSArray *participants = [self getParticipantsForAnswerSet:answerSet];
        
        if (participants.count < targetParticipants) {
            return NO;
        }
    
    } else {
        HCRError(@"Unhandled survey question condition: %@",key);
        NSParameterAssert(NO);
        return NO;
    }
    
    return YES;
    
}

@end
