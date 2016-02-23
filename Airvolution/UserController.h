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

static NSString * const updateProfileKey = @"users shared locations updated";
static NSString * const NotLoggedIniCloudNotificationKey = @"iCloud user not found";
static NSString * const UsernameSavedNotificationKey = @"new username saved";
static NSString * const UserImageNotificationKey = @"profile image saved";
static NSString * const AscendingSort = @"acendingDate";
static NSString * const DescendingSort = @"descendingDate";
static NSString * const AlphabeticalSort = @"alphabetical";


@interface UserController : NSObject

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSArray *allUsersRecordNames;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) CKRecordID *currentUserRecordID; //User Record Type
@property (nonatomic, strong) NSString *currentUserRecordName; //User Record Type

+ (UserController *)sharedInstance;
- (void)initialLoad:(BOOL)isInitialLoad;
- (void)fetchUserRecordIDWithCompletion:(void (^)(NSString *userRecordName))completion;
- (User *)findUserInCoreDataWithUserUserRecordName:(NSString*)recordName;
- (NSArray*)fetchLocationsForUser:(User*)user;
- (void)saveLocationFilter:(NSString*)filter;
@end
