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

#pragma mark - Finding User's iCloud

- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion {

    [[CKContainer containerWithIdentifier:@"iCloud.com.julienguanzon.Airvolution"] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
    
        if (recordID) {
            self.currentUserRecordID = recordID;
            self.currentUserRecordName = recordID.recordName;

            NSLog(@"USER RECORD NAME Fetched %@", self.currentUserRecordName);
            completion(self.currentUserRecordName);
        } else {
            NSLog(@"User not logged in to iCloud");
            [[NSNotificationCenter defaultCenter] postNotificationName:NotLoggedIniCloudNotificationKey object:nil];
        }
        
    }];

}

#pragma mark - Finding User's shared locations from all locations array

-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        
        if ([location.userRecordName isEqualToString: @"__defaultOwner__"]) {
            [tempArray addObject:location];
//            NSLog(@"user's locations found");
        } else {
//            NSLog(@"not user's location");
        }
    }
    self.usersSharedLocations = tempArray;
    NSLog(@"User has %ld locations", self.usersSharedLocations.count);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UsersLocationsNotificationKey object:nil];
    });
    
    [self checkUserinCloudKitUserList];
}


+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
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
                        [userListMutableArray addObject:record[RecordNameKey]];
                }
                if ([userListMutableArray containsObject:self.currentUserRecordName]) {
                    NSLog(@"user is in cloudkit");
                    self.allUsersRecordNames = userListMutableArray;
                    NSLog(@"self.allUsersRecordNames %@", self.allUsersRecordNames);
                    [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                        [self updateUserPoints];
                    }];
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
                [userListMutableArray addObject:record[RecordNameKey]];
            }
            if ([userListMutableArray containsObject:self.currentUserRecordName]) {
                NSLog(@"user is in cloudkit");
                self.allUsersRecordNames = userListMutableArray;
                [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                    [self updateUserPoints];
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
    
    NSMutableArray *allUsersTempArray = [[NSMutableArray alloc] init];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        if (!operationError) {
            for (CKRecordID *recordID in recordsByRecordID) {
                User *user = [[User alloc] initWithDictionary:recordsByRecordID[recordID]];
                [allUsersTempArray addObject:user];
            }
            self.allUsers = allUsersTempArray;
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


- (void)findCurrentUser{
    for (User *user in self.allUsers) {
        if ([user.recordName isEqualToString:self.currentUserRecordName]) {
            self.currentUser = user;
        } else {
            NSLog(@"looking for user in all Users array");
        }
    }
    NSLog(@"self.currentUser == %@", self.currentUser);
    [self checkUsername];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:removeLoadingLaunchScreenNotification object:nil];
    });
}

-(void)checkUsername {
    //if user saved a blank username a default username will be assigned.
    if ([self.currentUser.username isEqualToString:@""]) {
        
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
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserPointsNotificationKey object:nil];
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


-(void)updateUserPoints {
//    NSString *username = [self.currentUserRecordName substringFromIndex:[self.currentUserRecordName length] - 12];
    NSInteger integer = self.usersSharedLocations.count * 25 ;
    NSString *pointsString = [@(integer)stringValue];

    if (![self.currentUser.points isEqualToString:pointsString]) {

        CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
        fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
            CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
            
            cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
            cloudKitUser[PointsKey] = pointsString;
            
            [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
                if (!error) {
                    NSLog(@"saved new points %@", record);
                    [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:UserPointsNotificationKey object:nil];
                        });
                        
                    }];
                } else {
                    NSLog(@"error updating points error %@", error);
                }
            }];

        };

        [[UserController publicDatabase] addOperation:fetchOperation];
        
    } else {
        NSLog(@"points matching no need to update");
    }
}


-(void)updateUsernameWith:(NSString *)newUsername
{
    CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
        CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
        cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitUser[UsernameKey] = newUsername;
        
        [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"saved new username %@", record);
                [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:UsernameSavedNotificationKey object:nil];
                    });
                }];
                [[LocationController sharedInstance]updateUsersSharedLocationsUsernameIfChanged:newUsername];
            } else {
                NSLog(@"error saving new username");
            }
        }];
        
    };
    [[UserController publicDatabase] addOperation:fetchOperation];

}

-(void)updateUserImageWithData:(NSData *)imageData
{
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
                
                [self retrieveAllUsersWithCompletion:^(NSArray *allUsers) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:UserImageNotificationKey object:nil];

                    });
                    
                }];
            }
        }];
        
    };
    [[UserController publicDatabase] addOperation:fetchOperation];
}


@end
