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
#import "UIColor+Color.h"
#import "AppDelegate.h"
@import GoogleMobileAds;

static NSString *const LocationCellKey = @"locationCell";
static NSString *const UserInfoCellKey = @"userInfoCell";

NSString *adUnitIDtest = @"ca-app-pub-3940256099942544/2934735716";
NSString *adUnitIDBannerAdOnShared = @"ca-app-pub-3012240931853239/1747853102";

@implementation ProfileTableViewDatasource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[LocationCustomCell class] forCellReuseIdentifier:LocationCellKey];
    tableView.delegate = self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [UserController sharedInstance].currentUser.locations.count;
            break;
            
        default: return 1;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    }
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Location *selectedLocation =[[UserController sharedInstance].currentUser sortedLocations][indexPath.row];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.tabBarController.selectedViewController = delegate.tabBarController.viewControllers[0];
    [[NSNotificationCenter defaultCenter]postNotificationName:goToSavedLocationNotificationKey object:selectedLocation];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return true;
    }
    return false;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LocationCustomCell *locationCell = [tableView dequeueReusableCellWithIdentifier:LocationCellKey];
        NSArray *usersSharedLocations = [[UserController sharedInstance].currentUser sortedLocations];
        if (usersSharedLocations.count > indexPath.row) {
            Location *location = usersSharedLocations[indexPath.row];
            locationCell.nameLabel.text = location.locationName;
            locationCell.dateLabel.text = [NSString stringWithFormat:@"added: %@",location.creationDateString];
            locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", location.street, location.city, location.state, location.zip];
            return locationCell;
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor lightGrayColor];
    CGRect rect = CGRectMake(0, 0, 320, 50);
    GADBannerView *bannerView = [[GADBannerView alloc]initWithFrame:rect];
    bannerView.backgroundColor = [UIColor blackColor];
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    bannerView.center = CGPointMake(screenWidth/2, bannerView.center.y);
    ProfileViewController *profileVC = [[ProfileViewController alloc]init];
    bannerView.adUnitID = adUnitIDtest;
    bannerView.rootViewController = profileVC;
    [bannerView loadRequest:[GADRequest request]];
    [cell addSubview:bannerView];
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"destructive");
        Location *location = [UserController sharedInstance].currentUser.sortedLocations[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:deleteLocationNotificationKey object:location.recordName];
    }
} 

@end
