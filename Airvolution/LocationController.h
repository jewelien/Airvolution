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
@import MapKit;

static NSString *const newLocationSavedNotificationKey = @"new location saved";
static NSString *const newLocationSaveFailedNotificationKey = @"new location not saved";
static NSString *const updateMapKey = @"all locations fetched";
static NSString *const locationDeletedNotificationKey = @"location deleted";


@interface LocationController : NSObject

@property (nonatomic,strong) NSArray *locations;
@property (nonatomic, strong) Location *selectedLocation;
+ (LocationController *)sharedInstance;
-(void)saveLocationWithName:(NSString *)name
                   location:(CLLocation *)location
              streetAddress:(NSString *)street
                       city:(NSString *)city
                      state:(NSString *)state
                        zip:(NSString *)zip
                    country:(NSString *)country
                      notes:(NSString *)notes cost:(NSNumber*)cost;
- (void)saveLocationToCoreData:(NSDictionary*)record;
- (void)loadLocationsFromCloudKitWithCompletion:(void (^)(NSArray *array))completion;
- (void)deleteLocationWithRecordName:(NSString*)recordName;
- (NSDictionary *)addressDictionaryForLocationWithCLLocation:(CLLocation *)location;
- (Location *)findLocationMatchingLocation:(CLLocation *)location;
-(void)updateUsersSharedLocationsUsernameIfChanged:(NSString *)newUsername;
-(void)didReceiveNotification:(NSDictionary*)notificationInfo;
-(void)subscribe;

-(UIAlertController*)alertForDirectionsToPlacemark:(MKPlacemark*)placemark;
-(void)goToMapsAppForDirectionsToPlacemark:(MKPlacemark*)placemark;

@end
