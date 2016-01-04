//
//  User.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

static NSString *const UserListRecordTypeKey = @"UserList";
static NSString *const RecordNameKey = @"recordName";

static NSString *const RecordIDKey = @"recordID";
static NSString *const IdentifierKey = @"identifier";
static NSString *const PointsKey = @"points";
static NSString *const UsernameKey = @"username";
static NSString *const LocationFilterKey = @"locationFilter";

static NSString *const ImageKey = @"profileImage";

@interface User : NSObject

typedef NS_ENUM(NSInteger, LocationFilter) {
    dateAscending = 0,
    dateDescending = 1,
    distance = 2,
    name = 3,
};

@property (nonatomic, strong) CKRecordID *recordID;
@property (nonatomic, strong) NSString *recordName;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) NSString *username;
//@property (nonatomic, strong) NSString *locationFilterString;

@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic) enum LocationFilter filter;


-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
