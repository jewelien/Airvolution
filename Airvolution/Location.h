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
#import <CoreData/CoreData.h>
#import "User.h"

static NSString * const locationRecordKey = @"location";
static NSString * const identifierKey = @"identifier";
static NSString * const nameKey = @"name";
static NSString * const locationKey = @"coordinates";
static NSString * const streetKey = @"street";
static NSString * const cityKey = @"city";
static NSString * const stateKey = @"state";
static NSString * const zipKey = @"zip";
static NSString * const countryKey = @"country";
static NSString * const creationDateKey = @"creationDate";
static NSString * const recordIDKey = @"recordID";
static NSString * const userKey = @"creatorUserRecordID";
static NSString * const usernameKey = @"username";
static NSString * const userRecordIDRefKey = @"userRecordID";
static NSString * const notesKey = @"notes";


@interface Location : NSManagedObject

@property (nonatomic, retain) NSString *locationName;
@property (nonatomic, retain) NSString *street;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, retain) NSString *zip;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *locationNotes;
@property (nonatomic) CLLocation *location;
@property (nonatomic, retain) NSString *userRecordName;
@property (nonatomic, retain) NSString *recordName;
@property (nonatomic, retain) User *user; //relationship

@property (nonatomic, retain) NSString *creationDateString;

@end
