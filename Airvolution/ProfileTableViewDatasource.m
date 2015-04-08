//
//  ProfileTableViewDatasource.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/2/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "ProfileTableViewDatasource.h"
#import "UserController.h"
#import "User.h"
#import "Location.h"
#import "ProfileCustomCell.h"

static NSString *const CellKey = @"cell";
static NSString *const UserInfoCellKey = @"userInfoCell";

@implementation ProfileTableViewDatasource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellKey];
    [tableView registerClass:[ProfileCustomCell class] forCellReuseIdentifier:UserInfoCellKey];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle;
    switch (section) {
        case 0:
            headerTitle = @"";
            break;
        case 1:
            headerTitle = @"My Shared Locations";
            break;
//        default:
//            break;
    }
    return headerTitle;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
        case 1:
            numberOfRows = [UserController sharedInstance].usersSharedLocations.count;
            break;
//        default:
//            break;
    }
    
    return numberOfRows;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellKey];
    ProfileCustomCell *userCell = [tableView dequeueReusableCellWithIdentifier:UserInfoCellKey];
    
    
    switch (indexPath.section) {
        case 0:
            tableView.rowHeight = 80;
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            cell = userCell;
            break;
        default:
            tableView.rowHeight = 50;
            if (cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellKey];
            }
            if ([UserController sharedInstance].usersSharedLocations.count > indexPath.row) {
                Location *location = [UserController sharedInstance].usersSharedLocations[indexPath.row];
                cell.textLabel.text = location.locationName;
                cell.detailTextLabel.text = location.street;
            }
            break;
    }

    
    return cell;
}
@end
