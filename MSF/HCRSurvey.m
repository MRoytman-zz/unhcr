//
//  HCRSurvey.m
//  UNHCR
//
//  Created by Sean Conrad on 1/7/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurvey.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurvey ()

@property BOOL dirtyQuestions;
@property NSArray *sortedQuestions;

@end

////////////////////////////////////////////////////////////////////////////////

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

- (void)setQuestionDictionary:(NSMutableDictionary *)questionDictionary {
    _questionDictionary = questionDictionary;
    self.dirtyQuestions = YES;
}

- (NSArray *)questions {
    
    if ((!self.sortedQuestions || self.dirtyQuestions) && self.questionDictionary) {
        
        self.dirtyQuestions = NO;
        
        // sort it!
        // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html#//apple_ref/doc/uid/20001845-BAJEAIEE
        // http://stackoverflow.com/questions/8633932/how-to-sort-an-array-with-alphanumeric-values
        
        NSMutableArray *sortedArray = @[].mutableCopy;
        NSArray *sortedKeys = [self.questionDictionary.allKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        
        for (NSString *key in sortedKeys) {
            [sortedArray addObject:[self.questionDictionary objectForKey:key]];
        }
        
        self.sortedQuestions = sortedArray;
        
    }
    
    return self.sortedQuestions;
}

- (NSArray *)answerSets {
    return self.answerSetDictionary.allValues;
}

@end
