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
#import <CloudKit/CloudKit.h>
#import <AddressBook/AddressBook.h>
@import MapKit;

static NSString *const newLocationSavedNotificationKey = @"new location saved";
static NSString *const newLocationSaveFailedNotificationKey = @"new location not saved";
static NSString *const updateMapKey = @"all locations fetched";
static NSString *const locationDeletedNotificationKey = @"location deleted";
static NSString *const locationAddedNotificationKey = @"location added";


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
                    country:(NSString *)country forBike:(BOOL)forBike;
- (void)saveLocationToCoreData:(NSDictionary*)record;
- (void)fetchLocationsnearLocation:(CLLocation*)location completion:(void (^)(NSArray *locations))completion;
-(void)fetchCurrentUserSavedLocationsWithCompletion:(void (^)(BOOL success))completion;
- (void)deleteLocationWithRecordName:(NSString*)recordName;
- (NSDictionary *)addressDictionaryForLocationWithCLLocation:(CLLocation *)location;
- (Location *)findLocationMatchingLocation:(CLLocation *)location;
-(void)didReceiveNotification:(NSDictionary*)notificationInfo;
-(void)subscribe;
- (void)reportLocation:(Location*)location withCompletion:(void(^)(BOOL success))completion;
- (void)cancelReportOnLocation:(Location*)location withCompletion:(void(^)(BOOL success))completion;
-(UIAlertController*)alertForDirectionsToPlacemark:(MKPlacemark*)placemark;
-(void)goToMapsAppForDirectionsToPlacemark:(MKPlacemark*)placemark;
-(void)fetchAllLocationsIfNecessaryInBackground;
- (Location *)findLocationInCoreDataWithLocationIdentifierOrRecordName:(NSString*)string;
@end
