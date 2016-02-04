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
@dynamic cost;

@synthesize creationDateString;
@synthesize costString;

-(NSString *)creationDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *string = [formatter stringFromDate:self.creationDate];
    return string;
}

-(NSString *)costString {
    if (self.cost > 0) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *stringResult = [formatter stringFromNumber:[NSNumber numberWithDouble:self.cost]];
        return stringResult;
    }
    return @"FREE";
}

-(User *)user{
    User* locationUser = [[UserController sharedInstance]findUserInCoreDataWithUserUserRecordName:self.userRecordName];
    return locationUser;
}

@end
