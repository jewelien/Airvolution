//
//  LocationController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/26/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LocationController.h"
#import "UserController.h"

@implementation LocationController

+ (LocationController *)sharedInstance {
    static LocationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [LocationController new];
    });
    return sharedInstance;
}

+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}


-(void)saveLocationWithName:(NSString *)name
                   location:(CLLocation *)location
              streetAddress:(NSString *)street
                       city:(NSString *)city
                      state:(NSString *)state
                        zip:(NSString *)zip
                    country:(NSString *)country
{
    CKRecord *cloudKitLocation = [[CKRecord alloc] initWithRecordType:locationRecordKey];
    cloudKitLocation[identifierKey] = [[NSUUID UUID] UUIDString];
    cloudKitLocation[nameKey] = name;
    cloudKitLocation[locationKey] = location;
    cloudKitLocation[streetKey] = street;
    cloudKitLocation[cityKey] = city;
    cloudKitLocation[stateKey] = state;
    cloudKitLocation[zipKey] = zip;
    cloudKitLocation[countryKey] = country;
    
    if ([[UserController sharedInstance].currentUser.username isEqualToString:@""]) {
        NSString *currentUserRecordName = [UserController sharedInstance].currentUserRecordName;
        NSString *defaultUsername = [currentUserRecordName substringFromIndex:[currentUserRecordName length] - 12];
        cloudKitLocation [UsernameKey] = defaultUsername;
    } else {
        cloudKitLocation [UsernameKey] = [UserController sharedInstance]. currentUser.username;
    }
    
    [[LocationController publicDatabase] saveRecord:cloudKitLocation completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            NSLog(@"Location saved to CloudKit");
            NSLog(@"record saved: %@", record);
//            NSLog(@"IDENTIFIER %@", cloudKitLocation[identifierKey]);
            [self loadLocationsAfterSavingLocationIdentifier:cloudKitLocation[identifierKey]];
            
        } else {
            NSLog(@"NOT saved to CloudKit");
            [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSaveFailedNotificationKey object:nil];
        }
    }];
    
}

- (void)loadLocationsAfterSavingLocationIdentifier:(NSString *)identifier {
    NSMutableArray *locationsIdentifiers = [[NSMutableArray alloc] init];
    for (Location *location in self.locations) {
        [locationsIdentifiers addObject:location.identifier];
    }
    if (![locationsIdentifiers containsObject:identifier]) {
        [self loadLocationsFromCloudKitWithCompletion:^(NSArray *array) {
            [self loadLocationsAfterSavingLocationIdentifier:identifier];
        }];
    } else {
        NSLog(@"new location fetched from cloudKit successfully");
        [[UserController sharedInstance] fetchUsersSavedLocationsFromArray:self.locations];
        
            [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSavedNotificationKey object:nil];

    }
    
}

- (void)loadLocationsFromCloudKitWithCompletion:(void (^)(NSArray *array))completion
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:locationRecordKey predicate:predicate];
    [[LocationController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"fetch locations failed");
        } else {
            NSLog(@"fetched locations successfully");
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dictionary in results) {
                Location *location = [[Location alloc] initWithDictionary:dictionary];
                [tempArray addObject:location];
            }
            self.locations = tempArray;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:allLocationsFetchedNotificationKey object:nil];

            });
            
            completion(self.locations);
        }
    }];

}

- (void)deleteLocation:(CKRecordID *)recordID {
    NSLog(@"identifier, %@", recordID);
    [[LocationController publicDatabase] deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
        if (error) {
            NSLog(@"location delete failed, error %@", error);
        } else {
            NSLog(@"record ID %@ deleted", recordID);
            [self loadLocationsFromCloudKitWithCompletion:^(NSArray *array) {
                
                    [[UserController sharedInstance] fetchUsersSavedLocationsFromArray:array];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:locationDeletedNotificationKey object:nil];

                });

            }];
        }
    }];
}

- (NSDictionary *)addressDictionaryForLocationWithCLLocation:(CLLocation *)location {
    Location *selectedLocation = [self findLocationMatchingLocation:location];
    NSDictionary *dictionary = @{
             (__bridge NSString *)kABPersonAddressStreetKey : selectedLocation.street,
             (__bridge NSString *)kABPersonAddressCityKey : selectedLocation.city,
             (__bridge NSString *)kABPersonAddressStateKey : selectedLocation.state,
             (__bridge NSString *)kABPersonAddressZIPKey : selectedLocation.zip,
             (__bridge NSString *)kABPersonAddressCountryKey : selectedLocation.country,
             };
    return dictionary;
}

- (Location *)findLocationMatchingLocation:(CLLocation *)location {
//    Location *matchingLocation;
    for (Location *findLocation in self.locations) {
        NSLog(@"findLocation.location.coordinate %f, %f", findLocation.location.coordinate.longitude, findLocation.location.coordinate.latitude);
        if (findLocation.location.coordinate.latitude == location.coordinate.latitude
            && findLocation.location.coordinate.longitude == location.coordinate.longitude) {
            self.selectedLocation = findLocation;
        }
    }
//    return matchingLocation;
    return self.selectedLocation;
}





@end






