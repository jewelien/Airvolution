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
        }
        
    }];

}

-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray {
    NSMutableArray *tempArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        if ([location.userRecordName isEqualToString: self.userRecordName]) {
            [tempArray addObject:location];
            NSLog(@"user's locations found");
        } else {
            NSLog(@"no locations found for user");
        }
        self.usersSharedLocations = tempArray;
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
                [self saveUsernametoCloudKitWithUserRecordName:self.userRecordName];
            } else {
                NSLog(@"successfully retrieved all users, total %ld", results.count);
                for (NSDictionary *dictionary in results) {
                    User *user = [[User alloc] initWithDictionary:dictionary];
                    [array addObject:user];
                }
                self.allUsers = array;
                NSLog(@"All Users %@", self.allUsers);
                [self checkUserInCloudkit];
            }
        }
    }];
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
    }
    
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
