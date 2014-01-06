//
//  HCRDataManager.h
//  UNHCR
//
//  Created by Sean Conrad on 1/4/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCRDataManager : NSObject

@property (nonatomic, readonly) NSArray *surveyQuestionsArray;
@property (nonatomic, readonly) NSDate *surveyLastUpdated;

+ (id)sharedManager;

- (void)refreshSurveyQuestionsWithCompletion:(void (^)(NSError *error))completionBlock;

@end
