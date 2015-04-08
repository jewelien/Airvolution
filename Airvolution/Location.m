//
//  Location.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "Location.h"

@implementation Location



-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.locationName = dictionary[nameKey];
        self.location = dictionary[locationKey];
        self.street = dictionary[streetKey];
        self.cityStateZip = dictionary[cityStateZipKey];
        self.country = dictionary[countryKey];
        [self formatNSDate:dictionary[creationDateKey]];
    }
    return self;
}

- (void)formatNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.creationDate = [dateFormatter stringFromDate:date];
}


@end
