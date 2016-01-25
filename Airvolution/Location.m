//
//  Location.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "Location.h"
#import "UserController.h"

@implementation Location

@dynamic locationName;
@dynamic street;
@dynamic city;
@dynamic state;
@dynamic zip;
@dynamic country;
@dynamic creationDate;
@dynamic identifier;
@dynamic locationNotes;
@dynamic userRecordName;
@dynamic location;
@dynamic recordName;
@dynamic user;

//@dynamic userRecordID;
//@dynamic username;
//@dynamic recordID;

@synthesize creationDateString;

-(NSString *)creationDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *string = [formatter stringFromDate:self.creationDate];
    return string;
}

-(User *)user{
    User* locationUser = [[UserController sharedInstance]findUserInCoreDataWithUserUserRecordName:self.userRecordName];
    return locationUser;
}

//-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
//    self = [super init];
//    if (self) {
//        self.locationName = dictionary[nameKey];
//        self.location = dictionary[locationKey];
//        self.street = dictionary[streetKey];
//        self.city = dictionary[cityKey];
//        self.state = dictionary[stateKey];
//        self.zip = dictionary[zipKey];
////        self.cityStateZip = dictionary[cityStateZipKey];
//        self.country = dictionary[countryKey];
//        self.identifier = dictionary[identifierKey];
//        [self formatNSDate:dictionary[creationDateKey]];
//        self.creationDate = dictionary[creationDateKey];
//        [self retrieveUserRecordNamefromUserRecordID:dictionary[userKey]];
//        self.recordID = dictionary[recordIDKey];
//        self.username = dictionary[usernameKey];
//        self.locationNotes = dictionary[notesKey];
//    }
//    return self;
//}
//
//- (void)formatNSDate:(NSDate *)date {
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    self.creationDateString = [dateFormatter stringFromDate:date];
//}
//
//- (void)retrieveUserRecordNamefromUserRecordID:(CKRecordID *)recordID {
//    self.userRecordName = recordID.recordName;
//}

@end
