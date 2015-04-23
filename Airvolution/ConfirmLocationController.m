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

- (void)confirmLocation:(Location *)location withNotes:(NSString *)notes
{
        
        CKReference *locationReference = [[CKReference alloc] initWithRecordID:location.recordID action:CKReferenceActionNone];
    CKReference *confirmerReference = [[CKReference alloc] initWithRecordID:[UserController sharedInstance].currentUserRecordID action:CKReferenceActionNone];
    
        CKRecord *cloudKitConfirmLocation = [[CKRecord alloc] initWithRecordType:ConfirmLocationTypeKey];
        cloudKitConfirmLocation[ConfirmIdentifierKey] = [[NSUUID UUID] UUIDString];
//        cloudKitConfirmLocation[ConfirmedUsernameKey] = username;
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
                NSLog(@"confirm locations record saved: %@", record);
//                //            NSLog(@"IDENTIFIER %@", cloudKitLocation[identifierKey]);
//                [self loadLocationsAfterSavingLocationIdentifier:cloudKitLocation[identifierKey]];
                
                
            } else {
                NSLog(@"confirm location NOT saved to CloudKit");
                [[NSNotificationCenter defaultCenter] postNotificationName:confirmLocationFailedNotification object:nil];
            }
        }];
    
}

- (void)fetchConfirmations {
    
}


@end
