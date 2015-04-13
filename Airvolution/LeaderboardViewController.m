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
@end

static NSString * const cellKey = @"cell";

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Leaderboard";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellKey];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLeaderboard) name:UserPointsNotificationKey object:nil];

    
}

- (void)updateLeaderboard {
    [self.tableView reloadData];
}

-(void)deRegisterForNotifcations
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [UserController sharedInstance].allUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellKey];
    
//    if (cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([UITableViewCell class])];
//    }
    
    User *user = [UserController sharedInstance].allUsers[indexPath.row];
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(35, 2, 40, 40)];
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
    
    NSString *pointsString = [NSString stringWithFormat:@"Points: %@", user.points];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:pointsString];
//    UIFont *fontSize = [UIFont systemFontOfSize:5.f];
//    [attributedString addAttribute:NSFontAttributeName value:fontSize range:NSMakeRange(0, 6)];
        pointsLabel.text = pointsString;
    pointsLabel.font = [UIFont systemFontOfSize:12.0];
    [cell.contentView addSubview:pointsLabel];
    
//    cell.imageView.image = user.profileImage;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
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
