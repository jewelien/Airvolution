//
//  AppDelegate.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "LocationController.h"
#import "ProfileViewController.h"
#import "LeaderboardViewController.h"
#import "UserController.h"
#import <MapKit/MapKit.h>
#import "UIColor+Color.h"


@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([self isFirstTimeOpening] == true) {
        [[UserController sharedInstance]initialLoad];
    } else {
        [[UserController sharedInstance]fetchUserRecordIDWithCompletion:^(NSString *userRecordName) {
            [[UserController sharedInstance]checkUserinCloudKitUserList];
            [[UserController sharedInstance]findCurrentUser];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:allLocationsFetchedNotificationKey object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:UsersLocationsNotificationKey object:nil];
            });
        }];


    }
    
//        [[UserController sharedInstance]fetchUserRecordIDWithCompletion:^(NSString *userRecordName) {
//            [[LocationController sharedInstance]loadLocationsFromCloudKitWithCompletion:^(NSArray *array) {
//                [[UserController sharedInstance]checkUserinCloudKitUserList];
//                //            [[UserController sharedInstance]fetchLocationsForUser:[UserController sharedInstance].currentUser];
//                //            [[UserController sharedInstance]fetchUsersSavedLocationsFromArray:array withCompletion:^(NSArray *usersLocations) {
//                //            }];
//            }];
//        }];
    

    [[UITabBar appearance] setTintColor:[UIColor airvolutionRed]];
    
    MapViewController *mapViewController = [MapViewController new];
    UIImage *mapImage = [UIImage imageNamed:@"globe"];
    UITabBarItem *mapTabBar = [[UITabBarItem alloc] initWithTitle:@"Map" image:mapImage selectedImage:nil];
    mapViewController.tabBarItem = mapTabBar;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
//    navigationController.navigationBar.backgroundColor = [UIColor airvolutionRed];
    
    ProfileViewController *profileViewController = [ProfileViewController new];
    UIImage *profileImage = [UIImage imageNamed:@"profileBlue"];
    UITabBarItem *profileTabBar = [[UITabBarItem alloc] initWithTitle:@"Profile" image:profileImage selectedImage:nil];
    profileViewController.tabBarItem = profileTabBar;
    UINavigationController *profileNav = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
    LeaderboardViewController *leaderboardViewController = [LeaderboardViewController new];
    UIImage *leaderboardImage = [UIImage imageNamed:@"people"];
    UITabBarItem *leaderboardTabBar = [[UITabBarItem alloc] initWithTitle:@"Leaderboard" image:leaderboardImage selectedImage:nil];
    leaderboardViewController.tabBarItem = leaderboardTabBar;
    UINavigationController *leaderboardNav = [[UINavigationController alloc] initWithRootViewController:leaderboardViewController];
    
    NSArray *controllers = [NSArray arrayWithObjects:profileNav, navigationController, leaderboardNav, nil];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = controllers;
    
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.tabBarController;
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MapViewController new]];
    
    [self.window makeKeyAndVisible];
    
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = 1;
    
    return YES;
}

- (BOOL) isFirstTimeOpening {
    NSUserDefaults *theDefaults = [NSUserDefaults standardUserDefaults];
    if([theDefaults integerForKey:@"hasRun"] == 0) {
        [theDefaults setInteger:1 forKey:@"hasRun"];
        [theDefaults synchronize];
        return true;
    }
    return false;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
