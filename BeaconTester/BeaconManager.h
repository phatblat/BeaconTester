//
//  BeaconManager.h
//  BeaconTester
//
//  Created by Ben Chatelain on 4/1/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

@import CoreLocation;
@import Foundation;

extern NSString *const IVUserDefaults_ClosestBeacon;
extern NSString *const IVUserDefaults_ClosestBeaconTimestamp;
extern NSString *const IVNotification_NewClosestBeaconAcquired;
extern NSString *const IVNotification_DidEnterBeaconRegion;
extern NSString *const IVNotification_DidExitBeaconRegion;

@interface BeaconManager : NSObject <CLLocationManagerDelegate>

/**
 Singleton instance getter.
 */
+ (instancetype)sharedManager;

/**
 This is not the initializer you're looking for.
 */
- (id)init __attribute__((unavailable("This class is a singleton and cannot be instantiated. Use the sharedManager accessor method to retrieve the singleton instance.")));

@end
