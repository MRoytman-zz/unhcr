//
//  HCRAppDelegate.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRAppDelegate.h"
#import "HCRHomeViewController.h"

#import <Parse/Parse.h>

@implementation HCRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // PARSE
    [Parse setApplicationId:@"goqitVsTnj11mpYdZltuuZuUvEPzUiv5Lf2Znghl"
                  clientKey:@"j4alKFSNJlVAHonKJi857Ziq5QrqDuiq2kjjKq6H"];
    
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
    
    // Parse UIAlert test UI :)
    [PFPush handlePush:userInfo];
    
    // if app is open, reset remote push info
    // (otherwise it will increment on server while app is open & receiving pushes)
    [self _resetBadgeNumber];
}

#pragma mark - Private Methods

- (void)_resetBadgeNumber {
    // PUSH: LOCAL DOUBLE-CLEAR
    // apparently -notifications- are cleared ONLY when the badge changes, so increment to 1 in case it's already at 0
    // http://stackoverflow.com/questions/8682051/ios-application-how-to-clear-notifications
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
