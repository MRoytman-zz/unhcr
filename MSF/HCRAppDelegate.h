//
//  HCRAppDelegate.h
//  MSF
//
//  Created by Sean Conrad on 12/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)registerParseChannelsWithCurrentUser;

@end
