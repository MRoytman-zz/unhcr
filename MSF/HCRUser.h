//
//  HCRUser.h
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import <Parse/Parse.h>

@interface HCRUser : PFUser
<PFSubclassing>

@property BOOL testUser;
@property BOOL alertsAuthor;
@property BOOL authorized;
@property BOOL showConstruction;
@property NSString *teamID;
@property NSString *fullName;

+ (void)surveySignInWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)surveyCreateUserWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock;

@end
