//
//  LeaderboardViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/1/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "UserController.h"
#import "UserController.h"

@interface LeaderboardViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sortedUsers;

@end

static NSString * const cellKey = @"cell";

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Leaderboard";
    [self sortUsersByPoints];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellKey];
    [self.view addSubview:self.tableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortUsersByPoints) name:UserPointsNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortUsersByPoints) name:AllUsersFetchNotificationKey object:nil];
    
}

- (void)updateLeaderboard {
    [self.tableView reloadData];
}

-(void)sortUsersByPoints {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:PointsKey ascending:NO];
    self.sortedUsers = [[UserController sharedInstance].allUsers sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UserController sharedInstance].allUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];

    for (id object in cell.contentView.subviews)
    {
        [object removeFromSuperview];
    }
    
//    User *user = [UserController sharedInstance].allUsers[indexPath.row];
    User *user = self.sortedUsers[indexPath.row];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(35, 2, 40, 40)];
    view.layer.cornerRadius = 15;
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor lightGrayColor];
    view.image = user.profileImage;
    [cell.contentView addSubview:view];
    
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 125, 20)];
//    usernameLabel.backgroundColor = [UIColor orangeColor];
    usernameLabel.textAlignment = NSTextAlignmentCenter;
    usernameLabel.text = user.username;
    [cell.contentView addSubview:usernameLabel];
    
    UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 10, 90, 20)];
//    pointsLabel.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:pointsLabel];
    pointsLabel.text = [NSString stringWithFormat:@"Points: %@", user.points];
    pointsLabel.font = [UIFont systemFontOfSize:13.0];
    
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
