//
//  AppDelegate.m
//  BeaconTester
//
//  Created by Ben Chatelain on 4/28/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

#import "AppDelegate.h"
#import <notify.h>

NSString *const NotificationNameDidChangeDisplayStatus  = @"com.apple.iokit.hid.displayStatus";

@interface AppDelegate ()
{
    int _notifyTokenForDidChangeDisplayStatus;
}

@property (nonatomic, assign, getter = isDisplayOn) BOOL displayOn;
@property (nonatomic, assign, getter = isRegisteredForDarwinNotifications) BOOL registeredForDarwinNotifications;

@end

@implementation AppDelegate

#pragma mark - Private Methods

//
// Private notification API usage - used to log when the screen is on vs. off
//
// http://stackoverflow.com/questions/14229955/is-there-a-way-to-check-if-the-ios-device-is-locked-unlocked#answer-18636057
//
- (void)registerForDeviceLockNotifications
{
    __weak AppDelegate *weakSelf = self;

    uint32_t result = notify_register_dispatch(NotificationNameDidChangeDisplayStatus.UTF8String,
                                               &_notifyTokenForDidChangeDisplayStatus,
                                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l),
                                               ^(int info) {
                                                   __strong AppDelegate *strongSelf = weakSelf;

                                                   if (strongSelf)
                                                   {
                                                       uint64_t state;
                                                       notify_get_state(_notifyTokenForDidChangeDisplayStatus, &state);

                                                       strongSelf.displayOn = (BOOL)state;

                                                       if (strongSelf.displayOn) {
                                                           NSLog(@"********************* DISPLAY ON *********************");
                                                       } else {
                                                           NSLog(@"********************* DISPLAY OFF *********************");
                                                       }
                                                   }
                                               });
    if (result != NOTIFY_STATUS_OK)
    {
        self.registeredForDarwinNotifications = NO;
        return;
    }

    self.registeredForDarwinNotifications = YES;
}

#pragma mark - UIApplicationDelegate Protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerForDeviceLockNotifications];

    [application cancelAllLocalNotifications];

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
