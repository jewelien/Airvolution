//
//  User.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "User.h"


@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
    self.username = dictionary[UsernameKey];
    self.points = dictionary[PointsKey];
    }
    NSLog(@"POINTS %@", self.points);
    NSLog(@"dictionary points key %@", dictionary[PointsKey]);
    return  self;
}

@end
