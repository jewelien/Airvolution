//
//  ConfirmLocationController.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/20/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "Location.h"

static NSString * const confirmLocationCompleteNotification = @"location confirmed";
static NSString * const confirmLocationFailedNotification = @"location not confirmed";


static NSString * const ConfirmLocationTypeKey = @"ConfirmLocation";
static NSString * const ConfirmedUsernameKey = @"confirmedByUsername";
static NSString * const ConfirmedNotesKey = @"notes";
static NSString * const ConfirmIdentifierKey = @"identifier";
static NSString * const LocationReferenceKey = @"locationRecordID";
static NSString * const ConfirmerReferenceKey = @"confirmedByRecordID";


@interface ConfirmLocationController : NSObject

@property (nonatomic, strong) NSString *confirmUsername;
@property (nonatomic, strong) NSString *confirmNotes;
@property (nonatomic, strong) NSString *confirmedDate;
@property (nonatomic, strong) NSString *confirmIdentifier;
@property (nonatomic, strong) CKRecordID *locationRecordID;
@property (nonatomic, strong) CKRecordID *confirmedByRecordID;

+ (ConfirmLocationController *)sharedInstance;
- (void)confirmLocation:(Location *)location withNotes:(NSString *)notes;
@end
