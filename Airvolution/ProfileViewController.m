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
#import "Location.h"
#import "LocationController.h"
#import "UIColor+Color.h"
#import <Airvolution-Swift.h>
#import "Airvolution-Swift.h"
@import GoogleMobileAds;

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ProfileTableViewDatasource *dataSource;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *deletingLocationView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"MY SHARED LOCATIONS (%lu)", (unsigned long)[UserController sharedInstance].currentUser.locations.count];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor airvolutionRed];
    UIBarButtonItem *sort = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStylePlain target:self action:@selector(sortSharedLocationsAlert)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = sort;
    CGRect tableViewRect = self.view.bounds;
    tableViewRect.size.height = tableViewRect.size.height - 100;
    self.tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStyleGrouped];
    self.dataSource = [ProfileTableViewDatasource new];
    [self.dataSource registerTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    [self.view addSubview:self.tableView];
    [self registerForNotifications];
}

-(void)viewWillAppear:(BOOL)animated {
    [self addAdView];
}

- (void)registerForNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:updateProfileKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLocationCheckAlert:) name:deleteLocationNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDeletedAlert) name:locationDeletedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:SortSavedKey object:nil];
}

- (void)updateProfile {
    self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"MY SHARED LOCATIONS (%lu)", (unsigned long)[UserController sharedInstance].currentUser.locations.count];
    [self.tableView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)addAdView {
    GADBannerView *bannerView = [StyleController sharedInstance].bannerView;
    bannerView.rootViewController = self;
    [bannerView loadRequest:[GADRequest request]];
    [self.view addSubview:bannerView];
}

#pragma mark deleteLocation

-(void)deleteLocationCheckAlert:(NSNotification *)notification {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Confirm Delete" message:@"Are you sure you want delete this location?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [controller removeFromParentViewController];
    }];
    [controller addAction:cancelAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        NSLog(@"location.recordID %@", notification.object);
        self.deletingLocationView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.deletingLocationView.frame = self.view.bounds;
        [self.view addSubview:self.deletingLocationView];
        [self.deletingLocationView startAnimating];
        [[LocationController sharedInstance]deleteLocationWithRecordName:notification.object];
    }];
    [controller addAction:deleteAction];
    [self presentViewController:controller animated:YES completion:nil];
    
}

-(void)locationDeletedAlert {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Deleted" message:@"The location you selected was deleted." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.deletingLocationView stopAnimating];
        [self.tableView reloadData];
        [controller removeFromParentViewController];
    }];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark sortLocations
-(void)sortSharedLocationsAlert {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Sort" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *descendingSortAction = [UIAlertAction actionWithTitle:@"newest to oldest" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UserController sharedInstance] saveLocationFilter:DescendingSort];
    }];
    [controller addAction:descendingSortAction];
    UIAlertAction *ascendingSortAction = [UIAlertAction actionWithTitle:@"oldest to newest" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UserController sharedInstance] saveLocationFilter:AscendingSort];
    }];
    [controller addAction:ascendingSortAction];
    UIAlertAction *alphabeticalSortAction = [UIAlertAction actionWithTitle:@"a to z" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UserController sharedInstance] saveLocationFilter:AlphabeticalSort];
    }];
    [controller addAction:alphabeticalSortAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [controller removeFromParentViewController];
    }];
    [controller addAction:cancelAction];
    [self presentViewController:controller animated:YES completion:nil];
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
