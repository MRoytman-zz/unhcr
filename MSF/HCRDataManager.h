//
//  HCRDataManager.h
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCRDataManager : NSObject

+ (id)sharedManager;

- (NSArray *)surveyQuestionsArray;
- (NSDate *)surveyLastUpdated;

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;

- (NSDictionary *)createNewSurveyAnswerSet;

@end
