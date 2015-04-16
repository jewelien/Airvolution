//
//  Location.h
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CloudKit/CloudKit.h>


static NSString * const locationRecordKey = @"location";
static NSString * const identifierKey = @"identifier";
static NSString * const nameKey = @"name";
static NSString * const locationKey = @"coordinates";
static NSString * const streetKey = @"street";
static NSString * const cityKey = @"city";
static NSString * const stateKey = @"state";
static NSString * const zipKey = @"zip";
//static NSString * const cityStateZipKey = @"cityStateZip";
static NSString * const countryKey = @"country";

static NSString * const creationDateKey = @"creationDate";
static NSString * const recordIDKey = @"recordID";

static NSString * const userKey = @"creatorUserRecordID";
static NSString * const usernameKey = @"username";
static NSString * const userRecordIDRefKey = @"userRecordID";



@interface Location : NSObject

@property (nonatomic, strong) NSString *locationName;
@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zip;
//@property (nonatomic, strong) NSString *cityStateZip;
@property (nonatomic, strong) NSString *country;


@property (nonatomic, strong) NSString *creationDate;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *userRecordName;
@property (nonatomic, strong) CKRecordID *recordID;
@property (nonatomic, strong) NSString *username;


- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end
