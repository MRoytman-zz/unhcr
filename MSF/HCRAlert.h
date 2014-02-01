//
//  HCRAlert.h
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//
// https://parse.com/docs/ios_guide#subclasses/iOS
//

#import <Parse/Parse.h>

@interface HCRAlert : PFObject
<PFSubclassing>

@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSString *authorID;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *environment;
@property (nonatomic, strong) NSDate *submittedTime;
@property (nonatomic) BOOL read;

+ (NSString *)parseClassName;

+ (HCRAlert *)newAlertToPush;
+ (HCRAlert *)localAlertCopyFromPFObject:(PFObject *)object;

- (NSComparisonResult)compareUsingCreatedDate:(HCRAlert *)alert;

@end
