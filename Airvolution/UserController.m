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
    //update profile my shared locations
    [[NSNotificationCenter defaultCenter] postNotificationName:UsersLocationsNotificationKey object:nil];
    [self checkUserinCloudKitUserList];
}


+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}

-(void)checkUserinCloudKitUserList {
    NSLog(@"checking if user is in CK UserList");
    //return an array of all User's record names only to use when fetching "Users" in cloudkit.
    //1. FETCH ALL USER RECORD NAMES FROM CLOUDKIT USER LIST --- STORE IN LOCAL ARRAY
    //2. CHECK THIS ARRAY IF CURRENT USER RECORD NAME IS IN THE LIST.
    //3. if YES - continue to step 5.
    //4. if NO. add user to cloudKit userList  -- do step 1, continue to step 5.
    //5. Continue to fetch all users from users. using the userrecordnames local array.
    
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
                    [self retrieveAllUsers];
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
                NSLog(@"self.allUsersRecordNames %@", self.allUsersRecordNames);
                [self retrieveAllUsers];
            } else {
                NSLog(@"user is not yet in cloudkit");
                [self checkUserInUserListAfterSave];
            }
        }
    }];
    
}


- (void)retrieveAllUsers {

    NSMutableArray *recordIDs = [[NSMutableArray alloc] init];
    for (NSString *recordName in self.allUsersRecordNames) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
        [recordIDs addObject:recordID];
    }
    
    NSLog(@"retrieving all users ");
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];
    
    NSMutableArray *allUsersTempArray = [[NSMutableArray alloc] init];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
//        NSLog(@"%@", recordsByRecordID);
        for (CKRecordID *recordID in recordsByRecordID) {
            User *user = [[User alloc] initWithDictionary:recordsByRecordID[recordID]];
            [allUsersTempArray addObject:user];
        }
        self.allUsers = allUsersTempArray;
        NSLog(@"RETRIEVED ALL USERS %@", self.allUsers);
        [self findCurrentUser];
    };
    
    [[UserController publicDatabase] addOperation:fetchOperation];
}


- (void)findCurrentUser{
    for (User *user in self.allUsers) {
        if ([user.recordName isEqualToString:self.currentUserRecordName]) {
            self.currentUser = user;
            [self updateUserPoints];
        } else {
            NSLog(@"looking for user in all Users array");
        }
    }
    NSLog(@"self.currentUser == %@", self.currentUser);
}


-(void)updateUserPoints {
    NSString *username = [self.currentUserRecordName substringFromIndex:[self.currentUserRecordName length] - 12];
    NSInteger integer = self.usersSharedLocations.count * 25 ;
    NSString *pointsString = [@(integer)stringValue];
    
    if ([self.currentUser.username isEqualToString:@""]) {
        CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
        fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
            
            CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
            
            cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
            cloudKitUser[UsernameKey] = username;
            
            [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
                if (!error) {
                    NSLog(@"saved default username %@", record);
                    [self retrieveAllUsers];
                }
            }];
            
        };
        
        [[UserController publicDatabase] addOperation:fetchOperation];
    }

    
//    if (![self.currentUser.points isEqualToString:pointsString] || [self.currentUser.username isEqualToString:@""]) {
    if (![self.currentUser.points isEqualToString:pointsString]) {

        CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
        fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
            CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
            
            cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
            cloudKitUser[PointsKey] = pointsString;
            
            [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
                if (!error) {
                    NSLog(@"saved new points %@", record);
                    [self retrieveAllUsers];
                }
            }];

        };

        [[UserController publicDatabase] addOperation:fetchOperation];
        
    } else {
        NSLog(@"points matching no need to update");
        [self pointsUpdated];
    }
}

- (void)pointsUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:UserPointsNotificationKey object:nil];
}

-(void)updateUsernameWith:(NSString *)newUsername {
    CKFetchRecordsOperation *fetchOperation = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        
        CKRecord *cloudKitUser = recordsByRecordID[[recordsByRecordID allKeys].firstObject];
        
        cloudKitUser[IdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitUser[UsernameKey] = newUsername;
        
        [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"saved new username %@", record);
                [self retrieveAllUsers];
                [[NSNotificationCenter defaultCenter] postNotificationName:UsernameSavedNotificationKey object:nil];
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
                [self retrieveAllUsers];
                [[NSNotificationCenter defaultCenter] postNotificationName:UserImageNotificationKey object:nil];
            }
        }];
        
    };
    [[UserController publicDatabase] addOperation:fetchOperation];
    
}


@end
