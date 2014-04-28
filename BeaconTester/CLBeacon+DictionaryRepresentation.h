//
//  CLBeacon+DictionaryRepresentation.h
//  BeaconTester
//
//  Created by Ben Chatelain on 4/2/14.
//  Copyright (c) 2014 Kaiser Permanente. All rights reserved.
//

@import CoreLocation;

@interface CLBeacon (DictionaryRepresentation)

- (NSDictionary *)dictionaryRepresentation;

@end
