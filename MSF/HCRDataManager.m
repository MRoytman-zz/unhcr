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
NSString *const HCRPrefKeyAnswerSetsLocalID = @"HCRPrefKeyAnswerSetsLocalID";
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
    
    if (self.localSurveyAnswerSetsArray == nil) {
        self.localSurveyAnswerSetsArray = @[].mutableCopy;
    }
    
    NSMutableDictionary *surveyAnswerSet = [NSMutableDictionary new];
    
    surveyAnswerSet[HCRPrefKeyAnswerSetsLocalID] = [NSString stringWithNewUUID];
    surveyAnswerSet[HCRPrefKeyAnswerSetsTeamID] = [[HCRUser currentUser] teamID];
    surveyAnswerSet[HCRPrefKeyAnswerSetsUser] = [[HCRUser currentUser] objectId];
    surveyAnswerSet[HCRPrefKeyAnswerSetsDurationStart] = [NSDate date];
    surveyAnswerSet[HCRPrefKeyAnswerSetsParticipantID] = @1;
    
    [self.localSurveyAnswerSetsArray addObject:surveyAnswerSet];
    [self _sync];
    
    return surveyAnswerSet;
    
}

- (NSString *)answerSetIDForAnswerSet:(NSDictionary *)answerSet {
    
    return [answerSet objectForKey:HCRPrefKeyAnswerSetsLocalID ofClass:@"NSString"];
    
}

- (NSDictionary *)answerSetWithID:(NSString *)answerSetID {
    
    NSNumber *index = [self _indexForAnswerSetWithID:answerSetID];
    
    if (index) {
        return [self.localSurveyAnswerSetsArray objectAtIndex:index.integerValue];
    } else {
        return nil;
    }
    
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

@end
