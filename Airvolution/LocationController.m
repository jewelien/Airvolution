//
//  LocationController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/26/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LocationController.h"

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

- (void)saveLocationWithName:(NSString *)name location:(CLLocation *)location {
    CKRecord *cloudKitLocation = [[CKRecord alloc] initWithRecordType:locationRecordKey];
    cloudKitLocation[locationIdentifierKey] = [[NSUUID UUID] UUIDString];
    cloudKitLocation[nameKey] = name;
    cloudKitLocation[locationKey] = location;
    
    [[LocationController publicDatabase] saveRecord:cloudKitLocation completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            NSLog(@"Location saved to CloudKit");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"savedToCloudKit" object:nil];
            
        } else {
            NSLog(@"NOT saved to CloudKit");
        }
    }];
    
}


- (void)loadLocationsFromCloudKit
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:locationRecordKey predicate:predicate];
    [[LocationController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"fetch locations failed");
        } else {
            NSLog(@"fetched locations successfully");
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (CKRecord *record in results) {
                NSMutableDictionary *dictionary = [NSMutableDictionary new];
                [dictionary setObject:[record objectForKey:nameKey] forKey:nameKey];
                [dictionary setObject:[record objectForKey:locationKey] forKey:locationKey];
                    [array addObject:dictionary];
            }
//            NSLog(@"records results : %@", results);
            self.locations = array;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationsFetched" object:nil];
        }
    }];

}


@end
