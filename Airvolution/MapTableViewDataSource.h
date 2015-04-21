//
//  MapTableViewDataSource.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/15/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


static NSString * const confirmNotificationKey = @"confirmPressed";


@interface MapTableViewDataSource : NSObject <UITableViewDataSource>

- (void)registerTableView:(UITableView *)tableView ;

@end
