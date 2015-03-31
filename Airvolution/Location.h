//
//  Location.h
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


static NSString * const locationRecordKey = @"location";
static NSString * const nameKey = @"name";
static NSString * const locationKey = @"coordinates";
static NSString * const locationIdentifierKey = @"identifier";


@interface Location : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic) CLLocation *location;

@end
