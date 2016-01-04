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
#import "UserCustomCell.h"
#import "LocationCustomCell.h"
#import "LocationController.h"
#import "ProfileViewController.h"

static NSString *const CellKey = @"cell";
static NSString *const LocationCellKey = @"locationCell";
static NSString *const UserInfoCellKey = @"userInfoCell";

@implementation ProfileTableViewDatasource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellKey];
    [tableView registerClass:[LocationCustomCell class] forCellReuseIdentifier:LocationCellKey];
//    [tableView registerClass:[UserCustomCell class] forCellReuseIdentifier:UserInfoCellKey];
    tableView.delegate = self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle;
    switch (section) {
        case 1:
            headerTitle = @"My Shared Locations";
            break;
    }
    return headerTitle;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect frame = tableView.frame;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-40, 8, 30, 30)];
    addButton.titleLabel.text = @"+";
    [addButton setImage:[UIImage imageNamed:@"sort"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(filterSharedLocationsTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 200, 30)];
    title.text = @"MY SHARED LOCATIONS";
    title.textColor = [UIColor darkGrayColor];
    title.font = [UIFont systemFontOfSize:14];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView addSubview:title];
    [headerView addSubview:addButton];
    
    switch (section) {
        case 1:
            return headerView;
            break;
    }
    UIView* view = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, frame.size.width, 0.0f)];
    return view;
    
}

- (void)filterSharedLocationsTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:editSortNotificationKey object:nil];
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
    }
    
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.rowHeight = 0;
    
    switch (indexPath.section) {
        case 0:
            tableView.rowHeight = 80;
            break;
        default: tableView.rowHeight = 60;
            break;
    }
    
    return tableView.rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellKey];
    LocationCustomCell *locationCell = [tableView dequeueReusableCellWithIdentifier:LocationCellKey];
    UserCustomCell *userCell = [[UserCustomCell alloc] init];
    User *currentUser = [UserController sharedInstance].currentUser;
    
    switch (indexPath.section) {
        case 0:
//            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            cell = userCell;
//            userCell.usernameLabel.text = [[UserControll]];
            userCell.usernameLabel.text = currentUser.username;
            userCell.pointsLabel.text = [NSString stringWithFormat:@"total shared: %@", currentUser.points];
            userCell.viewForImage.image = currentUser.profileImage;
            [userCell.editButton addTarget:self action:@selector(editUser) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            cell = locationCell;
            NSArray *usersSharedLocations = [UserController sharedInstance].usersSharedLocations;
//            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
//            NSArray *sortedArray = [usersSharedLocations sortedArrayUsingDescriptors:@[sortDescriptor]];

            if (usersSharedLocations.count > indexPath.row) {
                Location *location = usersSharedLocations[indexPath.row];
                locationCell.nameLabel.text = location.locationName;
                locationCell.dateLabel.text = [NSString stringWithFormat:@"added: %@",location.creationDateString];
                locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", location.street, location.city, location.state, location.zip];
//                locationCell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", location.street, location.cityStateZip];
            }
            break;
    }

    return cell;
}

- (void)editUser {
    [[NSNotificationCenter defaultCenter] postNotificationName:editProfileNotificationKey object:nil];
}


-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL command;
    switch (indexPath.section) {
        case 1:
            command = YES;
            break;
        default:
            break; command = NO;
    }
    return command;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"destructive");
        Location *location = [UserController sharedInstance].usersSharedLocations[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:deleteLocationNotificationKey object:location.recordID];
    }
} 


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return NO;
            break;
            
        default: YES;
            break;
    }
    return YES;
}


@end
