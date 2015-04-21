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


+ (CKDatabase*)publicDatabase {
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    return database;
}

- (void)confirmLocation:(Location *)location WithUsername:(NSString *)username andNotes:(NSString *)notes
{
        
        CKReference *locationReference = [[CKReference alloc] initWithRecordID:location.recordID action:CKReferenceActionNone];
    CKReference *confirmerReference = [[CKReference alloc] initWithRecordID:[UserController sharedInstance].currentUserRecordID action:CKReferenceActionNone];
    
        CKRecord *cloudKitConfirmLocation = [[CKRecord alloc] initWithRecordType:ConfirmLocationTypeKey];
        cloudKitConfirmLocation[ConfirmIdentifierKey] = [[NSUUID UUID] UUIDString];
        cloudKitConfirmLocation[ConfirmedUsernameKey] = username;
        cloudKitConfirmLocation[ConfirmedNotesKey] = notes;
        cloudKitConfirmLocation[LocationReferenceKey] = locationReference;
        cloudKitConfirmLocation[ConfirmerReferenceKey] = confirmerReference;

    
        if (![UserController sharedInstance].currentUser.username) {
            NSLog(@"currentUser.username %@", [UserController sharedInstance].currentUser.username);
            NSString *currentUserRecordName = [UserController sharedInstance].currentUserRecordName;
            NSString *defaultUsername = [currentUserRecordName substringFromIndex:[currentUserRecordName length] - 12];
            cloudKitConfirmLocation[ConfirmedUsernameKey] = defaultUsername;
        } else {
            cloudKitConfirmLocation[usernameKey] = [UserController sharedInstance]. currentUser.username;
        }
        
        [[ConfirmLocationController publicDatabase] saveRecord:cloudKitConfirmLocation completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                NSLog(@"Location saved to CloudKit");
                NSLog(@"record saved: %@", record);
//                //            NSLog(@"IDENTIFIER %@", cloudKitLocation[identifierKey]);
//                [self loadLocationsAfterSavingLocationIdentifier:cloudKitLocation[identifierKey]];
                
            } else {
                NSLog(@"NOT saved to CloudKit");
//                [[NSNotificationCenter defaultCenter] postNotificationName:newLocationSaveFailedNotificationKey object:nil];
            }
        }];
    
}

- (void)fetchConfirmations {
    
}


@end
