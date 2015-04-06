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

@implementation ProfileTableViewDatasource

//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [UserController sharedInstance].usersSharedLocations.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    User *user = [UserController sharedInstance].usersSharedLocations[indexPath.row];
    cell.textLabel.text = user.username;
    
    return cell;
}
@end
