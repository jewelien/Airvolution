//
//  ViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MapViewController.h"
#import "LocationController.h"
#import "UserController.h"
#import "MapTableViewDataSource.h"
#import "UIColor+Color.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *initialLoadingIndicatorView;


@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) MKPointAnnotation *droppedPinAnnotation;

@property (nonatomic, strong) NSMutableArray *searchedAnnotations;

@property (nonatomic, strong) NSArray *selectedPinAddress;
@property (nonatomic, strong) NSString *selectedPinStreet;
@property (nonatomic, strong) NSString *selectedPinCity;
@property (nonatomic, strong) NSString *selectedPinState;
@property (nonatomic, strong) NSString *selectedPinZip;
@property (nonatomic, strong) NSString *selectedPinCountry;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSArray *allLocations;
@property (nonatomic, strong) MKPointAnnotation *selectedAnnotation;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MapTableViewDataSource *datasource;
@property (nonatomic, strong) UIView *locationInfoBackgroundView;


@end

static NSString * const droppedPinTitle = @"cancel or add";


@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTitle:@"AIRVOLUTION"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                    };
//    UIImage *logoImage = [UIImage imageNamed:@"logo"];
//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
//    logoImageView.image = logoImage;
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 0, 15);
    
    self.navigationController.navigationBar.barTintColor = [UIColor airvolutionRed];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:5.0];
    self.view.backgroundColor = [UIColor airvolutionRed];
    
    
    [self setupMap];
    [self navigationBarButtonItems];
    [self registerForNotifications];
    
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, -30, 285, 30)];
    [self showSearchBar];
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
//    [self.navigationItem setLeftBarButtonItem:searchButton];

    [self loadingViewAtLaunch];

}

- (void)loadingViewAtLaunch {
    self.initialLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.initialLoadingIndicatorView.frame = self.view.bounds;
    self.initialLoadingIndicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.initialLoadingIndicatorView startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.navigationController.navigationBar addSubview:self.initialLoadingIndicatorView];
}


- (void)setupMap {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)navigationBarButtonItems{
    //    self.dropPinButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 400, 45, 55)];
    ////    self.dropPinButton.backgroundColor = [UIColor grayColor];
    //    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    //    [self.view addSubview:self.dropPinButton];
    //    [self.dropPinButton addTarget:self action:@selector(dropPinAtCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.dropPinButton = [[UIButton alloc] initWithFrame:view.frame];
    [self.dropPinButton setImage:[UIImage imageNamed:@"marker"] forState:UIControlStateNormal];
    
    [self.dropPinButton addTarget:self action:@selector(dropPinAtCenterOfMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.dropPinButton];
    UIBarButtonItem *pinDrop = [[UIBarButtonItem alloc] initWithCustomView:view];
    [self.navigationItem setRightBarButtonItem:pinDrop];
    
    
    UILongPressGestureRecognizer *dropPinPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinWithGestureRecognizer:)];
    dropPinPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:dropPinPress];
    
    
    MKUserTrackingBarButtonItem *barButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIImage *currentLocationImage = [UIImage imageNamed:@"nearMe"];
    UIImageView *currentLocationView = [[UIImageView alloc] initWithImage:currentLocationImage];
    [barButtonItem setCustomView:currentLocationView] ;
    [self.navigationItem setLeftBarButtonItem:barButtonItem];

}

#pragma mark - mapSearch

- (void)showSearchBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar = [[UISearchBar alloc] init];
        int viewWidth = self.view.frame.size.width;
        self.searchBar.frame = CGRectMake(10 , 70, viewWidth - 15, 30);
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.backgroundColor = [UIColor whiteColor];
            self.searchBar.barTintColor = [UIColor lightGrayColor];
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        [self.view addSubview:self.searchBar];
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.mapView removeAnnotations:self.searchedAnnotations];
//    [UIView animateWithDuration:1.0 animations:^{
//        self.searchBar.frame = CGRectMake(20, -30, 285, 30);
//        self.searchBar.text = @"";
//    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.mapView removeAnnotations:self.searchedAnnotations];
    [searchBar resignFirstResponder];
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.searchBar.text;
    request.region = self.mapView.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         self.searchedAnnotations = [NSMutableArray new];
         
         for (MKMapItem *item in response.mapItems) {
             MKPointAnnotation *searchedAnnotation = [[MKPointAnnotation alloc] init];
             searchedAnnotation.coordinate = item.placemark.coordinate;
             searchedAnnotation.title = item.name;
             [self.searchedAnnotations addObject:searchedAnnotation];
         }
         
         [self.mapView showAnnotations:self.searchedAnnotations animated:NO];
     }];
}

#pragma mark - notification observers
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notLoggedIniCloudAlert) name:NotLoggedIniCloudNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMapWithSavedLocations) name:allLocationsFetchedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitFailedAlert) name:newLocationSaveFailedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitSuccess) name:newLocationSavedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMapAnnotations) name:locationDeletedNotificationKey object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLaunchScreen) name:removeLoadingLaunchScreenNotification object:nil];
}

- (void)removeLaunchScreen {
    [self.initialLoadingIndicatorView stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)notLoggedIniCloudAlert {
    [self.initialLoadingIndicatorView stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Required" message:@"To use this app please log in to your iCloud account in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert removeFromParentViewController];
        [self.indicatorView stopAnimating];
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Take me there" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)removeMapAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateMapWithSavedLocations];
}

- (void)updateMapWithSavedLocations
{
    NSMutableArray *locationsArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        MKPointAnnotation *savedAnnotation = [[MKPointAnnotation alloc] init];
        savedAnnotation.coordinate = CLLocationCoordinate2DMake(location.location.coordinate.latitude, location.location.coordinate.longitude);
        savedAnnotation.title = location.locationName;
        
        [locationsArray addObject:savedAnnotation];
    }
    self.allLocations = locationsArray;
    [self.mapView addAnnotations:locationsArray];
    [self.mapView reloadInputViews];
    
    [self removeLaunchScreen];
}

- (void)savedToCloudKitFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Location failed to save. Please make sure you have a network connection and logged in to your iCloud account in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)savedToCloudKitSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Location saved. Thank you!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
        [self.indicatorView stopAnimating];
    }];
    [alert addAction:action];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - geocode location
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *selectedAnnotation = view.annotation;
    
    if ( [selectedAnnotation isKindOfClass:[MKPlacemark class]] ) {
        return;
    } else {
        CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:selectedAnnotation.coordinate.latitude longitude:selectedAnnotation.coordinate.longitude];
        [self reverseGeocode:selectedLocation forAnnotation:selectedAnnotation];
    }
    
}

- (void)reverseGeocode:(CLLocation *)location forAnnotation:(MKPointAnnotation *)annotation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.selectedPinAddress = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
            self.selectedPinStreet = [placemark.addressDictionary valueForKey:@"Street"];
            self.selectedPinCity = [placemark.addressDictionary valueForKey:@"City"];
            self.selectedPinState = [placemark.addressDictionary valueForKey:@"State"];
            self.selectedPinZip  = [placemark.addressDictionary valueForKey:@"ZIP"];
            self.selectedPinCountry  = [placemark.addressDictionary valueForKey:@"Country"];

            annotation.subtitle = [NSString stringWithFormat:@"%@", self.selectedPinAddress[0]];
        }
    }];

}

#pragma mark - drop Pin Action
- (void)dropPinAtCenterOfMap {
    
    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
//    self.droppedPinAnnotation.coordinate = self.mapView.userLocation.coordinate;
    self.droppedPinAnnotation.coordinate = self.mapView.centerCoordinate;
    self.droppedPinAnnotation.title = droppedPinTitle;
    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
    NSLog(@"DROPPED %@", self.location);
    
    for (id annotation in self.mapView.annotations) {
        if ([[annotation title] isEqualToString:droppedPinTitle]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    [self.mapView addAnnotation:self.droppedPinAnnotation];
}

- (void)addPinWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
    self.droppedPinAnnotation.coordinate = touchMapCoordinate;
    self.droppedPinAnnotation.title = droppedPinTitle;
    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
    NSLog(@"DROPPED %@", self.location);
    
    for (id annotation in self.mapView.annotations) {
        if ([[annotation title] isEqualToString:droppedPinTitle]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self.mapView addAnnotation:self.droppedPinAnnotation];
}

#pragma mark - annotation views
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pinView;
//    pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
//    if ([annotation isKindOfClass:[MKPlacemark class] ]) {
    if ([self.searchedAnnotations containsObject:annotation]) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"searchedPin"];

        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
    } else if ([[annotation title] isEqualToString:droppedPinTitle]) {
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droppedPin"];
            pinView.draggable = YES;
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            pinView.pinColor = MKPinAnnotationColorPurple;
            
            UIButton *addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            addLocationButton.tag = 2;
            pinView.rightCalloutAccessoryView = addLocationButton;
            
            UIImage *removePinImage = [UIImage imageNamed:@"remove"];
            UIButton *removePinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, removePinImage.size.width, removePinImage.size.height)];
            [removePinButton setImage:removePinImage forState:UIControlStateNormal];
            removePinButton.tag = 1;
            pinView.leftCalloutAccessoryView = removePinButton;
            
        }     else {
            pinView.annotation = annotation;
        }
    } else { //pinview for saved/shared locations
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sharedPin"];
        pinView.canShowCallout = YES;
    
        UIImage *directionsImage = [UIImage imageNamed:@"rightFilled"];
        UIButton *directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, directionsImage.size.width, directionsImage.size.height)];
        [directionsButton setImage:directionsImage forState:UIControlStateNormal];
        directionsButton.tag = 3;
        pinView.leftCalloutAccessoryView = directionsButton;
        
//        UIImage *moreInfo = [UIImage imageNamed:@"right"];
//        UIButton *moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, moreInfo.size.width, moreInfo.size.height)];
//        [moreInfoButton setImage:moreInfo forState:UIControlStateNormal];
        UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        moreInfoButton.tag = 4;
        pinView.rightCalloutAccessoryView = moreInfoButton;
    }
    
    return pinView;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if (self.droppedPinAnnotation) {
        [mapView selectAnnotation:self.droppedPinAnnotation animated:YES];
    }
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        self.location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        //        NSLog(@"DRAGGED %@", self.location );
        
    }
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    self.selectedAnnotation = view.annotation;
    
    if ([control tag] == 2) {
        [self addLocationButtonClicked];
        
    } else if ([control tag] == 1) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
        
    } else if ([control tag] == 3) {
        //directions
        [self directionsButtonPressedWithAnnotation:self.selectedAnnotation];
        
    } else if ([control tag] == 4) {
        //more info
        [self locationMoreInfoPressedForAnnotation:self.selectedAnnotation];
    }
    
}

-(void) addLocationButtonClicked {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Location" message:[NSString stringWithFormat:@"Address: %@, \n %@", self.selectedPinAddress[0], self.selectedPinAddress[1]]  preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"location name";
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"notes (optional)";
        textField.textAlignment = NSTextAlignmentCenter;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self removeFromParentViewController];
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *locationNameField = alertController.textFields[0];
        UITextField *locationNotesField = alertController.textFields[1];
        if ([locationNameField.text isEqualToString:@""]) {
            NSLog(@"no text no save");
        } else {
            [self saveButtonPressedWithLocationName:locationNameField.text andLocationNotes:locationNotesField.text];
        }
    }];
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)saveButtonPressedWithLocationName:(NSString *)locationName andLocationNotes:(NSString *)notes {
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame = self.view.bounds;
    self.indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    //                self.indicatorView.center = CGPointMake(160, 240);
    [self.indicatorView startAnimating];
    [self.view addSubview:self.indicatorView];
    
    if (![UserController sharedInstance].currentUserRecordID) {
        [self notLoggedIniCloudAlert];
    } else {
        [[LocationController sharedInstance] saveLocationWithName:locationName
                                                         location:self.location
                                                    streetAddress:self.selectedPinStreet
                                                             city:self.selectedPinCity state:self.selectedPinState zip:self.selectedPinZip
                                                          country:self.selectedPinCountry
                                                            notes:notes];
    }
}
    




#pragma mark - directions
-(void)directionsButtonPressedWithAnnotation:(MKPointAnnotation *)annotation
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Directions" message:@"You will be taken to the maps app for directions." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [controller removeFromParentViewController];
    }];
    [controller addAction:cancelAction];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self goToMapsAppForDirectionsToAnnotation:annotation];
    }];
    [controller addAction: action];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)goToMapsAppForDirectionsToAnnotation:(MKPointAnnotation *)annotation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    NSDictionary *dictionary = [[LocationController sharedInstance]addressDictionaryForLocationWithCLLocation:location];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:dictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 10000, 10000);
    [MKMapItem openMapsWithItems:@[mapItem] launchOptions:[NSDictionary dictionaryWithObjectsAndKeys: [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey, [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}

#pragma mark - location info
-(void)locationMoreInfoPressedForAnnotation:(MKPointAnnotation *)annotation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    [[LocationController sharedInstance] findLocationMatchingLocation:location];

    self.locationInfoBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
//    UIView *locationInfoBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, locationInfoBackgroundView.frame.size.width, 300)];
    self.locationInfoBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:self.locationInfoBackgroundView];

    [UIView animateWithDuration:.25f animations:^{
        self.locationInfoBackgroundView.frame = self.view.bounds;
    }];
    
    int backgroundViewWidth = self.locationInfoBackgroundView.frame.size.width;
    int locationInfoViewWidth = backgroundViewWidth - 40;
    
    UIView *locationInfoView = [[UIView alloc] initWithFrame:CGRectMake((backgroundViewWidth / 2) - locationInfoViewWidth/2 , 125,  locationInfoViewWidth, 282)];
//    UIView *locationInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 300)];
    locationInfoView.backgroundColor = [UIColor colorWithWhite:.50 alpha:.75];
//    locationInfoView.backgroundColor = [UIColor airvolutionRed];
    [self.locationInfoBackgroundView addSubview:locationInfoView];
    
//    self.tableView = [[UITableView alloc] initWithFrame:locationInfoView.bounds style:UITableViewStyleGrouped];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, locationInfoView.frame.size.width-20, locationInfoView.frame.size.height-20)];

    [locationInfoView addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    self.datasource = [MapTableViewDataSource new];
    self.tableView.dataSource = self.datasource;
    [self.datasource registerTableView:self.tableView];
    self.tableView.delegate = self;
    
}


#pragma mark - tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowHeight;
    switch (indexPath.row) {
        case 0:
            rowHeight = 60;
            break;
            
        case 1:
//            UITableViewCell *notesCell = (tableView cell);
//            if (tableView cellForRowAtIndexPath:indexPath) {
                rowHeight = 20;
//            }
            break;
            
        case 2:
            rowHeight = 90;
            break;
        default:// directions, backToMap
            rowHeight = 40;
            break;
    }
    return rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 2:
            [self.locationInfoBackgroundView removeFromSuperview];
            break;
        case 3: //directions
            [self directionsButtonPressedWithAnnotation:self.selectedAnnotation];
            break;
        case 4: //go back to map
            [self.locationInfoBackgroundView removeFromSuperview];
            break;
        default:
            break;
    }
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL command;
    switch (indexPath.row) {
        case 0:
            return NO;
            break;
            
        default: return YES;
            break;
    }
    return command;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
