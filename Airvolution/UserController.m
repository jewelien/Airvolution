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

- (void)initialLoad:(BOOL)isInitialLoad {
    if (isInitialLoad || (!isInitialLoad && [LocationController sharedInstance].locations.count == 0)) {
        [self fetchUserRecordIDWithCompletion:^(NSString *userRecordName) {
            [[LocationController sharedInstance]loadLocationsFromCloudKitWithCompletion:^(NSArray *array) {
                [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
                    });
                }];
            }];
        }];
    } else {
        [[UserController sharedInstance]fetchUserRecordIDWithCompletion:^(NSString *userRecordName) {
            [[UserController sharedInstance]findCurrentUser];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:updateMapKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateProfileKey object:nil];
            });
        }];
    }
}

#pragma mark - Finding User's iCloud
- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion {
    [[CKContainer defaultContainer]
//    [[CKContainer containerWithIdentifier:@"iCloud.com.julienguanzon.Airvolution"]
     fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        if (recordID) {
            [[LocationController sharedInstance] subscribe];
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

- (void)retrieveAllUsersWithCompletion:(void (^)(NSArray *allUsers))completion
{
    //"Can't query system types", CloudKit doesn't let you query User records ("Users" record type in CKDashboard). Can only pull user info with recordID. 
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
                User *existingUser = [self findUserInCoreDataWithUserUserRecordName:recordID.recordName];
                if (!existingUser) {
                    [self saveUserToCoreData:userDictionary];
                }
            }

//            NSLog(@"RETRIEVED ALL USERS %@", self.allUsers);
            [self findCurrentUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:AllUsersFetchNotificationKey object:nil];
            completion(self.allUsers);
        } else {
            NSLog(@"error retrieving all users, %@", operationError);
        }

    };
    
    [[UserController publicDatabase] addOperation:fetchOperation];
}

-(void)saveUserToCoreData:(NSDictionary*)userInfo {
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
    user.points = userInfo[PointsKey];
    user.identifier = userInfo[IdentifierKey];
    user.username = userInfo[UsernameKey];
    CKAsset *asset = userInfo[ImageKey];
    user.profileImage = [[UIImage alloc]initWithContentsOfFile:asset.fileURL.path];
    CKRecordID *recordID = userInfo[RecordIDKey];
    user.recordName = recordID.recordName;
    user.filter = DescendingSort;
    if (![user isInserted]) {
        [[Stack sharedInstance].managedObjectContext insertObject:user];
    }
    [user.managedObjectContext refreshObject:user mergeChanges:YES];
    [self saveToCoreData];
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
//    NSLog(@"self.currentUser == %@", self.currentUser);
    [self checkUsername];
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

#pragma mark fetch CoreData
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

-(NSArray *)allUsersRecordNames {
    NSMutableSet *recordNamesSet = [[NSMutableSet alloc] init];
    for (Location *location in [LocationController sharedInstance].locations) {
        if (![recordNamesSet containsObject:location.userRecordName]) {
            [recordNamesSet addObject:location.userRecordName];
        }
    }
    return [recordNamesSet allObjects];
}
#pragma mark update Profile
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
