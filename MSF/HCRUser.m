//
//  HCRUser.m
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import "HCRUser.h"

#import <Parse/PFObject+Subclass.h>

////////////////////////////////////////////////////////////////////////////////

@implementation HCRUser

@dynamic alertsAuthor, authorized, showConstruction, teamID, fullName, testUser;

#pragma mark - Class Methods

+ (void)surveySignInWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        BOOL success = (user && !error);
        completionBlock(success,error);
    }];
    
}

+ (void)surveyCreateUserWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL, NSError *))completionBlock {
    
    HCRUser *newUser = [HCRUser object];
    newUser.username = username;
    newUser.password = password;
    newUser.email = username;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded,error);
        }
    }];
    
}

@end
