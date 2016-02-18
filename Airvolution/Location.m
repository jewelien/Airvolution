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
@dynamic userRecordName;
@dynamic location;
@dynamic recordName;
@dynamic user;
@dynamic reports;

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

@end
