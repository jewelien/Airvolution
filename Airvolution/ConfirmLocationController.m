//
//  ConfirmLocationController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/20/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "ConfirmLocationController.h"
#import "UserController.h"

@implementation ConfirmLocationController


+ (ConfirmLocationController *)sharedInstance {
    static ConfirmLocationController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ConfirmLocationController new];
    });
    return sharedInstance;
}

+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}

//fetch all confirmations check if user has already confirmed location. yes send an alert that user cannot confirm the same location more than once. if no save the confirmation.

//fetch confirmations only for the selected location to appear in tableview.

- (void)fetchConfirmations {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:ConfirmLocationTypeKey predicate:predicate];
    [[ConfirmLocationController publicDatabase] performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"fetch confirmations failed");
        } else {
            NSLog(@"fetch confirmations success, results %@", results);
        }
    }];
    
    
}


- (void)confirmLocation:(Location *)location withNotes:(NSString *)notes
{
        
        CKReference *locationReference = [[CKReference alloc] initWithRecordID:location.recordID action:CKReferenceActionNone];
    CKReference *confirmerReference = [[CKReference alloc] initWithRecordID:[UserController sharedInstance].currentUserRecordID action:CKReferenceActionNone];
    
        CKRecord *cloudKitConfirmLocation = [[CKRecord alloc] initWithRecordType:ConfirmLocationTypeKey];
        cloudKitConfirmLocation[ConfirmIdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitConfirmLocation[ConfirmedNotesKey] = notes;
        cloudKitConfirmLocation[LocationReferenceKey] = locationReference;
        cloudKitConfirmLocation[ConfirmerReferenceKey] = confirmerReference;

    
        if (![UserController sharedInstance].currentUser.username) {
            NSLog(@"currentUser.username %@", [UserController sharedInstance].currentUser.username);
            NSString *currentUserRecordName = [UserController sharedInstance].currentUserRecordName;
            NSString *defaultUsername = [currentUserRecordName substringFromIndex:[currentUserRecordName length] - 12];
            cloudKitConfirmLocation[ConfirmedUsernameKey] = defaultUsername;
        } else {
            cloudKitConfirmLocation[ConfirmedUsernameKey] = [UserController sharedInstance]. currentUser.username;
        }
        
        [[ConfirmLocationController publicDatabase] saveRecord:cloudKitConfirmLocation completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"Location saved to CloudKit");
                NSLog(@"confirm locations record saved: %@", record);
//                //            NSLog(@"IDENTIFIER %@", cloudKitLocation[identifierKey]);
//                [self loadLocationsAfterSavingLocationIdentifier:cloudKitLocation[identifierKey]];
                [self fetchConfirmations];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:confirmLocationCompleteNotification object:nil];
                });
                
            } else {
                NSLog(@"confirm location NOT saved to CloudKit");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:confirmLocationFailedNotification object:nil];
                });
            }
        }];
    
}




@end
