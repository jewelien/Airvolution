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


@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ProfileTableViewDatasource *dataSource;
@property (nonatomic, strong) UIActivityIndicatorView *savingUsernameView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSData *imageData;
//@property (nonatomic, strong) NSURL *selectedImageURL;
@property (nonatomic, strong) UIActivityIndicatorView *savingImageView;
@property (nonatomic, strong) UIActivityIndicatorView *deletingLocationView;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Profile";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor airvolutionRed]};

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.dataSource = [ProfileTableViewDatasource new];
    [self.dataSource registerTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    [self.view addSubview:self.tableView];

    [self registerForNotifications];
    
}

- (void)registerForNotifications
{    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:updateProfileKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEditAlertController) name:editProfileNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usernameSaveSuccessAlert) name:UsernameSavedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileImageSaveSuccessAlert) name:UserImageNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteLocationCheckAlert:) name:deleteLocationNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDeletedAlert) name:locationDeletedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortSharedLocationsAlert) name:editSortNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:SortSavedKey object:nil];
}

- (void)updateProfile {
    [self.tableView reloadData];
}

-(void)usernameSaveSuccessAlert {
    UIAlertController *usernamedSavedAlertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Username changed successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.tableView reloadData];
        [self.savingUsernameView stopAnimating];
        [usernamedSavedAlertController removeFromParentViewController];
    }];
    [usernamedSavedAlertController addAction:okAction];
    [self presentViewController:usernamedSavedAlertController animated:YES completion:nil];
}

-(void)profileImageSaveSuccessAlert {
    UIAlertController *profileImageSavedAlertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Profile image changed successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.tableView reloadData];
        [self.savingImageView stopAnimating];
    }];
    [profileImageSavedAlertController addAction:okAction];
    [self presentViewController:profileImageSavedAlertController animated:YES completion:nil];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark EditButtonPressed
- (void)presentEditAlertController {
    UIAlertController *editAlertController = [UIAlertController alertControllerWithTitle:@"Edit" message:@"What would you like to change?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *editUsername = [UIAlertAction actionWithTitle:@"username" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self editUsername];
    }];
    [editAlertController addAction:editUsername];
    
    UIAlertAction *editImage = [UIAlertAction actionWithTitle:@"profile image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"profileImage");
        [self editProfileImage];
    }];
    [editAlertController addAction:editImage];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [editAlertController removeFromParentViewController];
    }];
    [editAlertController addAction:cancel];


    [self presentViewController:editAlertController animated:YES completion:nil];
}

#pragma mark usernameEdit

- (void)editUsername
{
    UIAlertController *usernameAlertController = [UIAlertController alertControllerWithTitle:@"Username" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [usernameAlertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"new username";
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [usernameAlertController removeFromParentViewController];
    }];
    [usernameAlertController addAction:cancelAction];
    
    
    UITextField *usernameField = usernameAlertController.textFields [0];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    for (User *user in [UserController sharedInstance].allUsers ) {
        [usernames addObject:user.username];
    }
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        
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

-(void)usernameAlreadyTakenAlert {
    UIAlertController *usernameTakeAlertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"The new username you entered has already been taken. Please choose a different username." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [usernameTakeAlertController removeFromParentViewController];
        [self editUsername];
    }];
    [usernameTakeAlertController addAction:okAction];
    [self presentViewController:usernameTakeAlertController animated:YES completion:nil];
}


#pragma mark profileImageEdit

-(void)editProfileImage {
    UIAlertController *imageDestinationAlertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    UIAlertAction *fromCameraRoll = [UIAlertAction actionWithTitle:@"From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [imageDestinationAlertController removeFromParentViewController];
    }];
    [imageDestinationAlertController addAction:fromCameraRoll];
    [imageDestinationAlertController addAction: takePhoto];
    [imageDestinationAlertController addAction:cancelAction];
    [self presentViewController:imageDestinationAlertController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageData = UIImagePNGRepresentation(self.selectedImage);
    [picker dismissViewControllerAnimated:YES completion:^{
        [self confirmImageAlert:self.selectedImage];
    }];
}

-(void)confirmImageAlert:(UIImage*)selectedImage {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Update profile image?" message:@"\n \n \n \n " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [controller removeFromParentViewController];
    }];
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant: 210];
//    [controller.view addConstraint:height];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UserController sharedInstance] updateUserImageWithData:self.imageData];
        [controller removeFromParentViewController];
    }];
    [controller addAction: cancelAction];
    [controller addAction:confirmAction];
    
    float estimatedCenter =[UIScreen mainScreen].bounds.size.width * .25 ;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(estimatedCenter, 50, 80, 80)];
    imageView.backgroundColor = [UIColor redColor];
    imageView.image = selectedImage;
    [controller.view addSubview:imageView];
    [self presentViewController:controller animated:YES completion:nil];
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
