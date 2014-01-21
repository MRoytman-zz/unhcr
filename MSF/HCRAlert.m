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

@implementation HCRAlert

@dynamic authorName, authorID, message, read;

#pragma mark - Class Methods

+ (NSString *)parseClassName {
    return @"Alert";
}

#pragma mark - Public Methods

- (NSComparisonResult)compareUsingCreatedDate:(HCRAlert *)alert {
    
    return [self.updatedAt compare:alert.updatedAt];
    
}

@end
