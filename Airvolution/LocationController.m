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

- (void)saveLocationWithName:(NSString *)name location:(CLLocation *)location addressArray:(NSArray *)address
{
    CKRecord *cloudKitLocation = [[CKRecord alloc] initWithRecordType:locationRecordKey];
    cloudKitLocation[identifierKey] = [[NSUUID UUID] UUIDString];
    cloudKitLocation[nameKey] = name;
    cloudKitLocation[locationKey] = location;
    cloudKitLocation[streetKey] = address[0];
    cloudKitLocation[cityStateZipKey] = address[1];
    cloudKitLocation[countryKey] = address[2];
    
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSavedNotificationKey object:nil];
        [[UserController sharedInstance] fetchUsersSavedLocationsFromArray:self.locations];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:allLocationsFetchedNotificationKey object:nil];
            completion(self.locations);
        }
    }];

}

@end






