//
//  HCRAppDelegate.m
//  MSF
//
//  Created by Sean Conrad on 12/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRAppDelegate.h"
#import "HCRHomeViewController.h"
#import "HCRUser.h"
#import "HCRSurveySubmission.h"
#import "HCRAlert.h"

#import <Parse/Parse.h>

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
#ifdef HCR_WIPE_NSUD
    HCRDebug(@"wiping NSUserDefaults (too late now anyway!)");
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:appDomain];
#endif
    
    // PARSE
    [HCRAlert registerSubclass];
    [HCRSurveySubmission registerSubclass];
    [HCRUser registerSubclass];
    [Parse setApplicationId:@"CZX2WArPOqFH6kWTNG30JWPfYVGO1SjmA0j3dwTH"
                  clientKey:@"l88Td8IxqYphPYso4Z8tbtonEH49aJpKOcuXSUfE"];
    
    [[HCRUser currentUser] refreshInBackgroundWithBlock:nil]; // in case user data has changed
    
    // PUSH
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // HCR CODE
    HCRHomeViewController *homeView = [[HCRHomeViewController alloc] initWithCollectionViewLayout:[HCRHomeViewController preferredLayout]];
    UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:homeView];
    rootNavigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.window.rootViewController = rootNavigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[HCRDataManager sharedManager] saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // clear badge when user enters the app
    [self _resetBadgeNumber];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    HCRDebug(@"PUSH RECEIVED! userInfo: %@",userInfo);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:HCRNotificationAlertNotificationReceived
                                                        object:nil
                                                      userInfo:userInfo];
    
    // if app is open, reset remote push info
    [self _resetBadgeNumber];
    
}

#pragma mark - Private Methods

- (void)_resetBadgeNumber {
    
    // PUSH: LOCAL DOUBLE-CLEAR
    // apparently -notifications- are cleared ONLY when the badge changes, so increment to 1 in case it's already at 0
    // http://stackoverflow.com/questions/8682051/ios-application-how-to-clear-notifications
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[PFInstallation currentInstallation] setBadge:0];
    [[PFInstallation currentInstallation] saveEventually];
    
}

@end
