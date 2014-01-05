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
NSString *const kLocalSurveyQuestionsKey = @"kLocalSurveyQuestionsKey";

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataManager ()

@property NSArray *localSurveyQuestionsArray;

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
        self.localSurveyQuestionsArray = [defaults objectForKey:kLocalSurveyQuestionsKey ofClass:@"NSArray" mustExist:NO];
    }
    return self;
}

#pragma mark - Public Methods

// TODO: (remote) get list of surveys

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock {
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        HCRDebug(@"Questions found: %d",objects.count);
        
        if (error) {
            [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse];
        } else {
            self.localSurveyQuestionsArray = objects;
            HCRDebug(@"self.localSurveyQuestionsArray updated");
        }
        
        completionBlock(error);
        
    }];
    
}

- (NSArray *)surveyQuestionsArray {
    
    return self.localSurveyQuestionsArray;
    
}

// (remote) update all questions
// (local) save local copy of data
// (local) access local copy of questions
// (local) get last updated date for all questions
// (local) get question for code (e.g. 23a)
// (local) start new survey
// (local) save array of people for each survey
// (local) save answers given per participant for survey
// (local) check conditions - per participant per question check of coded response
// (remote) get survey ID (gets current value + increments it)
// (remote) submit survey with ID, users, etc (relatively complex)

#pragma mark - Private Methods



@end
