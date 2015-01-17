//
//  EAEmailManager.h
//  evilapples
//
//  Created by Sean Conrad on 3/24/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

////////////////////////////////////////////////////////////////////////////////

typedef enum {
    EAEmailStatusSuccess    = 1,
    EAEmailStatusFailed,
    EAEmailStatusCancelled
} EAEmailStatus;

typedef void (^EAEmailCompletionBlock)(EAEmailStatus emailStatus);

////////////////////////////////////////////////////////////////////////////////

@interface EAEmailUtilities : NSObject
<MFMailComposeViewControllerDelegate>

+ (id)sharedUtilities;
+ (BOOL)canSendMail;

- (void)emailFromViewController:(UIViewController *)controller
               withToRecipients:(NSArray *)recipientStringArray
                withSubjectText:(NSString *)subjectText
                   withBodyText:(NSString *)bodyText
                 withCompletion:(EAEmailCompletionBlock)completionBlock;

- (void)emailFromViewController:(UIViewController *)controller
        withEmergencyDictionary:(NSDictionary *)emergencyDictionary
                 withCompletion:(EAEmailCompletionBlock)completionBlock;

@end
