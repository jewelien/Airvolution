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
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
        
        if (recordID) {
            self.userRecordID = recordID;
            self.userRecordName = recordID.recordName;
            NSLog(@"USER RECORD NAME Fetched %@", self.userRecordName);
            completion(self.userRecordName);
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CloudKitSaveFail" object:nil];
        }
        
    }];

}

-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray {
    NSMutableArray *tempArray = [NSMutableArray new];
    NSLog(@"locations array %@", [LocationController sharedInstance].locations);
    
    for (Location *location in [LocationController sharedInstance].locations) {
        
        if ([location.userRecordName isEqualToString: @"__defaultOwner__"]) {
            [tempArray addObject:location];
            NSLog(@"user's locations found");
        } else {
            NSLog(@"not user's location");
            NSLog(@"location.userRecordName, %@",location.userRecordName);
            NSLog(@"self.userRecordName %@", self.userRecordName);
        }
        self.usersSharedLocations = tempArray;
        NSLog(@"self.usersSharedLocations, %@", self.usersSharedLocations);
    }
    [self retrieveAllUsers];
}

+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}

- (void)retrieveAllUsers {
    NSLog(@"method called ");
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:UserRecordTypeKey predicate:predicate];
    [[UserController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"error retrieving all users with error %@", error);
        }
        else {
            if (results.count == 0) {
                NSLog(@"no users found when retrieving all users");
//                [self saveUsernametoCloudKitWithUserRecordName:self.userRecordName];
            } else {
                NSLog(@"successfully retrieved all users, total %ld", results.count);
                for (NSDictionary *dictionary in results) {
                    User *user = [[User alloc] initWithDictionary:dictionary];
                    [array addObject:user];
                }
                self.allUsers = array;
                NSLog(@"All Users %@", self.allUsers);
                [self findCurrentUser];
                [self checkUserInCloudkit];
            }
        }
    }];
}
- (void)findCurrentUser{
    for (User *user in self.allUsers) {
        if ([user.userRecordName isEqualToString:@"__defaultOwner__"]) {
            NSLog(@"current user found in all users %@", user.userRecordName);
            self.currentUser = user;
        } else {
            NSLog(@"current user not found in all users");
            NSLog(@"user.userRecordName %@", user.userRecordName);
        }
    }
    NSLog(@"self.currentUser == %@", self.currentUser);
}

- (void)checkUserInCloudkit {
    NSLog(@"checking User In Cloudkit");
    NSMutableArray *usernameArray = [NSMutableArray new];
    for (User *user in self.allUsers) {
        [usernameArray addObject:user.username];
    }
    NSLog(@"usernameARRAY %@", usernameArray);

    if (![usernameArray containsObject:self.userRecordName]) {
        NSLog(@"current user not found in cloudkit, saving now");
        [self saveUsernametoCloudKitWithUserRecordName:self.userRecordName];
    } else {
        NSLog(@"user is in cloudkit");
        NSLog(@"user Identifier %@", self.currentUser.userIdentifier);

        [self checkUserUpdate];
    }
    
}



-(void)checkUserUpdate{
    NSInteger integer = self.usersSharedLocations.count * 25 ;
    NSString *pointsString = [@(integer)stringValue];
    if (![self.currentUser.points isEqualToString:pointsString]) {
        NSLog(@"Points do not match, %@ : %@", self.currentUser.points, pointsString);

        NSLog(@"user Identifier %@", self.currentUser.userIdentifier);
        
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName: self.currentUser.userIdentifier];
        
        [[UserController publicDatabase] deleteRecordWithID:recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (error) {
                NSLog(@"Record ID not deleted with error, %@", error);
                NSLog(@"record iD not deleted %@", recordID);
                
            }else {
                NSLog(@"deleted recordID %@", recordID);
            }
        }];
        
    } else {
        NSLog(@"User points matches.");
    }
    
//        CKRecord *cloudKitUser = [[CKRecord alloc] initWithRecordType:UserRecordTypeKey];
//        cloudKitUser[UserIdentifierKey] = [[NSUUID UUID] UUIDString];
//        cloudKitUser[UsernameKey] = self.userRecordName;
//        cloudKitUser[PointsKey] = pointsString;
//        
//        CKModifyRecordsOperation *modifyOp = [[CKModifyRecordsOperation alloc]initWithRecordsToSave:@[cloudKitUser] recordIDsToDelete:nil];
//        
//        modifyOp.database = [UserController publicDatabase];
//        modifyOp.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
//            if (error) {
//                NSLog(@"[%@] Error pushing local data: %@", self.class, error);
//                NSLog(@"deletedRecordIDs %@", deletedRecordIDs);
//                NSLog(@"saved records %@", savedRecords);
//            } else {
//                NSLog(@"deleted /saved successfully");
//                NSLog(@"deletedRecordIDs %@", deletedRecordIDs);
//                NSLog(@"saved records %@", savedRecords);
//            }
//        };
//        [[UserController publicDatabase] addOperation:modifyOp];
    
}


-(void)saveUsernametoCloudKitWithUserRecordName:(NSString *)userRecordName {
    CKRecord *cloudKitUser = [[CKRecord alloc] initWithRecordType:UserRecordTypeKey];
    cloudKitUser[UserIdentifierKey] = [[NSUUID UUID] UUIDString];
    cloudKitUser[UsernameKey] = userRecordName;
    NSInteger integer = self.usersSharedLocations.count * 25 ;
    cloudKitUser[PointsKey] = [@(integer)stringValue];
    
    
    [[UserController publicDatabase] saveRecord:cloudKitUser completionHandler:^(CKRecord *record, NSError *error) {
        if (!error) {
            NSLog(@"User saved to CloudKit, %@", record);
        }
        else {
            NSLog(@"User not saved to CloudKit");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CloudKitSaveFail" object:nil];
        }
    }];
}

- (void)updateUser:(User *)user withRecordName:(NSString *)recordName {
//    
//    
//    if (dictionary[UsernameKey] != self.user.username) {
//        NSLog(@"username has changed");
//    } else {
//        NSLog(@"no changes to username");
//    }
//    
//    NSInteger integer = self.usersSharedLocations.count * 25;
//    NSString *pointsString = [@(integer)stringValue];
//    NSLog(@"%@", pointsString);
//    if (dictionary[PointsKey] !=  pointsString ) {
//        NSLog(@"points changed");
//    } else {
//        NSLog(@"no changes to points");
//    }
//    
    
}

@end
