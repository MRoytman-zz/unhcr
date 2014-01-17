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

@property BOOL dirtyAnswerSets;
@property NSArray *sortedAnswerSets;

@property (nonatomic, readwrite) NSMutableDictionary *answerSetDictionary;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurvey

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.questionDictionary = [decoder decodeObjectForKey:HCRPrefKeyQuestions];
        self.answerSetDictionary = [decoder decodeObjectForKey:HCRPrefKeyAnswerSets];
        self.localID = [decoder decodeObjectForKey:HCRPrefKeySurveyLocalID];
        self.title = [decoder decodeObjectForKey:HCRPrefKeySurveyTitle];
        self.ageQuestion = [decoder decodeObjectForKey:HCRPrefKeySurveyAgeQuestion];
        self.genderQuestion = [decoder decodeObjectForKey:HCRPrefKeySurveyGenderQuestion];
        self.participantsQuestion = [decoder decodeObjectForKey:HCRPrefKeySurveyParticipantsQuestion];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.questionDictionary forKey:HCRPrefKeyQuestions];
    [encoder encodeObject:self.answerSetDictionary forKey:HCRPrefKeyAnswerSets];
    [encoder encodeObject:self.localID forKey:HCRPrefKeySurveyLocalID];
    [encoder encodeObject:self.title forKey:HCRPrefKeySurveyTitle];
    [encoder encodeObject:self.ageQuestion forKey:HCRPrefKeySurveyAgeQuestion];
    [encoder encodeObject:self.genderQuestion forKey:HCRPrefKeySurveyGenderQuestion];
    [encoder encodeObject:self.participantsQuestion forKey:HCRPrefKeySurveyParticipantsQuestion];
}

#pragma mark - Getters & Setters

- (void)setQuestionDictionary:(NSMutableDictionary *)questionDictionary {
    _questionDictionary = questionDictionary;
    self.dirtyQuestions = YES;
}

- (void)setAnswerSetDictionary:(NSMutableDictionary *)answerSetDictionary {
    _answerSetDictionary = answerSetDictionary;
    self.dirtyAnswerSets = YES;
}

- (NSArray *)questions {
    
    if (!self.questionDictionary) {
        
    } else if (!self.sortedQuestions || self.dirtyQuestions) {
        
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
    
    if (!self.answerSetDictionary) {
        self.sortedAnswerSets = nil;
    } else if (!self.sortedAnswerSets || self.dirtyAnswerSets) {
        
        self.dirtyAnswerSets = NO;
        
        // sort it!
        // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html#//apple_ref/doc/uid/20001845-BAJEAIEE
        // http://stackoverflow.com/questions/8633932/how-to-sort-an-array-with-alphanumeric-values
        
        NSMutableArray *answerSetArray = @[].mutableCopy;
        for (NSString *key in self.answerSetDictionary.allKeys) {
            [answerSetArray addObject:[self.answerSetDictionary objectForKey:key]];
        }
        
        [answerSetArray sortUsingSelector:@selector(compareStartedDateToAnswerSet:)];
        
        self.sortedAnswerSets = answerSetArray;
        
    }
    
    return self.sortedAnswerSets;
    
}

- (void)addQuestionDictionary:(NSDictionary *)questionDictionary {
    
    self.questionDictionary = questionDictionary.mutableCopy;
    self.dirtyQuestions = YES;
    
}

- (void)addAnswerSet:(HCRSurveyAnswerSet *)answerSet {
    
    if (self.answerSetDictionary == nil) {
        self.answerSetDictionary = @{}.mutableCopy;
    }
    
    [self.answerSetDictionary setObject:answerSet forKey:answerSet.localID];
    self.dirtyAnswerSets = YES;
    
}

- (void)removeAnswerSetWithLocalID:(NSString *)localID {
    
    [self.answerSetDictionary removeObjectForKey:localID];
    self.dirtyAnswerSets = YES;
    
    if (self.answerSetDictionary.count == 0) {
        self.answerSetDictionary = nil;
    }
    
}

- (void)removeAllAnswerSets {
    
    self.answerSetDictionary = nil;
    
}

@end
