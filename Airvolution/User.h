//
//  User.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

static NSString *const UserListRecordTypeKey = @"UserList";
static NSString *const RecordNameKey = @"recordName";

static NSString *const RecordIDKey = @"recordID";
static NSString *const IdentifierKey = @"identifier";
static NSString *const PointsKey = @"points";
static NSString *const UsernameKey = @"username";

@interface User : NSObject

@property (nonatomic, strong) CKRecordID *recordID;
@property (nonatomic, strong) NSString *recordName;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *username;

//@property (nonatomic, strong) CKAsset *image;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
