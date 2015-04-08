//
//  ProfileTableViewDatasource.h
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProfileTableViewDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (void)registerTableView:(UITableView *)tableView;

@end
