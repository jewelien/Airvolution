//
//  UserController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "UserController.h"

@implementation UserController

+ (UserController *)sharedInstance {
    static UserController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [UserController new];
    });
    return sharedInstance;
}

- (void)fetchUserRecordID {
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
//        NSLog(@"record ID %@ ", recordID);
        [self fetchUsersSavedLocations:recordID];
    }];

}

-(void)fetchUsersSavedLocations:(CKRecordID *)ID {
    NSLog(@"%@", ID);
//    
////    CKReference* recordToMatch = [[CKReference alloc] initWithRecordID:ID action:CKReferenceActionNone];
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"createdBy == _cd5f8486186028ea08f86b6597489619"];
//    
////    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[ID]];
////    CKFetchRecordsOperation *fetchOperation2 = [CKFetchRecordsOperation fetchCurrentUserRecordOperation];
//    
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Users" predicate:predicate];
    
//    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];  ///working on this
    
//    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
//        NSLog(@"%@", results);
//    }];
//
    
//    [database fetchRecordWithID:ID completionHandler:^(CKRecord *record, NSError *error) {  //working on this
//        NSLog(@"%@", record);
//    }];
    
}

@end
