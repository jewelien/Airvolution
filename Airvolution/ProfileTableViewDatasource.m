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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.rowHeight = 0;
    
    switch (indexPath.section) {
        case 0:
            tableView.rowHeight = 80;
            break;
        default: tableView.rowHeight = 50;
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
            userCell.pointsLabel.text = [NSString stringWithFormat:@"Points: %@", currentUser.points];
            break;
        default:
            cell = locationCell;
            if ([UserController sharedInstance].usersSharedLocations.count > indexPath.row) {
                Location *location = [UserController sharedInstance].usersSharedLocations[indexPath.row];
                locationCell.nameLabel.text = location.locationName;
                locationCell.dateLabel.text = [NSString stringWithFormat:@"added: %@",location.creationDate];
                locationCell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", location.street, location.cityStateZip];
            }
            break;
    }

    
    return cell;
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
//    return NO;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rowAction;
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"swiped");
        [[NSNotificationCenter defaultCenter] postNotificationName:editProfileNotificationKey object:nil];
    }];
    editAction.backgroundColor = [UIColor orangeColor];
    
    
    switch (indexPath.section) {
        case 0:
            rowAction = @[editAction];
            break;
        default:
            break;
    }
    
    return rowAction;
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}






@end
