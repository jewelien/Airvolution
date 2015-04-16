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
#import <AddressBook/AddressBook.h>

static NSString *const newLocationSavedNotificationKey = @"new location saved";
static NSString *const newLocationSaveFailedNotificationKey = @"new location not saved";
static NSString *const allLocationsFetchedNotificationKey = @"all locations fetched";
static NSString *const locationDeletedNotificationKey = @"location deleted";


@interface LocationController : NSObject

@property (nonatomic,strong) NSArray *locations;
@property (nonatomic, strong) Location *selectedLocation;
//@property (nonatomic, strong) User *user;


+ (LocationController *)sharedInstance;
//- (void)saveLocationWithName:(NSString *)name location:(CLLocation *)location addressArray:(NSArray *)address;
-(void)saveLocationWithName:(NSString *)name
                   location:(CLLocation *)location
              streetAddress:(NSString *)street
                       city:(NSString *)city
                      state:(NSString *)state
                        zip:(NSString *)zip
                    country:(NSString *)country;

- (void)loadLocationsFromCloudKitWithCompletion:(void (^)(NSArray *array))completion;
- (void)deleteLocation:(Location *)location;
- (NSDictionary *)addressDictionaryForLocationWithCLLocation:(CLLocation *)location;
- (Location *)findLocationMatchingLocation:(CLLocation *)location;
-(void)updateUsersSharedLocationsUsernameIfChanged:(NSString *)newUsername;


@end
