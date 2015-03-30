//
//  LocationController.h
//  Airvolution
//
//  Created by Julien Guanzon on 3/26/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@interface LocationController : NSObject

@property (nonatomic,strong) NSArray *locations;

+ (LocationController *)sharedInstance;

- (void)saveLocationWithName:(NSString *)name location:(CLLocation *)location;

- (void)loadLocationsFromCloudKit;


@end
