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
    self.userRecordID = dictionary[creatorUserKey];
    self.userIdentifier = dictionary[UserIdentifierKey];
    [self retrieveUserRecordNamefromUserRecordID:dictionary[creatorUserKey]];
    }
    
    NSLog(@"POINTS %@", self.points);
    return  self;
}


- (void)retrieveUserRecordNamefromUserRecordID:(CKRecordID *)recordID {
    self.userRecordName = recordID.recordName;
    NSLog(@"self.userRecordName %@", self.userRecordName);

}

@end
