//
//  ProfileTableViewDatasource.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString * const editProfileNotificationKey = @"edit profile tapped";
static NSString * const deleteLocationNotificationKey = @"delete location tapped";
static NSString * const editSortNotificationKey = @"edit sort tapped";
static NSString * const goToLocationNotificationKey = @"goToLocation";


@interface ProfileTableViewDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)registerTableView:(UITableView *)tableView;

@end
