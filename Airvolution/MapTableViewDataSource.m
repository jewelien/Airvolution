//
//  MapTableViewDataSource.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/15/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MapTableViewDataSource.h"
#import "LocationController.h"
#import "UIColor+Color.h"
#import "MapViewController.h"

@interface MapTableViewDataSource ()

@property (nonatomic, strong) Location *selectedLocation;
@property (nonatomic, strong) MapViewController *mapVC;

@end

@implementation MapTableViewDataSource

- (void)registerTableView:(UITableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    
    UITableViewCell *nameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UITableViewCell *addressCell = [[UITableViewCell alloc] init];
    UITableViewCell *locationNotesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UITableViewCell *backToMapCell = [[UITableViewCell alloc] init];
    UITableViewCell *directionsCell = [[UITableViewCell alloc] init];
    UITableViewCell *confirmCell = [[UITableViewCell alloc] init];
    self.selectedLocation = [LocationController sharedInstance].selectedLocation;

    if (indexPath.row == 0) {
        cell = nameCell;
        [self locationNameCell:nameCell];
    }
    
    if (indexPath.row == 1) {
        cell = locationNotesCell;
        [self locationNotesCell:locationNotesCell];
    }
    
    if (indexPath.row == 2) {
        cell = addressCell;
        [self addressCell:addressCell];
        
    }
    
    if (indexPath.row == 3) {
        cell = confirmCell;
        [self confirmCell:confirmCell];
    }
    
    if (indexPath.row == 4) {
        cell = directionsCell;
        directionsCell.textLabel.text = @"Directions";
        directionsCell.textLabel.font = [UIFont systemFontOfSize:12];
        directionsCell.textLabel.textAlignment = NSTextAlignmentCenter;
        directionsCell.textLabel.textColor = [UIColor blueColor];
    }
    
    if (indexPath.row == 5) {
        cell = backToMapCell;
        backToMapCell.textLabel.text = @"Back to Map";
        backToMapCell.textLabel.font = [UIFont systemFontOfSize:12];
        backToMapCell.textLabel.textAlignment = NSTextAlignmentCenter;
        backToMapCell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
    
}

- (void)locationNameCell:(UITableViewCell *)nameCell{
//            nameCell.backgroundColor = [UIColor lightGrayColor];
//    nameCell.textLabel.textColor = [UIColor whiteColor];
    nameCell.textLabel.text = self.selectedLocation.locationName;
    nameCell.textLabel.textColor = [UIColor airvolutionRed];
    nameCell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    nameCell.textLabel.textAlignment = NSTextAlignmentCenter;
    nameCell.detailTextLabel.text = [NSString stringWithFormat:@"shared by: %@  on: %@", self.selectedLocation.username, self.selectedLocation.creationDate];
    nameCell.detailTextLabel.font = [UIFont italicSystemFontOfSize:12];
}

- (void)locationNotesCell:(UITableViewCell *)locationNotesCell
{
    if (self.selectedLocation.locationNotes) {
        locationNotesCell.textLabel.text = self.selectedLocation.locationNotes;
        locationNotesCell.textLabel.font = [UIFont italicSystemFontOfSize:12];
    } else {
        locationNotesCell.textLabel.text = @"no notes added";
        locationNotesCell.textLabel.textColor = [UIColor grayColor];
        locationNotesCell.textLabel.font = [UIFont italicSystemFontOfSize:12];

    }
}

- (void)addressCell:(UITableViewCell *)addressCell{
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, addressCell.contentView.frame.size.width, 20)];
    [addressCell.contentView addSubview:addressLabel];
    addressLabel.text = @"address: ";
    addressLabel.font = [UIFont systemFontOfSize:12];
    addressLabel.textColor = [UIColor blueColor];
    
    UILabel *streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, addressCell.contentView.frame.size.width, 20)];
    [addressCell.contentView addSubview:streetLabel];
    streetLabel.text = self.selectedLocation.street;
    streetLabel.font = [UIFont systemFontOfSize:15];
    
    
    UILabel *cityStateZipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, addressCell.contentView.frame.size.width, 20)];
    [addressCell.contentView addSubview:cityStateZipLabel];
    cityStateZipLabel.text = [NSString stringWithFormat:@"%@ %@ %@", self.selectedLocation.city, self.selectedLocation.state, self.selectedLocation.zip];
    cityStateZipLabel.font = [UIFont systemFontOfSize:15];

    
    UILabel *countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, addressCell.contentView.frame.size.width, 20)];
    [addressCell.contentView addSubview:countryLabel];
    countryLabel.text = self.selectedLocation.country;
    countryLabel.font = [UIFont systemFontOfSize:15];

}

- (void)confirmCell:(UITableViewCell *)confirmCell {
    //row height 40
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, confirmCell.contentView.frame.size.width / 2, 30)];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
    confirmButton.layer.cornerRadius = 5;
    confirmButton.showsTouchWhenHighlighted = YES;
    confirmButton.backgroundColor = [UIColor airvolutionRed];
    [confirmCell.contentView addSubview:confirmButton];
    [confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 320 - 160
    float leftoverWidth = (confirmCell.contentView.frame.size.width - confirmButton.frame.size.width) - 90;
    UIButton *confirmCountButton = [[UIButton alloc] initWithFrame:CGRectMake(confirmButton.frame.size.width + 15, 5, leftoverWidth, 30)];
    confirmCountButton.layer.cornerRadius = 15;
    confirmCountButton.showsTouchWhenHighlighted = YES;
    confirmCountButton.backgroundColor = [UIColor airvolutionRed];
    [confirmCell.contentView addSubview:confirmCountButton];
    [confirmCountButton setTitle:@"#" forState:UIControlStateNormal];

}

-(void)confirmButtonPressed {
    [[NSNotificationCenter defaultCenter] postNotificationName:confirmNotificationKey object:nil];
}


@end
