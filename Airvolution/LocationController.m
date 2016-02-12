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

#pragma mark save

-(void)saveLocationWithName:(NSString *)name
                   location:(CLLocation *)location
              streetAddress:(NSString *)street
                       city:(NSString *)city state:(NSString *)state zip:(NSString *)zip
                    country:(NSString *)country
                      notes:(NSString *)notes cost:(NSNumber*)cost
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
    cloudKitLocation[costKey] = cost;
    
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
                [self updateUI];
            });
        } else {
            NSLog(@"NOT saved to CloudKit");
            [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSaveFailedNotificationKey object:nil];
        }
    }];
}

#pragma mark load
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
    location.cost = [[record objectForKey:costKey] doubleValue];
    
    if (![location isInserted]) {
        [[Stack sharedInstance].managedObjectContext insertObject:location];
    }
    [[Stack sharedInstance].managedObjectContext refreshObject:location mergeChanges:YES];
    [self saveToCoreData];
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


- (void)updateUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
    });
}

#pragma mark subscription
-(void)subscribe {
    [[LocationController publicDatabase]fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"subsrtiptions fetched = %@", subscriptions);
            if (!subscriptions || subscriptions.count == 0) {
                [self setupSubscription];
            }
        } else {
            NSLog(@"Error fetching subscriptions - %@", error);
        }
    }];
}

-(void)setupSubscription{
    NSPredicate *truePredicate = [NSPredicate predicateWithValue:YES];
    CKSubscription *itemSubscription = [[CKSubscription alloc]initWithRecordType:locationRecordKey
                                                                       predicate:truePredicate
                                                                         options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate | CKSubscriptionOptionsFiresOnRecordDeletion];
    CKNotificationInfo *notification = [[CKNotificationInfo alloc]init];
    notification.shouldSendContentAvailable = YES;
    notification.desiredKeys = @[nameKey];
    itemSubscription.notificationInfo = notification;
    
    [self saveSubscription:itemSubscription];
}

-(void)saveSubscription:(CKSubscription *)subscriptionInfo {
    [[LocationController publicDatabase]saveSubscription:subscriptionInfo completionHandler:^(CKSubscription * _Nullable subscription, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Subsription saved = %@", subscription);
        } else {
            NSLog(@"Subscription save error = %@", error);
        }
    }];
}

-(void)didReceiveNotification:(NSDictionary*)notificationInfo {
    CKNotification *note = [CKNotification notificationFromRemoteNotificationDictionary:notificationInfo];
    if (![note isKindOfClass:[CKNotification class]]) {
        return;
    }
    CKQueryNotification *queryNote = (CKQueryNotification*)note;
    //    CKRecordID *recordID = [queryNote recordID];
    //    NSDictionary *recordFields = [queryNote recordFields];
    //    NSString *containterIdentifier = [note containerIdentifier];
    //    CKNotificationType noteType = [note notificationType];
    
    CKQueryNotificationReason reason = [queryNote queryNotificationReason];
    switch (reason) {
        case CKQueryNotificationReasonRecordCreated:
            [self saveLocationFromNotification:queryNote];
            break;
        case CKQueryNotificationReasonRecordDeleted:
            [self deleteLocationFromNotification:queryNote];
            break;
        default:
            break;
    }
}

- (void)saveLocationFromNotification:(CKQueryNotification*)queryNotification {
    [[LocationController publicDatabase]fetchRecordWithID:queryNotification.recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (!error) {
            [self saveLocationToCoreData:(NSDictionary*)record];
            [self updateUI];
        } else {
            NSLog(@"Error with remote notification: %@",error);
        }
    }];
}

-(void)deleteLocationFromNotification:(CKQueryNotification*)queryNotification{
    CKRecordID *recordID = [queryNotification recordID];
    Location *location = [self findLocationInCoreDataWithLocationIdentifier:recordID.recordName];
    [self deleteLocationInCoreData:location];
    if ([location.userRecordName isEqualToString:[UserController sharedInstance].currentUserRecordName]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:locationDeletedNotificationKey object:nil];
        });
    }
    [self updateUI];
}


#pragma mark delete
- (void)deleteLocationWithRecordName:(NSString*)recordName {
    CKRecordID *recordID = [[CKRecordID alloc]initWithRecordName:[NSString stringWithFormat:@"%@",recordName]];
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[recordID]];
    operation.savePolicy = CKRecordSaveAllKeys;
    operation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        if (!error) {
            //delete in CoreData
            Location *locationToDelete = [self findLocationInCoreDataWithLocationIdentifier:recordName];
            [self deleteLocationInCoreData:locationToDelete];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:locationDeletedNotificationKey object:nil];
                [self updateUI];
            });
        } else {
            NSLog(@"Error: %@",error);
        }

    };
    [[LocationController publicDatabase]addOperation:operation];
}
-(void)deleteLocationInCoreData:(Location*)location {
    NSManagedObject *object = [[Stack sharedInstance].managedObjectContext objectWithID:location.objectID];
    [[Stack sharedInstance].managedObjectContext deleteObject:object];
    [self saveToCoreData];
}

#pragma mark fetch
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
    NSLog(@"ALL LOCATIONS COUNT = %lu", (unsigned long)array.count);
    return array;
}

- (NSDictionary *)addressDictionaryForLocationWithCLLocation:(CLLocation *)location {
    Location *selectedLocation = [self findLocationMatchingLocation:location];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    if (selectedLocation.street) {
        [dictionary setValue:selectedLocation.street forKey:(__bridge NSString *)kABPersonAddressStreetKey];
    }
    if (selectedLocation.city) {
        [dictionary setValue:selectedLocation.city forKey:(__bridge NSString *)kABPersonAddressCityKey];
    }
    if (selectedLocation.state) {
        [dictionary setValue:selectedLocation.state forKey:(__bridge NSString *)kABPersonAddressStateKey];
    }
    if (selectedLocation.zip) {
        [dictionary setValue:selectedLocation.zip forKey:(__bridge NSString *)kABPersonAddressZIPKey];
    }
    if (selectedLocation.country) {
        [dictionary setValue:selectedLocation.country forKey:(__bridge NSString *)kABPersonAddressCountryKey];
    }
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

//directions alert
-(UIAlertController*)alertForDirectionsToPlacemark:(MKPlacemark*)placemark {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Directions" message:@"You will be taken to the maps app for directions." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [controller removeFromParentViewController];
    }];
    [controller addAction:cancelAction];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self goToMapsAppForDirectionsToPlacemark:placemark];
    }];
    [controller addAction: action];
    return controller;
}

-(void)goToMapsAppForDirectionsToPlacemark:(MKPlacemark*)placemark
{
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 10000, 10000);
    [MKMapItem openMapsWithItems:@[mapItem] launchOptions:[NSDictionary dictionaryWithObjectsAndKeys: [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey, [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}



@end






