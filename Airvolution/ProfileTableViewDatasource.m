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
#import "LocationCustomCell.h"
#import "LocationController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"

#import "AppDelegate.h"

static NSString *const LocationCellKey = @"locationCell";
static NSString *const UserInfoCellKey = @"userInfoCell";

@implementation ProfileTableViewDatasource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[LocationCustomCell class] forCellReuseIdentifier:LocationCellKey];
    tableView.delegate = self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"total shared: %lu", (unsigned long)[UserController sharedInstance].currentUser.locations.count];
}

- (void)filterSharedLocationsTapped {
    [[NSNotificationCenter defaultCenter] postNotificationName:editSortNotificationKey object:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UserController sharedInstance].currentUser.locations.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
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
    LocationCustomCell *locationCell = [tableView dequeueReusableCellWithIdentifier:LocationCellKey];
    NSArray *usersSharedLocations = [[UserController sharedInstance].currentUser sortedLocations];
    if (usersSharedLocations.count > indexPath.row) {
        Location *location = usersSharedLocations[indexPath.row];
        locationCell.nameLabel.text = location.locationName;
        locationCell.dateLabel.text = [NSString stringWithFormat:@"added: %@",location.creationDateString];
        locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", location.street, location.city, location.state, location.zip];
        //locationCell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", location.street, location.cityStateZip];
    }
    return locationCell;
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"destructive");

        Location *location = [UserController sharedInstance].currentUser.sortedLocations[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:deleteLocationNotificationKey object:location.recordName];
    }
} 

@end
