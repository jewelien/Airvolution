//
//  ProfileViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/1/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileTableViewDatasource.h"
#import "UserController.h"


@interface ProfileViewController ()

@property (nonatomic, strong) ProfileTableViewDatasource *dataSource;
@property (nonatomic, strong) UIActivityIndicatorView *savingUsernameView;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:UsersLocationsNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:UserProfileNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEditAlertController) name:editProfileNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeIndicatorView) name:UsernameSavedNotificationKey object:nil];
}

- (void)updateProfile {
    [self.tableView reloadData];
}

-(void)removeIndicatorView {
    UIAlertController *usernamedSavedAlertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Username changed successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.savingUsernameView stopAnimating];
        [usernamedSavedAlertController removeFromParentViewController];
    }];
    [usernamedSavedAlertController addAction:okAction];
    [self presentViewController:usernamedSavedAlertController animated:YES completion:nil];
}

-(void)deRegisterForNotifcations
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)presentEditAlertController {
    UIAlertController *editAlertController = [UIAlertController alertControllerWithTitle:@"Edit" message:@"Select what you would like to change." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *editUsername = [UIAlertAction actionWithTitle:@"username" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editUsername];
    }];
    [editAlertController addAction:editUsername];
    
//    UIAlertAction *editImage = [UIAlertAction actionWithTitle:@"profile image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSLog(@"profileImage");
//    }];
//    [editAlertController addAction:editImage];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"cancel");
        [editAlertController removeFromParentViewController];
    }];
    [editAlertController addAction:cancel];


    [self presentViewController:editAlertController animated:YES completion:nil];
}

- (void)editUsername
{
    UIAlertController *usernameAlertController = [UIAlertController alertControllerWithTitle:@"Username" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [usernameAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"new username";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"cancel");
        [usernameAlertController removeFromParentViewController];
    }];
    [usernameAlertController addAction:cancelAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"save username");
        UITextField *usernameField = usernameAlertController.textFields [0];
        NSMutableArray *usernames = [[NSMutableArray alloc] init];
        for (User *user in [UserController sharedInstance].allUsers ) {
            [usernames addObject:user.username];
        }
        
        if ([usernames containsObject:usernameField.text]) {
            NSLog(@"already taken");
            [self usernameAlreadyTakenAlert];
        } else {
            NSLog(@"username available");
            self.savingUsernameView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.savingUsernameView.frame = self.view.bounds;
            self.savingUsernameView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [self.view addSubview:self.savingUsernameView];
            [self.savingUsernameView startAnimating];
            [[UserController sharedInstance]updateUsernameWith:usernameField.text];
        }
        
    }];
    [usernameAlertController addAction:saveAction];
    
    [self presentViewController:usernameAlertController animated:YES completion:nil];

}

-(void)editProfileImage {
    
}

-(void)usernameAlreadyTakenAlert {
    UIAlertController *usernameTakeAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"The new username you entered has already been taken. Please choose a different username." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [usernameTakeAlertController removeFromParentViewController];
        [self editUsername];
    }];
    [usernameTakeAlertController addAction:okAction];
    [self presentViewController:usernameTakeAlertController animated:YES completion:nil];
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
