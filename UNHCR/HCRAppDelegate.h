//
//  HCRAppDelegate.h
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <HockeySDK/HockeySDK.h>

@interface HCRAppDelegate : UIResponder
<UIApplicationDelegate, BITHockeyManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
