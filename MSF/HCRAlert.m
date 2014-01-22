//
//  HCRAlert.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import "HCRAlert.h"

#import <Parse/PFObject+Subclass.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const kCoderKeyObjectID = @"kCoderKeyObjectID";
NSString *const kCoderKeyCreatedAt = @"kCoderKeyCreatedAt";
NSString *const kCoderKeyUpdatedAt = @"kCoderKeyUpdatedAt";
NSString *const kCoderKeyAuthorName = @"kCoderKeyAuthorName";
NSString *const kCoderKeyAuthorID = @"kCoderKeyAuthorID";
NSString *const kCoderKeyMessage = @"kCoderKeyMessage";
NSString *const kCoderKeyEnvironment = @"kCoderKeyEnvironment";
NSString *const kCoderKeyRead = @"kCoderKeyRead";

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlert

@dynamic authorName, authorID, message, read, environment;

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.objectId = [decoder decodeObjectForKey:kCoderKeyObjectID];
//        self.createdAt = [decoder decodeObjectForKey:kCoderKeyCreatedAt];
//        self.updatedAt = [decoder decodeObjectForKey:kCoderKeyUpdatedAt];
        self.authorName = [decoder decodeObjectForKey:kCoderKeyAuthorName];
        self.authorID = [decoder decodeObjectForKey:kCoderKeyAuthorID];
        self.message = [decoder decodeObjectForKey:kCoderKeyMessage];
        self.environment = [decoder decodeObjectForKey:kCoderKeyEnvironment];
        self.read = [[decoder decodeObjectForKey:kCoderKeyRead] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.objectId forKey:kCoderKeyObjectID];
    [encoder encodeObject:self.authorName forKey:kCoderKeyAuthorName];
    [encoder encodeObject:self.authorID forKey:kCoderKeyAuthorID];
    [encoder encodeObject:self.message forKey:kCoderKeyMessage];
    [encoder encodeObject:self.environment forKey:kCoderKeyEnvironment];
    [encoder encodeObject:@(self.read) forKey:kCoderKeyRead];
}

#pragma mark - Class Methods

+ (NSString *)parseClassName {
    return @"Alert";
}

+ (HCRAlert *)newAlertToPush {
    
    HCRAlert *alert = [HCRAlert new];
    
    // set environment so pushes can be sent to the proper channels
    alert.environment = HCRENVIRONMENT;
    
    return alert;
    
}

+ (HCRAlert *)localAlertCopyFromPFObject:(PFObject *)object {
    
    HCRAlert *alert = (HCRAlert *)object;
    alert.read = NO;
    
    return alert;
    
}

#pragma mark - Public Methods

- (NSComparisonResult)compareUsingCreatedDate:(HCRAlert *)alert {
    
    return [alert.updatedAt compare:self.updatedAt];
    
}

@end
