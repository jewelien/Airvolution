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
#import "MapViewController.h"

#import "AppDelegate.h"

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
            numberOfRows = [UserController sharedInstance].currentUser.locations.count;
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
    Location *selectedLocation =[[UserController sharedInstance].currentUser sortedLocations][indexPath.row];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MapViewController *mapVC = delegate.tabBarController.viewControllers[0];
    delegate.tabBarController.selectedViewController = mapVC;
    [[NSNotificationCenter defaultCenter]postNotificationName:goToLocationNotificationKey object:selectedLocation];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellKey];
    LocationCustomCell *locationCell = [tableView dequeueReusableCellWithIdentifier:LocationCellKey];
    UserCustomCell *userCell = [[UserCustomCell alloc] init];
    User *currentUser = [UserController sharedInstance].currentUser;
    
    switch (indexPath.section) {
        case 0:
        {
//            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
            cell = userCell;
//            userCell.usernameLabel.text = [[UserControll]];
            userCell.usernameLabel.text = currentUser.username;
            userCell.pointsLabel.text = [NSString stringWithFormat:@"total shared: %@", currentUser.points];
            userCell.viewForImage.image = currentUser.profileImage;
            [userCell.editButton addTarget:self action:@selector(editUser) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default:
        {
            cell = locationCell;
//            NSArray *usersSharedLocations = [[UserController sharedInstance].currentUser.locations allObjects];
//            usersSharedLocations = [usersSharedLocations sortedArrayUsingDescriptors:@[[self sortLocationsForFilter:[UserController sharedInstance].currentUser.filter]]];
            NSArray *usersSharedLocations = [[UserController sharedInstance].currentUser sortedLocations];

            if (usersSharedLocations.count > indexPath.row) {
                Location *location = usersSharedLocations[indexPath.row];
                locationCell.nameLabel.text = location.locationName;
                locationCell.dateLabel.text = [NSString stringWithFormat:@"added: %@",location.creationDateString];
                locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", location.street, location.city, location.state, location.zip];
//                locationCell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", location.street, location.cityStateZip];
            }
            break;
        }
    }

    return cell;
}


- (NSSortDescriptor*)sortLocationsAscending {
    return [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
}
- (NSSortDescriptor*)sortLocationsDescending {
    return [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
}
- (NSSortDescriptor*)sortLocationsAlphabetical {
    return [[NSSortDescriptor alloc] initWithKey:@"locationName" ascending:YES];
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

        Location *location = [UserController sharedInstance].currentUser.sortedLocations[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:deleteLocationNotificationKey object:location.recordName];
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
