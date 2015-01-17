//
//  EAEmailManager.m
//  evilapples
//
//  Created by Sean Conrad on 3/24/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "EAEmailUtilities.h"

////////////////////////////////////////////////////////////////////////////////

@interface EAEmailUtilities ()

@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) EAEmailCompletionBlock emailCompletionBlock;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation EAEmailUtilities

+ (id)sharedUtilities
{
    static EAEmailUtilities *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EAEmailUtilities alloc] init];
    });
	return manager;
}

- (id)init
{
    if ( self = [super init] )
    {
        //
    }
    return self;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    
    if (error) {
        NSLog(@"error sending email: %@",error);
    }
    
    EAEmailStatus emailStatus;
    switch (result) {
        case MFMailComposeResultSent:
        case MFMailComposeResultSaved:
            emailStatus = EAEmailStatusSuccess;
            break;
            
        case MFMailComposeResultFailed:
            emailStatus = EAEmailStatusFailed;
            break;
            
        case MFMailComposeResultCancelled:
            emailStatus = EAEmailStatusCancelled;
            break;
    }
    
    [self.viewController dismissViewControllerAnimated:YES
                                            completion:^{
                                                
                                                if (self.emailCompletionBlock) {
                                                    self.emailCompletionBlock(emailStatus);
                                                }
                                                
                                            }];
    
}

#pragma mark - Class Methods

+ (BOOL)canSendMail {
    return [MFMailComposeViewController canSendMail];
}

#pragma mark - Public Methods

- (void)dismissAllViewControllersAnimated:(BOOL)animated {
    [self.viewController dismissViewControllerAnimated:animated completion:nil];
}

- (void)emailFromViewController:(UIViewController *)controller
               withToRecipients:(NSArray *)recipientStringArray
                withSubjectText:(NSString *)subjectText
                   withBodyText:(NSString *)bodyText
                 withCompletion:(EAEmailCompletionBlock)completionBlock {

    NSCAssert([NSThread isMainThread], @"Require main thread");
    
    if ([MFMailComposeViewController canSendMail]) {
        
        // set completion block
        self.emailCompletionBlock = completionBlock;
        
        // make email
        MFMailComposeViewController *emailController = [[MFMailComposeViewController alloc] init];
        [emailController setMailComposeDelegate:self];
        
        // set recipients
        [emailController setToRecipients:recipientStringArray];
        
        // set text
        [emailController setSubject:subjectText];
        [emailController setMessageBody:bodyText
                                 isHTML:NO];
        
        // show controller
        self.viewController = controller;
        [self.viewController presentViewController:emailController
                                          animated:YES
                                        completion:nil];
        
    } else {
    
        [UIAlertView showWithTitle:@"Email Error"
                           message:@"Your device is not configured to send email! Please set up email on your device and try again."
                           handler:nil];
        
        if (self.emailCompletionBlock) {
            self.emailCompletionBlock(EAEmailStatusFailed);
        }
        
    }
    
}

- (void)emailFromViewController:(UIViewController *)controller withEmergencyDictionary:(NSDictionary *)emergencyDictionary withCompletion:(EAEmailCompletionBlock)completionBlock {
    
    NSDictionary *contactDictionary = [emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *emailString = [[contactDictionary objectForKey:@"Email" ofClass:@"NSString"] stringByAppendingString:@".test"];
    
#warning ADDING .TEST TO EMAIL ADDRESS
    NSString *subjectString = [NSString stringWithFormat:@"RE: %@ in %@ at %@ (%@)",
                               [emergencyDictionary objectForKey:@"Category" ofClass:@"NSString"],
                               [emergencyDictionary objectForKey:@"Camp" ofClass:@"NSString"],
                               [emergencyDictionary objectForKey:@"Location" ofClass:@"NSString"],
                               [emergencyDictionary objectForKey:@"Time" ofClass:@"NSString"]];
    
    NSString *bodyString = @"\n\n\n\nYou are receiving this message in response to an Emergency Bulletin you posted using the Refugee Information Service.";
    
    [self emailFromViewController:controller
                 withToRecipients:@[emailString]
                  withSubjectText:subjectString
                     withBodyText:bodyString
                   withCompletion:nil];
    
}

@end
