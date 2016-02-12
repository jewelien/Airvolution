//
//  User.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "User.h"
#import "UserController.h"

@implementation User

//@dynamic recordID;
@dynamic recordName;
@dynamic identifier;
@dynamic points;
@dynamic username;
@dynamic profileImage;
@dynamic locations;
@dynamic filter;

- (NSArray *)sortedLocations {
    NSSortDescriptor *sortDescriptor = [self sortLocationsForFilter:self.filter];
    NSArray *sortedArray = [self.locations sortedArrayUsingDescriptors:@[ sortDescriptor ]];
    return sortedArray;
}

- (NSSortDescriptor*)sortLocationsForFilter:(NSString*)filter {
    if ([filter isEqualToString:AscendingSort]) {
        return [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    } else if ([filter isEqualToString:DescendingSort]) {
        return [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    } else if ([filter isEqualToString:AlphabeticalSort]) {
        return [[NSSortDescriptor alloc] initWithKey:@"locationName" ascending:YES];
    } else {
        return [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    }
}

-(NSSet *)locations{
    NSArray *array = [[UserController sharedInstance] fetchLocationsForUser:self];
    return [NSSet setWithArray: array];
}
-(NSString *)points{
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.locations.count];
}


/*
 "<CKRecordID: 0x7fb62060a970; _c835c6d554eafe238933b65a1a9dd94d:(_defaultZone:__defaultOwner__)>" =
 "<CKRecord: 0x7fb61ec82710;
 recordType=Users,
 recordID=_c835c6d554eafe238933b65a1a9dd94d:(_defaultZone:__defaultOwner__),
 recordChangeTag=i7rxe5ce, values={\n
 identifier = \"3E7837F6-C23C-44B2-89E8-5D9DF9AB061E\";\n
 points = 50;\n
 username = \"_c835c6d554eafe238933b65a1a9dd94d\";\n}>";
 */


@end
