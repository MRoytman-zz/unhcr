//
//  HCRSurveySubmission.m
//  UNHCR
//
//  Created by Sean Conrad on 1/14/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import "HCRSurveySubmission.h"

#import <Parse/PFObject+Subclass.h>

////////////////////////////////////////////////////////////////////////////////

// PARSE CLASSES
#ifdef DEBUG
NSString *const kSurveyResultClass = @"Test";
#else
#ifdef PRODUCTION
NSString *const kSurveyResultClass = @"Result";
#else
NSString *const kSurveyResultClass = @"Result-TestFlight";
#endif
#endif

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveySubmission

@dynamic teamID,userID,consent,householdID,participantID,age,gender,answerCodes,answerStrings,duration;

#pragma mark - Class Methods

+ (NSString *)parseClassName {
    return kSurveyResultClass;
}

#pragma mark - Getters & Setters

- (void)setAnswerCodes:(NSDictionary *)answerCodes {
    
    for (NSString *key in answerCodes) {
        NSString *keyString = [NSString stringWithFormat:@"code_%@",key];
        [self setObject:[answerCodes objectForKey:key] forKey:keyString];
    }
    
}

- (void)setAnswerStrings:(NSDictionary *)answerStrings {
    
    for (NSString *key in answerStrings) {
        NSString *keyString = [NSString stringWithFormat:@"string_%@",key];
        self[keyString] = [answerStrings objectForKey:key];
    }
    
}

@end
