//
//  SCErrorManager.m
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "SCErrorManager.h"

@implementation SCErrorManager

#pragma mark -
#pragma mark Life Cycle

+ (id)sharedManager {
    
    // TODO: make threadsafe
    static SCErrorManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SCErrorManager alloc] init];
    });
	return manager;
}

- (id)init
{
    self = [super init];
    if ( self != nil )
    {
        //
    }
    return self;
}

#pragma mark - Class Methods

- (void)showAlertForError:(NSError *)error withErrorSource:(SCErrorSource)errorSource {
    
    switch (errorSource) {
        case SCErrorSourceParse:
            [self _showAlertForParseError:error];
            break;
            
        default:
            NSAssert(NO, @"Unhandled error source!");
            break;
    }
    
}

#pragma mark - Private Methods

- (void)_showAlertForParseError:(NSError *)parseError {
    
    // http://parse.com/docs/dotnet/api/html/T_Parse_ParseException_ErrorCode.htm
    
    NSString *errorTitle = @"Connection Error";
    NSString *errorBody = @"The connection to our servers has failed. Please try again later.\n\nFor further assistance, contact us at: help@hms.io";
    
    if (parseError.code == 100) {
        // no internet connection; do nothing - default messaging works
    } else if (parseError.code == 101) {
        errorTitle = @"Incorrect Username/Password";
        errorBody = @"Please try again. If you've forgotten your password, scroll down and tap \"Forgot Password\".";
    }
    
    [UIAlertView showWithTitle:errorTitle
                       message:errorBody
                       handler:nil];
    
}

@end
