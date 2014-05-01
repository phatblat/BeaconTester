//
//  BeaconManager.m
//  BeaconTester
//
//  Created by Ben Chatelain on 4/1/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

#import "BeaconManager.h"
#import "CLBeacon+DictionaryRepresentation.h"

@import UIKit.UIAlertView;
@import UIKit.UIApplication;
@import UIKit.UILocalNotification;

@interface BeaconManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *beaconRegions;
@property (strong, nonatomic) UIAlertView *alertView;

@end

@implementation BeaconManager

#pragma mark - NSObject

+ (void)load
{
    [self sharedManager];
}

#pragma mark - Init

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static BeaconManager *_singleton;
    dispatch_once(&onceToken, ^{
        _singleton = [[BeaconManager alloc] initSingleton];
    });
    return _singleton;
}

- (instancetype)initSingleton
{
    if (self = [super init]) {
        if ([CLLocationManager isRangingAvailable]) {
            [self setupBeaconRegions];
            [self startMonitoringRegions];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device Not Compatible"
                                                                message:@"This app requires a device which supports Bluetooth Low Energy."
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self presentAlert:alertView];
        }
    }
    return self;
}

#pragma mark - Beacon Setup

/**
 Sets up a `CLLocationManager` and the beacon region(s) that we want to watch for.
 */
- (void)setupBeaconRegions
{
    // This location manager will be used to notify the user of region state transitions.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // Populate the regions we will range once.
    self.beaconRegions = [NSMutableArray array];


    //
    // Use this code to configure the UUIDs manually for testing
    //
    NSArray *supportedProximityUUIDs = @[
                                         // AirLocate Example App
                                         [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"], // unflashed KST major 33, minor 1,2
                                         [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
                                         [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"],

                                         // KST Particles
                                         [[NSUUID alloc] initWithUUIDString:@"8AEFB031-6C32-486F-825B-E26FA193487D"], // flashed (b010?) KST major 1, minor 1
                                         [[NSUUID alloc] initWithUUIDString:@"4C56C69A-D494-4DEE-AEFE-7E064803ECEE"],
                                         [[NSUUID alloc] initWithUUIDString:@"C75581A3-D1C6-4648-A9AC-F8F85F361D54"],
                                         [[NSUUID alloc] initWithUUIDString:@"76630532-774C-4641-BA52-E854107E4ADD"],

                                         // BlueCats
                                         [[NSUUID alloc] initWithUUIDString:@"DDBFBA71-9C58-4B5F-BE23-E5FDEEF11EF4"],

                                         // Estimote
                                         [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"],
                                        ];

    [supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
        NSUUID *uuid = (NSUUID *)uuidObj;
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        region.notifyEntryStateOnDisplay = YES;
        [self.beaconRegions addObject:region];

        NSLog(@"Added beacon region: %@", region);
    }];
}

- (void)startMonitoringRegions
{
    [self.beaconRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [self.locationManager startMonitoringForRegion:region];
    }];
}

/**
 Starts up the "ranging" beavior for iBeacons. Updates are delivered to the `locationManager:didRangeBeacons:inRegion:` delegate method.
 
 This "ranging" does not appear to work in the background.
 */
- (void)startRanging
{
    [self.beaconRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [self.locationManager startRangingBeaconsInRegion:region];
    }];
}

#pragma mark - CLLocationManagerDelegate (Region Monitoring)

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Monitoring started for region %@", region);
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"Location manager state %@ for region: %@", [self stringWithRegionState:state], region);
    [self didChangeState:[self stringWithRegionState:state] forRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region %@", region);
    [self didChangeState:@"Enter" forRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region %@", region);
    [self didChangeState:@"Exit" forRegion:(CLBeaconRegion *)region];
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Monitoring failed for region %@ with error: %@", region, error);
}

#pragma mark - CLLocationManagerDelegate (Ranging)

/**
 This delegate method is used because it is called in response to beacons appearing or changing signal strength.

 @see `CLLocationManagerDelegate`
 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [self didDetectBeacons:beacons];
}

#pragma mark - Enum Translation

- (NSString *)stringWithRegionState:(CLRegionState)state
{
    switch (state) {
        case CLRegionStateUnknown:
            return @"Unknown";
            break;

        case CLRegionStateInside:
            return @"Inside";
            break;

        case CLRegionStateOutside:
            return @"Outside";
            break;

        default:
            break;
    }
}

- (NSString *)stringWithProximity:(CLProximity)proximity
{
    switch (proximity) {
        case CLProximityUnknown:
            return @"Unknown";
            break;

        case CLProximityImmediate:
            return @"Immediate";
            break;

        case CLProximityNear:
            return @"Near";
            break;

        case CLProximityFar:
            return @"Far";
            break;

        default:
            break;
    }
}

#pragma mark - Region & Beacon Handling

- (void)didChangeState:(NSString *)state forRegion:(CLBeaconRegion *)region
{
    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendFormat:@"%@ region %@", state, region];


    if ([state isEqualToString:@"Enter"] || [state isEqualToString:@"Inside"]) {
        [self.locationManager startRangingBeaconsInRegion:region];
    } else if ([state isEqualToString:@"Exit"] || [state isEqualToString:@"Outside"]) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

- (void)didDetectBeacons:(NSArray *)beacons
{
    if ([beacons count] == 0) {
        return;
    }

    NSMutableString *message = [[NSMutableString alloc] init];
    [message appendFormat:@"%ld beacons detected", (long)[beacons count]];

    [beacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"\n\nBeacon #%ld", (long)idx);
        [self debugBeacon:obj];
    }];

    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        // Local notifications
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.alertBody = message;
        notification.userInfo = @{ @"notification" : @"contracted" };
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        // Present alert
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self presentAlert:alertView];
    }
}

#pragma mark - UIAlert Management

- (void)presentAlert:(UIAlertView *)alertView
{
    if (self.alertView) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    }

    self.alertView = alertView;
    [self.alertView show];
}

#pragma mark - Debugging

- (void)debugBeacon:(CLBeacon *)beacon
{
#if defined DEBUG
    NSString *uuid = [beacon.proximityUUID UUIDString];
    NSNumber *major = beacon.major;
    NSNumber *minor = beacon.minor;
    NSString *proximityString = [self stringWithProximity:beacon.proximity];
    CLLocationAccuracy accuracy = beacon.accuracy;
    NSInteger rssi = beacon.rssi;

    NSLog(@"\nuuid: %@\nmajor: %ld\nminor: %ld\nproximity: %@\naccuracy: %f\nrssi: %ld",
          uuid, [major longValue], [minor longValue], proximityString, accuracy, (long)rssi);
#endif
}

@end
