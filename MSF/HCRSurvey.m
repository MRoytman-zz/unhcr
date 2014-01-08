//
//  HCRSurvey.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurvey.h"

@implementation HCRSurvey

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.questionDictionary = [decoder decodeObjectForKey:HCRPrefKeyQuestions];
        self.answerSetDictionary = [decoder decodeObjectForKey:HCRPrefKeyAnswerSets];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.questionDictionary forKey:HCRPrefKeyQuestions];
    [encoder encodeObject:self.answerSetDictionary forKey:HCRPrefKeyAnswerSets];
}

#pragma mark - Getters & Setters

//- (NSArray *)propertyList {
//    return @[
//             NSStringFromSelector(@selector(questionDictionary)),
//             NSStringFromSelector(@selector(questionDictionary)),
//             ];
//}

- (NSArray *)questions {
    return self.questionDictionary.allValues;
}

- (NSArray *)answerSets {
    return self.answerSetDictionary.allValues;
}

@end
