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
NSString *const HCRPrefKeyAnswerSetsUser = @"userId";
NSString *const HCRPrefKeyAnswerSetsConsent = @"consent";
NSString *const HCRPrefKeyAnswerSetsHouseholdID = @"householdId";
NSString *const HCRPrefKeyAnswerSetsTeamID = @"teamId";
NSString *const HCRPrefKeyAnswerSetsParticipantID = @"participantId";
NSString *const HCRPrefKeyAnswerSetsParticipantAge = @"participantAge";
NSString *const HCRPrefKeyAnswerSetsParticipantGender = @"participantGender";
NSString *const HCRPrefKeyAnswerSetsDuration = @"duration";

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
            
            self.localSurveyQuestionsArray = [NSArray arrayWithArray:newArray];
        }
        
        completionBlock(error);
        
    }];
    
}

- (NSArray *)surveyQuestionsArray {
    
    return self.localSurveyQuestionsArray;
    
}

- (NSDate *)surveyLastUpdated {
    
    // TODO: make more efficient; don't always check whole array (somehow determine 'dirty' status)
    
    NSDate *date; // set date to non-nil inside loop so it returns nil if no survey list
    
    for (NSDictionary *question in [[HCRDataManager sharedManager] surveyQuestionsArray]) {
        
        if (!date) {
            date = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        date = [date laterDate:question[HCRPrefKeyQuestionsUpdated]];
    }
    
    return date;
    
}

- (NSDictionary *)surveyQuestionDataWithQuestionCode:(NSString *)questionCode {
    
    NSDictionary *questionDictionary;
    
    for (NSDictionary *question in [[HCRDataManager sharedManager] surveyQuestionsArray]) {
        
        if ([question[HCRPrefKeyQuestionsQuestionCode] isEqualToString:questionCode]) {
            questionDictionary = question;
            break;
        }
        
    }
    
    return questionDictionary;
    
}

- (NSDictionary *)createNewSurveyAnswerSet {
    
    // create new survey
    // store initial vars necessary
    // add to list of local surveys in-process
    
    NSMutableDictionary *surveyAnswerSet = [NSMutableDictionary new];
    
    surveyAnswerSet[HCRPrefKeyAnswerSetsTeamID] = [[HCRUser currentUser] teamID];
    surveyAnswerSet[HCRPrefKeyAnswerSetsUser] = [[HCRUser currentUser] objectId];
    surveyAnswerSet[HCRPrefKeyAnswerSetsDurationStart] = [NSDate date];
    surveyAnswerSet[HCRPrefKeyAnswerSetsParticipantID] = @1;
    
    [self.localSurveyAnswerSetsArray addObject:surveyAnswerSet];
    [self _sync];
    
    return surveyAnswerSet;
    
}

// (local) save array of people for each survey
// (local) save answers given per participant for survey
// (local) check conditions - per participant per question check of coded response
// (remote) get survey ID (gets current value + increments it)
// (remote) submit survey with ID, users, durection (updatedAt - createdAt), etc (relatively complex)

#pragma mark - Private Methods

- (void)_sync {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSArray arrayWithArray:self.localSurveyAnswerSetsArray]
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

@end
