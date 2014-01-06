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

////////////////////////////////////////////////////////////////////////////////

extern NSString *const HCRUserAuthorizedKey;

////////////////////////////////////////////////////////////////////////////////

@interface HCRUser : PFUser<PFSubclassing>

+ (HCRUser *)currentUser;

- (BOOL)surveyUserAuthorized;
- (NSString *)teamID;

+ (void)surveySignInWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)surveyCreateUserWithUsername:(NSString *)username withPassword:(NSString *)password withCompletion:(void (^)(BOOL succeeded, NSError *error))completionBlock;

@end