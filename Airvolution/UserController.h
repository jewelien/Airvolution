//
//  UserController.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "User.h"

@interface UserController : NSObject

//@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *usersSharedLocations;
@property (nonatomic, strong) CKRecordID *userRecordID;
@property (nonatomic, strong) NSString *userRecordName;

+ (UserController *)sharedInstance;


- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion;
-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray;
@end
