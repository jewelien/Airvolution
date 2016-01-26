//
//  UserController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "UserController.h"
#import "LocationController.h"
#import "Location.h"
#import "ProfileViewController.h"
#import "User.h"
#import "Stack.h"

@interface UserController ()
@end

@implementation UserController

+ (UserController *)sharedInstance {
    static UserController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [UserController new];
    });
    return sharedInstance;
}

+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}

- (void)initialLoad {
    [self fetchUserRecordIDWithCompletion:^(NSString *userRecordName) {
        [[LocationController sharedInstance]loadLocationsFromCloudKitWithCompletion:^(NSArray *array) {
            [self checkUserinCloudKitUserList];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
        }];
    }];
}

#pragma mark - Finding User's iCloud
- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion {
    [[CKContainer defaultContainer]
//    [[CKContainer containerWithIdentifier:@"iCloud.com.julienguanzon.Airvolution"]
     fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (recordID) {
            self.currentUserRecordID = recordID;
            self.currentUserRecordName = recordID.recordName;

            NSLog(@"USER RECORD NAME Fetched %@", self.currentUserRecordName);
            completion(self.currentUserRecordName);
        } else {
            NSLog(@"User not logged in to iCloud");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NotLoggedIniCloudNotificationKey object:nil];
            });
        }
    }];

}


-(void)checkUserinCloudKitUserList {
    NSLog(@"checking if user is in CK UserList");
    
    NSMutableArray *userListMutableArray = [[NSMutableArray alloc] init];

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:UserListRecordTypeKey predicate:predicate];
    
    [[UserController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"fetch CloudKit UserList failed, error %@", error);
        } else {
            
            if (results.count == 0) {
                NSLog(@"no users in user list");
                [self saveUserinCloudKitUserList];
            } else {
                for (CKRecord *record in results) {
                    if (record[RecordNameKey]) {
                        [userListMutableArray addObject:record[RecordNameKey]];
                    }
                }
                if ([userListMutableArray containsObject:self.currentUserRecordName]) {
                    NSLog(@"user is in cloudkit");
                    self.allUsersRecordNames = userListMutableArray;
                    NSLog(@"self.allUsersRecordNames %@", self.allUsersRecordNames);
                    if (self.allUsers.count == 0) {
                        [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
//                            [self updateUserPoints];
                        }];
                    }
                } else {
                    NSLog(@"user is not in cloudkit");
                    [self saveUserinCloudKitUserList];
                }
            }
        }
    }];
}

- (void)saveUserinCloudKitUserList {
    CKRecord *cloudKitUserList = [[CKRecord alloc] initWithRecordType:UserListRecordTypeKey];
    cloudKitUserList[RecordNameKey] = self.currentUserRecordName;
    
    [[UserController publicDatabase] saveRecord:cloudKitUserList completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            NSLog(@"record saved: %@", record);
            [self checkUserInUserListAfterSave];
        } else {
            NSLog(@"NOT saved to CloudKit");
        }
    }];
}

-(void)checkUserInUserListAfterSave {
    NSLog(@"checking user in CK UserList after save");
    NSMutableArray *userListMutableArray = [[NSMutableArray alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:UserListRecordTypeKey predicate:predicate];
    
    [[UserController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"fetch CloudKit UserList failed, error %@", error);
        } else {
            for (CKRecord *record in results) {
                if (record[RecordNameKey]) {
                    [userListMutableArray addObject:record[RecordNameKey]];
                }
            }
            if ([userListMutableArray containsObject:self.currentUserRecordName]) {
                NSLog(@"user is in cloudkit");
                self.allUsersRecordNames = userListMutableArray;
                [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
//                    [self updateUserPoints];
                }];
            } else {
                NSLog(@"user is not yet in cloudkit");
                [self checkUserInUserListAfterSave];
            }
        }
    }];
    
}


- (void)retrieveAllUsersWithCompletion:(void (^)(NSArray *allUsers))completion
{
    NSMutableArray *recordIDs = [[NSMutableArray alloc] init];
    for (NSString *recordName in self.allUsersRecordNames) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
        [recordIDs addObject:recordID];
    }
    
    NSLog(@"retrieving all users ");
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];
    
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        if (!operationError) {
            for (CKRecordID *recordID in recordsByRecordID) {
                NSDictionary *userDictionary = recordsByRecordID[recordID];
                User *user;
                User *existingUser = [self findUserInCoreDataWithUserUserRecordName:recordID.recordName];
                if (!existingUser) {
                    user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
                    user.points = userDictionary[PointsKey];
                    user.identifier = userDictionary[IdentifierKey];
                    user.username = userDictionary[UsernameKey];
                    CKAsset *asset = userDictionary[ImageKey];
                    user.profileImage = [[UIImage alloc]initWithContentsOfFile:asset.fileURL.path];
                    user.recordName = recordID.recordName;
                    user.filter = DescendingSort;
                    if (![user isInserted]) {
                        [[Stack sharedInstance].managedObjectContext insertObject:user];
                    }
                    [user.managedObjectContext refreshObject:user mergeChanges:YES];
                    [self saveToCoreData];
                }
            }

            NSLog(@"RETRIEVED ALL USERS %@", self.allUsers);
            [self findCurrentUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:AllUsersFetchNotificationKey object:nil];
            completion(self.allUsers);
        } else {
            NSLog(@"error retrieving all users, %@", operationError);
        }

    };
    
    [[UserController publicDatabase] addOperation:fetchOperation];

}

- (User *)findUserInCoreDataWithUserUserRecordName:(NSString*)recordName {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recordName == %@", recordName]];
    NSArray *array = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    return array.firstObject;
}

- (NSArray *)fetchLocationsForUser:(User *)user {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userRecordName == %@", user.recordName]];
    NSArray *array = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    return array;
}

- (NSArray *)allUsers {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSArray *array = [[Stack sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSLog(@"USERS COUNT = %ld", array.count);
    return array;
}


-(void)saveToCoreData {
//    [[Stack sharedInstance].managedObjectContext refreshAllObjects];
    [[Stack sharedInstance].managedObjectContext save:nil];
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


- (void)findCurrentUser {
    for (User *user in self.allUsers) {
        if ([user.recordName isEqualToString:self.currentUserRecordName]) {
            self.currentUser = user;
        } else {
            NSLog(@"looking for user in all Users array");
        }
    }
    NSLog(@"self.currentUser == %@", self.currentUser);
    [self checkUsername];
//    [self fetchUsersSavedLocationsFromArray:self.usersSharedLocations withCompletion:^(NSArray *usersLocations) {
//        //
//    }];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:removeLoadingLaunchScreenNotification object:nil];
//    });
}

-(void)checkUsername {
    //if user saved a blank username a default username will be assigned.
    if (!self.currentUser.username) {
//    if ([self.currentUser.username isEqualToString:@""]) {
        
        NSString *defaultUsername = [self.currentUserRecordName substringFromIndex:[self.currentUserRecordName length] - 12];
        
        CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
        fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
            
            CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
            
            cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
            cloudKitUser[usernameKey] = defaultUsername;
            
            [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
                if (!error) {
                    NSLog(@"saved defaultUsername %@", record);
                    [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
                        });
                        
                    }];
                } else {
                    NSLog(@"error updating username %@", error);
                }
            }];
            
        };
        
        [[UserController publicDatabase] addOperation:fetchOperation];

    } else {
//        NSLog(@"User has a username");
    }

}

-(void)updateUsernameWith:(NSString *)newUsername
{
    self.currentUser.username = newUsername;
    [self saveToCoreData];
    CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
        CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
        cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitUser[UsernameKey] = newUsername;
        
        [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"saved new username %@", record);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:UsernameSavedNotificationKey object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
                });
                [[LocationController sharedInstance]updateUsersSharedLocationsUsernameIfChanged:newUsername];
            } else {
                NSLog(@"Update username error, %@", error);
            }
        }];
        
    };
    [[UserController publicDatabase] addOperation:fetchOperation];
}

-(void)updateUserImageWithData:(NSData *)imageData
{
    self.currentUser.profileImage = [UIImage imageWithData:imageData];
    [self saveToCoreData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UserImageNotificationKey object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
    });
    
    NSURL *cachesDirectory =[[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *tempName = [[NSUUID UUID].UUIDString stringByAppendingString:@"jpeg"];
    
    NSURL *localURL = [cachesDirectory URLByAppendingPathComponent:tempName];
    [imageData writeToURL:localURL atomically:YES];
    NSLog(@"localURL %@", localURL);
    
    CKAsset *asset = [[CKAsset alloc] initWithFileURL:localURL];
    NSLog(@"asset %@", asset);
    
    
    CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
        CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
        
        cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitUser[ImageKey] = asset;
        
        [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"saved new profile image %@", record);
            } else {
                NSLog(@"Update image error: %@", error);
            }
        }];
        
    };
    [[UserController publicDatabase] addOperation:fetchOperation];
}

- (void)saveLocationFilter:(NSString*)filter {
    if ([filter isEqualToString:AscendingSort]) {
        self.currentUser.filter = AscendingSort;
    } else if ([filter isEqualToString:DescendingSort]) {
        self.currentUser.filter = DescendingSort;
    } else if ([filter isEqualToString:AlphabeticalSort]) {
        self.currentUser.filter = AlphabeticalSort;
    }
    [self saveToCoreData];
    [[NSNotificationCenter defaultCenter]postNotificationName:SortSavedKey object:nil];
}


@end
