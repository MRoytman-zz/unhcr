//
//  HCRSurvey.h
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@interface HCRSurvey : HCRArchivalObject

@property (nonatomic, readonly) NSArray *questions;
@property (nonatomic, readonly) NSArray *answerSets;

@property (nonatomic, strong) NSMutableDictionary *questionDictionary;
@property (nonatomic, strong) NSMutableDictionary *answerSetDictionary;

@property (nonatomic, strong) NSString *localID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *ageQuestion;
@property (nonatomic, strong) NSString *genderQuestion;
@property (nonatomic, strong) NSString *participantsQuestion;

@end
