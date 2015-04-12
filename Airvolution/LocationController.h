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
//#import "MapViewController.h"
#import <CloudKit/CloudKit.h>
//#import "User.h"

static NSString *const newLocationSavedNotificationKey = @"new location saved";
static NSString *const newLocationSaveFailedNotificationKey = @"new location not saved";
static NSString *const allLocationsFetchedNotificationKey = @"all locations fetched";


@interface LocationController : NSObject

@property (nonatomic,strong) NSArray *locations;
//@property (nonatomic, strong) User *user;


+ (LocationController *)sharedInstance;
- (void)saveLocationWithName:(NSString *)name location:(CLLocation *)location addressArray:(NSArray *)address;
- (void)loadLocationsFromCloudKitWithCompletion:(void (^)(NSArray *array))completion;




@end
