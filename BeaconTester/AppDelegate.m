//
//  AppDelegate.m
//  BeaconTester
//
//  Created by Ben Chatelain on 4/28/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

#import "AppDelegate.h"

//
// Private notification API usage
//
// http://stackoverflow.com/questions/14229955/is-there-a-way-to-check-if-the-ios-device-is-locked-unlocked#answer-14271472
// http://stackoverflow.com/questions/14352228/is-there-a-away-to-detect-the-event-when-ios-device-goes-to-sleep-mode-when-the#answer-14357568
//
static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSString *notifcationName = (__bridge NSString *)name;
    NSLog(@"Darwin notification NAME = %@",name);

    if ([notifcationName isEqualToString:@"com.apple.springboard.lockstate"]) {
        NSLog(@"LOCK STATUS CHANGED");
    }
    else if ([notifcationName isEqualToString:@"com.apple.springboard.lockcomplete"]) {
        // the "com.apple.springboard.lockcomplete" notification will always come after the "com.apple.springboard.lockstate" notification
        NSLog(@"DEVICE LOCKED");
    }
    else if ([notifcationName isEqualToString:@"com.apple.springboard.hasBlankedScreen"]) {
        NSLog(@"screen has either gone dark, or been turned back on!");
    }
}

@implementation AppDelegate

#pragma mark - Private Methods

- (void)registerforDeviceLockNotifications
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockstate"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.lockcomplete"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), //center
                                    NULL, // observer
                                    displayStatusChanged, // callback
                                    CFSTR("com.apple.springboard.hasBlankedScreen"), // event name
                                    NULL, // object
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

#pragma mark - UIApplicationDelegate Protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerforDeviceLockNotifications];

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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
