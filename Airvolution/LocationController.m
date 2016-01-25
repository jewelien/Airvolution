//
//  LocationController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/26/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LocationController.h"
#import "UserController.h"
#import "Stack.h"

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
                       city:(NSString *)city state:(NSString *)state zip:(NSString *)zip
                    country:(NSString *)country
                      notes:(NSString *)notes
{
    CKReference *userReference = [[CKReference alloc] initWithRecordID:[UserController sharedInstance].currentUserRecordID action:CKReferenceActionNone];
    CKRecord *cloudKitLocation = [[CKRecord alloc] initWithRecordType:locationRecordKey];
    cloudKitLocation[identifierKey] = [[NSUUID UUID] UUIDString];
    cloudKitLocation[nameKey] = name;
    cloudKitLocation[locationKey] = location;
    cloudKitLocation[streetKey] = street;
    cloudKitLocation[cityKey] = city;
    cloudKitLocation[stateKey] = state;
    cloudKitLocation[zipKey] = zip;
    cloudKitLocation[countryKey] = country;
    cloudKitLocation[userRecordIDRefKey] = userReference;
    cloudKitLocation[notesKey] = notes;
    
    if (![UserController sharedInstance].currentUser.username) {
        NSLog(@"currentUser.username %@", [UserController sharedInstance].currentUser.username);
        //    if ([[UserController sharedInstance].currentUser.username isEqualToString:@""]) {
        NSString *currentUserRecordName = [UserController sharedInstance].currentUserRecordName;
        NSString *defaultUsername = [currentUserRecordName substringFromIndex:[currentUserRecordName length] - 12];
        cloudKitLocation [usernameKey] = defaultUsername;
    } else {
        cloudKitLocation [usernameKey] = [UserController sharedInstance].currentUser.username;
    }
    
    [[LocationController publicDatabase] saveRecord:cloudKitLocation completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            NSLog(@"Location saved to CloudKit");
            NSLog(@"record saved: %@", record);
            [self saveLocationToCoreData:(NSDictionary*)record];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSavedNotificationKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];

            });
        } else {
            NSLog(@"NOT saved to CloudKit");
            [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSaveFailedNotificationKey object:nil];
        }
    }];
    
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
            for (NSDictionary *record in results) {
                Location *existingLocation = [self findLocationInCoreDataWithLocationIdentifier:[record objectForKey:identifierKey]];
                if (!existingLocation) {
                    [self saveLocationToCoreData:record];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
            });
            completion(self.locations);
        }
    }];
    
}

- (void)saveLocationToCoreData:(NSDictionary*)record {
    Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
    location.locationName = [record objectForKey:nameKey];
    location.street =  [record objectForKey:streetKey];
    location.city =  [record objectForKey:cityKey];
    location.state =  [record objectForKey:stateKey];
    location.zip =  [record objectForKey:zipKey];
    location.country =  [record objectForKey:countryKey];
    NSDate *date =  [record objectForKey:creationDateKey];
    location.creationDate = date;
    location.identifier =  [record objectForKey:identifierKey];
    location.locationNotes =  [record objectForKey:notesKey];
    location.location = [record objectForKey:locationKey];
    CKRecordID *recordID = [record objectForKey:recordIDKey];
    location.recordName = recordID.recordName;
    CKReference *reference = [record objectForKey:userRecordIDRefKey];
    location.userRecordName = reference.recordID.recordName;
    
    if (![location isInserted]) {
        [[Stack sharedInstance].managedObjectContext insertObject:location];
    }
    [[Stack sharedInstance].managedObjectContext refreshObject:location mergeChanges:YES];
    [self saveToCoreData];
}

- (Location *)findLocationInCoreDataWithLocationIdentifier:(NSString*)identifier {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"identifier == %@ || recordName == %@", identifier, identifier]];
    NSError *error;
    NSArray *array = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return array.firstObject;
}


-(NSArray *)locations {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    NSArray *array = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSLog(@"ALL LOCATIONS COUNT = %ld", array.count);
    return array;
}

-(void)saveToCoreData {
//    [[Stack sharedInstance].managedObjectContext refreshAllObjects];
    [[Stack sharedInstance].managedObjectContext save:nil];
//    NSError *error = nil;
//    if(![[Stack sharedInstance].managedObjectContext save:&error]) {
//        NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
//        NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
//        if(detailedErrors != nil && [detailedErrors count] > 0) {
//            for(NSError* detailedError in detailedErrors) {
//                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
//            }
//        }
//        else {
//            NSLog(@"  %@", [error userInfo]);
//        }
//    }
//    [[Stack sharedInstance].managedObjectContext performBlock:^{
//        NSError *error = nil;
//        BOOL success = [[Stack sharedInstance].managedObjectContext save:&error];
//        if (!success) {
//            NSLog(@"Core Data save ERROR %@", error);
//        }
//    }];
//    if (![[NSThread currentThread] isMainThread]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[Stack sharedInstance].managedObjectContext save:NULL];
//        });
//        return;
//    }
}

- (void)deleteLocationWithRecordName:(NSString*)recordName {
    CKRecordID *recordID = [[CKRecordID alloc]initWithRecordName:[NSString stringWithFormat:@"%@",recordName]];
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[recordID]];
    operation.savePolicy = CKRecordSaveAllKeys;
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        if (!error) {
            //delete in CoreData
            Location *locationToDelete = [self findLocationInCoreDataWithLocationIdentifier:recordName];
            [[Stack sharedInstance].managedObjectContext deleteObject:locationToDelete];
            [self saveToCoreData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:locationDeletedNotificationKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
            });
        } else {
            NSLog(@"Error: %@",error);
        }

    };
    [[LocationController publicDatabase]addOperation:operation];
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
    for (Location *findLocation in self.locations) {
//        NSLog(@"findLocation.location.coordinate %f, %f", findLocation.location.coordinate.longitude, findLocation.location.coordinate.latitude);
        if (findLocation.location.coordinate.latitude == location.coordinate.latitude
            && findLocation.location.coordinate.longitude == location.coordinate.longitude) {
            self.selectedLocation = findLocation;
        }
    }
    return self.selectedLocation;
}


-(void)updateUsersSharedLocationsUsernameIfChanged:(NSString *)newUsername {
    NSMutableArray *usersLocationsRecordId = [[NSMutableArray alloc] init];
    for (Location *location in [UserController sharedInstance].currentUser.locations) {
        CKRecordID *recordID = [[CKRecordID alloc]initWithRecordName:location.recordName];
        [usersLocationsRecordId addObject:recordID];
    }
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:usersLocationsRecordId];
    fetchOperation.perRecordCompletionBlock = ^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        CKRecord *cloudKitLocation = record;
        cloudKitLocation[usernameKey] = newUsername;
        
        [[LocationController publicDatabase] saveRecord:cloudKitLocation completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"error saving locations with new username, %@", error);
            } else {
                NSLog(@"successfully saved user's locations with new username, %@", record);
            }
        }];
    };
    [[LocationController publicDatabase] addOperation:fetchOperation];
}



@end






