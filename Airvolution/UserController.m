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
        self.userRecordID = recordID;
        self.userRecordName = recordID.recordName;
        NSLog(@"USER RECORD NAME Fetched %@", self.userRecordName);
        completion(self.userRecordName);
    }];

}

-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray {
    NSLog(@"array passed in %@", allLocationsArray);
    NSMutableArray *tempArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        NSLog(@"loca record NAME %@", location.userRecordName);
        NSLog(@"self record nAME %@", self.userRecordName);
        if ([location.userRecordName isEqualToString: self.userRecordName]) {
            NSLog(@"loc matched, %@", location);
            [tempArray addObject:location];
        } else {
            NSLog(@"no saved locations for this user");
        }
        NSLog(@"temp array %@", tempArray);
        self.usersSharedLocations = tempArray;
    }
    
//    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creatorUserRecordID == %@", ID];
//
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Location" predicate:predicate];
//    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
//        if (error) {
//            NSLog(@"fetch user's saved locations failed");
//        } else {
//            NSLog(@"fetched user's saved locations successfully");
//            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
//            for (NSDictionary *dictionary in results) {
//                Location *location = [[Location alloc] initWithDictionary:dictionary];
//                [tempArray addObject:location];
//            }
//            NSLog(@"user's saved locations results : %@", tempArray);
//            self.usersSharedLocations = tempArray;
////            [[NSNotificationCenter defaultCenter] postNotificationName:@"locationsFetched" object:nil];
//        }
//    }];

}




@end
