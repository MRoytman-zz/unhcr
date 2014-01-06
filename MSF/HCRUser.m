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

NSString *const HCRUserAuthorizedKey = @"authorized";
NSString *const HCRUserTeamIDKey = @"teamId";

////////////////////////////////////////////////////////////////////////////////

@implementation HCRUser

#pragma mark - Overrides

+ (HCRUser *)currentUser {
    return (HCRUser *)[PFUser currentUser];
}

#pragma mark - Public Methods

- (BOOL)surveyUserAuthorized {
    return [[[HCRUser currentUser] objectForKey:HCRUserAuthorizedKey] boolValue];
}

- (NSString *)teamID {
    return [[HCRUser currentUser] objectForKey:HCRUserTeamIDKey];
}

+ (void)surveySignInWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        BOOL success = (user && !error);
        completionBlock(success,error);
    }];
    
}

+ (void)surveyCreateUserWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL, NSError *))completionBlock {
    
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    newUser.email = username;
    
    newUser[HCRUserAuthorizedKey] = @NO;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded,error);
        }
    }];
    
}

@end
