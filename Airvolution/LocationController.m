//
//  LocationController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/26/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LocationController.h"
#import <CloudKit/CloudKit.h>

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
        } else {
            NSLog(@"NOT saved to CloudKit");
        }
    }];
    
}

- (NSArray *)locations {
//    CKContainer *defaultContainer = [CKContainer defaultContainer];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:locationRecordKey predicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
//    CKQueryOperation *operation = [[CKQueryOperation alloc] initWithQuery:query];
//    operation.desiredKeys = @[@"%@, %@", nameKey, locationKey];
//    [[LocationController publicDatabase]addOperation:operation];
    [[LocationController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        
        if (error) {
            NSLog(@"fetch locations failed");
        } else {
            NSLog(@"fetched locations successfully");
            for (CKRecord *record in results) {
                //            NSLog(@"%@, %@", [record objectForKey:nameKey], [record objectForKey:locationKey]);
                [array addObject:[record objectForKey:nameKey]];
                [array addObject:[record objectForKey:locationKey]];
            }
        }
    }];
    return array;
}





@end
