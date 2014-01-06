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

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager ()

@property (nonatomic) NSArray *localSurveyQuestionsArray;

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
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setLocalSurveyQuestionsArray:(NSArray *)localSurveyQuestionsArray {
    _localSurveyQuestionsArray = localSurveyQuestionsArray;
    [self _sync];
}

#pragma mark - Public Methods

// TODO: (remote) get list of surveys

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock {
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse withCompletion:nil];
        } else {
            
            HCRDebug(@"Questions found: %d",objects.count);
            
            NSMutableArray *newArray = [NSMutableArray new];
            
            for (PFObject *object in objects) {
                
                NSMutableDictionary *dictionary = [NSMutableDictionary new];
                
                for (NSString *key in [object allKeys]) {
                    [dictionary setObject:object[key]
                                   forKey:key];
                }
                
                [dictionary setObject:[object updatedAt]
                               forKey:HCRPrefKeyQuestionsUpdated];
                
                [newArray addObject:dictionary];
                
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
    
    // set date to non-nil inside loop so it returns nil if no survey list
    NSDate *date;
    
    for (NSDictionary *question in [[HCRDataManager sharedManager] surveyQuestionsArray]) {
        
        if (!date) {
            date = [NSDate dateWithTimeIntervalSince1970:0];
        }
        
        date = [date laterDate:question[HCRPrefKeyQuestionsUpdated]];
    }
    
    return date;
    
}

// (local) get question for code (e.g. 23a)
// (local) start new survey
// (local) save array of people for each survey
// (local) save answers given per participant for survey
// (local) check conditions - per participant per question check of coded response
// (remote) get survey ID (gets current value + increments it)
// (remote) submit survey with ID, users, etc (relatively complex)

#pragma mark - Private Methods

- (void)_sync {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.localSurveyQuestionsArray
                 forKey:HCRPrefKeyQuestions];
    
    [defaults synchronize];
    
}

@end
