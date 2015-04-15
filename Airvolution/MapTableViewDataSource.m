//
//  MapTableViewDataSource.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/15/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MapTableViewDataSource.h"
#import "LocationController.h"

@implementation MapTableViewDataSource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
//    UITableViewCell *nameCell = [[UITableViewCell alloc] init];
    UITableViewCell *nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UITableViewCell *locationCell = [[UITableViewCell alloc] init];
    UITableViewCell *backToMapCell = [[UITableViewCell alloc] init];
    UITableViewCell *directionsCell = [[UITableViewCell alloc] init];
    Location *selectedLocation = [LocationController sharedInstance].selectedLocation;

    if (indexPath.row == 0) {
        cell = nameCell;
//        nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
//        nameCell.backgroundColor = [UIColor lightGrayColor];
        nameCell.textLabel.text = selectedLocation.locationName;
        nameCell.textLabel.font = [UIFont systemFontOfSize:25];
        nameCell.textLabel.textAlignment = NSTextAlignmentCenter;
        nameCell.detailTextLabel.text = [NSString stringWithFormat:@"shared by: %@  on: %@", selectedLocation.username, selectedLocation.creationDate];
        nameCell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        nameCell.detailTextLabel.font = [UIFont italicSystemFontOfSize:10];
        NSLog(@"selectedlocation.username %@", selectedLocation.username);

    }
    if (indexPath.row == 1) {
//        locationCell.textLabel.text = [LocationController sharedInstance].selectedLocation.street;
        cell = locationCell;
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, locationCell.contentView.frame.size.width, 20)];
        [locationCell.contentView addSubview:addressLabel];
        addressLabel.text = @"address: ";
        addressLabel.font = [UIFont systemFontOfSize:12];
        addressLabel.textColor = [UIColor blueColor];
        
        UILabel *streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, locationCell.contentView.frame.size.width, 20)];
        [locationCell.contentView addSubview:streetLabel];
        streetLabel.text = selectedLocation.street;


        UILabel *cityStateZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, locationCell.contentView.frame.size.width, 20)];
        [locationCell.contentView addSubview:cityStateZipLabel];
        cityStateZipLabel.text = [NSString stringWithFormat:@"%@ %@ %@", selectedLocation.city, selectedLocation.state, selectedLocation.zip];

        UILabel *countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, locationCell.contentView.frame.size.width, 20)];
        [locationCell.contentView addSubview:countryLabel];
        countryLabel.text = selectedLocation.country;


    }
    
    if (indexPath.row == 2) {
        cell = directionsCell;
        directionsCell.textLabel.text = @"Directions";
        directionsCell.textLabel.font = [UIFont systemFontOfSize:12];
        directionsCell.textLabel.textAlignment = NSTextAlignmentCenter;
        directionsCell.textLabel.textColor = [UIColor blueColor];
    }
    
    if (indexPath.row == 3) {
        cell = backToMapCell;
        backToMapCell.textLabel.text = @"Back to Map";
        backToMapCell.textLabel.font = [UIFont systemFontOfSize:12];
        backToMapCell.textLabel.textAlignment = NSTextAlignmentCenter;
        backToMapCell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
    
}



@end
