//
//  SCErrorManager.h
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, SCErrorSource) {
    SCErrorSourceParse
};

////////////////////////////////////////////////////////////////////////////////

@interface SCErrorManager : NSObject

+ (id)sharedManager;

- (void)showAlertForError:(NSError *)error withErrorSource:(SCErrorSource)errorSource withCompletion:(void (^)(void))completionBlock;

@end
