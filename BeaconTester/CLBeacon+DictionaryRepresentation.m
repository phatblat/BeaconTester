//
//  CLBeacon+DictionaryRepresentation.m
//  BeaconTester
//
//  Created by Ben Chatelain on 4/2/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

#import "CLBeacon+DictionaryRepresentation.h"

@implementation CLBeacon (DictionaryRepresentation)

- (NSDictionary *)dictionaryRepresentation
{
    return @{ @"uuid" : [self.proximityUUID UUIDString],
              @"major" : self.major,
              @"minor" : self.minor,
              @"rssi" : @(self.rssi),
            };
}

@end
