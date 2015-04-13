//
//  User.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "User.h"

@interface User ()
    @property (nonatomic, strong) CKAsset *image;
@end

@implementation User

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        self.recordID = dictionary[RecordIDKey];
        self.recordName = self.recordID.recordName;
        self.identifier = dictionary[IdentifierKey];
        self.points = dictionary[PointsKey];
        self.username = dictionary[UsernameKey];
        
        self.image = dictionary[ImageKey];
        self.profileImage = [UIImage imageWithContentsOfFile:self.image.fileURL.path];
        
    }
//    NSLog(@"%@, %@, %@, %@, %@", self.recordID, self.recordName, self.identifier, self.points, self.username);
    NSLog(@"profileimage %@", self.profileImage);
    return  self;
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
