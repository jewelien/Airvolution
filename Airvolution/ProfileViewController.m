//
//  ProfileViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/1/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewDatasource.h"


@interface ProfileViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ProfileTableViewDatasource *dataSource;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Profile";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.dataSource = [ProfileTableViewDatasource new];
    [self.dataSource registerTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    [self.view addSubview:self.tableView];
    
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
