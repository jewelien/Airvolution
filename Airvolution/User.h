//
//  User.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

static NSString *const UserRecordTypeKey = @"User";
static NSString *const UserIdentifierKey = @"identifier";
static NSString *const UsernameKey = @"username";
static NSString *const PointsKey = @"points";

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *points;
@property (nonatomic, strong) CKAsset *image;
@property (nonatomic, strong) CKRecordID *userRecordID;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
