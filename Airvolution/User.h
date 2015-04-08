//
//  User.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) NSInteger points;
@property (nonatomic, strong) CKAsset *image;
@property (nonatomic, strong) CKRecordID *userRecordID;

-(void)initWithDictionary:(NSDictionary *)dictionary;

@end
