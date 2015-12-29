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

static NSString * const removeLoadingLaunchScreenNotification = @"remove launch screen";

static NSString * const UsersLocationsNotificationKey = @"users shared locations updated";
static NSString * const NotLoggedIniCloudNotificationKey = @"iCloud user not found";
static NSString * const AllUsersFetchNotificationKey = @"all users fetched";

static NSString * const UserPointsNotificationKey = @"user points updated";
static NSString * const UsernameSavedNotificationKey = @"new username saved";
static NSString * const UserImageNotificationKey = @"profile image saved";



@interface UserController : NSObject

//@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *usersSharedLocations;
@property (nonatomic, strong) CKRecordID *currentUserRecordID; //User Record Type
@property (nonatomic, strong) NSString *currentUserRecordName; //User Record Type
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSArray *allUsersRecordNames;


+ (UserController *)sharedInstance;


- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion;
-(void)fetchUsersSavedLocationsFromArray:(NSArray *)allLocationsArray withCompletion:(void (^)(NSArray *usersLocations))completion;
-(void)updateUsernameWith:(NSString *)newUsername;
-(void)updateUserImageWithData:(NSData *)imageData;
-(void)checkUserinCloudKitUserList;
-(void)updateUserPoints;

@end
