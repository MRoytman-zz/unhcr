//
//  HCRSurveySubmission.h
//  UNHCR
//
//  Created by Sean Conrad on 1/14/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import <Parse/Parse.h>

@interface HCRSurveySubmission : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *teamID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSNumber *consent;
@property (nonatomic, strong) NSNumber *householdID;
@property (nonatomic, strong) NSNumber *participantID;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, strong) NSDictionary *answerCodes;
@property (nonatomic, strong) NSDictionary *answerStrings;
@property (nonatomic, strong) NSNumber *duration;

+ (NSString *)parseClassName;

@end
