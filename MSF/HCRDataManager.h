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
- (NSArray *)surveyAnswerSetsArray;
- (NSDate *)surveyLastUpdated;

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;

- (NSDictionary *)createNewSurveyAnswerSet;
- (NSString *)answerSetIDForAnswerSet:(NSDictionary *)answerSet;
- (NSDictionary *)answerSetWithID:(NSString *)answerSetID;
- (void)removeAnswerSetWithID:(NSString *)answerSetID;

@end
