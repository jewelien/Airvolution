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


@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ProfileTableViewDatasource *dataSource;
@property (nonatomic, strong) UIActivityIndicatorView *savingUsernameView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSData *imageData;
//@property (nonatomic, strong) NSURL *selectedImageURL;
@property (nonatomic, strong) UIActivityIndicatorView *savingImageView;


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfile) name:UserPointsNotificationKey object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEditAlertController) name:editProfileNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usernameSaveSuccessAlert) name:UsernameSavedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileImageSaveSuccessAlert) name:UserImageNotificationKey object:nil];
}

- (void)updateProfile {
    [self.tableView reloadData];
}

-(void)usernameSaveSuccessAlert {
    UIAlertController *usernamedSavedAlertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Username changed successfully." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.savingUsernameView stopAnimating];
        [usernamedSavedAlertController removeFromParentViewController];
    }];
    [usernamedSavedAlertController addAction:okAction];
    [self presentViewController:usernamedSavedAlertController animated:YES completion:nil];
}

-(void)profileImageSaveSuccessAlert {
    UIAlertController *profileImageSavedAlertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Profile image changed successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.savingImageView stopAnimating];
    }];
    [profileImageSavedAlertController addAction:okAction];
    [self presentViewController:profileImageSavedAlertController animated:YES completion:nil];
    
}

-(void)deRegisterForNotifcations
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark EditButtonPressed
- (void)presentEditAlertController {
    UIAlertController *editAlertController = [UIAlertController alertControllerWithTitle:@"Edit" message:@"Select what you would like to change." preferredStyle:UIAlertControllerStyleAlert];
    
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
        NSLog(@"cancel");
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
    UIAlertAction *fromCameraRoll = [UIAlertAction actionWithTitle:@"From Camera Roll" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    [imageDestinationAlertController addAction:fromCameraRoll];
    [self presentViewController:imageDestinationAlertController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.imageData = UIImagePNGRepresentation(self.selectedImage);
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self confirmImageView:self.selectedImage];
    }];
    
}


-(void)confirmImageView:(UIImage *)selectedImage {
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    UIView *confirmImageView = [[UIView alloc] initWithFrame:CGRectMake((self.backgroundView.frame.size.width / 2) - 140, 90, 280, 260)];
    confirmImageView.backgroundColor = [UIColor colorWithWhite:.95 alpha:2.0];
//    confirmImageView.backgroundColor = [UIColor grayColor];
    [self.backgroundView addSubview:confirmImageView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((confirmImageView.frame.size.width / 2) - 70, 40, 140, 140)];
    imageView.image = selectedImage;
    [confirmImageView addSubview:imageView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((confirmImageView.frame.size.width / 2) - 70, 10, 140, 30)];
    label.text = @"Confirm Image";
    label.textAlignment = NSTextAlignmentCenter;
//    label.font = [UIFont boldSystemFontOfSize:20];
    label.font = [UIFont systemFontOfSize:13 weight:1.0];
    [confirmImageView addSubview:label];

    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((confirmImageView.frame.size.width / 2) - 70, 185, 140, 30)];
//    cancelButton.backgroundColor = [UIColor lightGrayColor];
    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmImageView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(imageCancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake((confirmImageView.frame.size.width / 2) - 70, 220, 140, 30)];
//    confirmButton.backgroundColor = [UIColor lightGrayColor];
    [confirmButton setTitle:@"confirm" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmImageView addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(imageConfirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.backgroundView];
}

-(void)imageCancelButtonPressed {
    [self.backgroundView removeFromSuperview];
}

-(void)imageConfirmButtonPressed {
    [self.backgroundView removeFromSuperview];
    
    self.savingImageView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.savingImageView.frame = self.view.bounds;
    self.savingImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:self.savingImageView];
    [self.savingImageView startAnimating];
    
    [[UserController sharedInstance] updateUserImageWithData:self.imageData];
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
