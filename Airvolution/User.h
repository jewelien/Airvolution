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
#import <CoreData/CoreData.h>

static NSString *const UserListRecordTypeKey = @"UserList";
static NSString *const RecordNameKey = @"recordName";
static NSString *const RecordIDKey = @"recordID";
static NSString *const IdentifierKey = @"identifier";
static NSString *const PointsKey = @"points";
static NSString *const UsernameKey = @"username";
static NSString *const LocationFilterKey = @"locationFilter";
static NSString *const ImageKey = @"profileImage";


@interface User : NSManagedObject

//@property (nonatomic, retain) NSString *recordID;
@property (nonatomic, retain) NSString *recordName;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *points;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) UIImage *profileImage;
@property (nonatomic, retain) NSSet *locations; //relationship
@property (nonatomic, strong) NSString *filter;

- (NSArray *)sortedLocations;
//@property (nonatomic, strong) NSString *locationFilterString;

//-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
