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

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate>

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

@property (nonatomic, strong) UIView *loadingView;
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
//    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setTitle:@"airvolution"];
    [self registerForNotifications];
    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:5.0];
    
    
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
    
//    self.dropPinButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 400, 45, 55)];
////    self.dropPinButton.backgroundColor = [UIColor grayColor];
//    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
//    [self.view addSubview:self.dropPinButton];
//    [self.dropPinButton addTarget:self action:@selector(dropPinAtCurrentLocation) forControlEvents:UIControlEventTouchUpInside];

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.dropPinButton = [[UIButton alloc] initWithFrame:view.frame];
    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.dropPinButton addTarget:self action:@selector(dropPinAtCenterOfMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.dropPinButton];
    UIBarButtonItem *pinDrop = [[UIBarButtonItem alloc] initWithCustomView:view];
    [self.navigationItem setRightBarButtonItem:pinDrop];
    
    
    UILongPressGestureRecognizer *dropPinPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinWithGestureRecognizer:)];
    dropPinPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:dropPinPress];
    
    
    MKUserTrackingBarButtonItem *barButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, -30, 285, 30)];
    [self showSearchBar];
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
//    [self.navigationItem setLeftBarButtonItem:searchButton];

}

#pragma mapSearch

- (void)showSearchBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar.frame = CGRectMake(20, 70, 285, 30);
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//        self.searchBar.backgroundColor = [UIColor blackColor];
//            self.searchBar.barTintColor = [UIColor whiteColor];
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

#pragma notification observer
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notLoggedIniCloudAlert) name:NotLoggedIniCloudNotificationKey object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMapWithSavedLocations) name:allLocationsFetchedNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitFailedAlert) name:newLocationSaveFailedNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitSuccess) name:newLocationSavedNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMapAnnotations) name:locationDeletedNotificationKey object:nil];

    
}

- (void)notLoggedIniCloudAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Required" message:@"Please log in to your iCloud account in iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
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
    [self presentViewController:alert animated:YES completion:nil];

    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma geocode location

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

#pragma annotations
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


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *pinView;
//    if ([annotation isKindOfClass:[MKPlacemark class] ]) {
    if ([self.searchedAnnotations containsObject:annotation]) {
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"placemarksPin"];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"placemarksPin"];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
    } else if ([[annotation title] isEqualToString:droppedPinTitle]) {
        if (pinView == nil) {
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"droppedPin"];
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droppedPin"];
            pinView.draggable = YES;
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            
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
    } else {
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"savedPin"];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"savedPin"];
        pinView.pinColor = MKPinAnnotationColorPurple;
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
        NSLog(@"add button clicked");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Location" message:[NSString stringWithFormat:@"Address: %@, \n %@", self.selectedPinAddress[0], self.selectedPinAddress[1]]  preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"location name";
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self removeFromParentViewController];
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alertController.textFields[0];
            if ([textField.text isEqualToString:@""]) {
                NSLog(@"no text no save");
            } else {
                
                self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                self.indicatorView.frame = self.view.bounds;
                self.indicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
                self.indicatorView.center = CGPointMake(160, 240);
                [self.loadingView addSubview:self.indicatorView];
                [self.indicatorView startAnimating];
                [self.view addSubview:self.indicatorView];
                
//            [[LocationController sharedInstance]saveLocationWithName:textField.text location:self.location addressArray:self.selectedPinAddress];
                [[LocationController sharedInstance] saveLocationWithName:textField.text location:self.location streetAddress:self.selectedPinStreet city:self.selectedPinCity state:self.selectedPinState zip:self.selectedPinZip country:self.selectedPinCountry];
                
            }
        }];
        [alertController addAction:saveAction];
        
        [self presentViewController:alertController animated:YES completion:nil];

        
    } else if ([control tag] == 1) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
        
    } else if ([control tag] == 3) {
        //directions
        [self directionsButtonPressedWithAnnotation:self.selectedAnnotation];
        
    } else if ([control tag] == 4) {
        //location info show animate in a view with tableview of  name, complete address, directions.
//        MKPointAnnotation *annotation = view.annotation;
        [self locationMoreInfoPressedForAnnotaiton:self.selectedAnnotation];
    }
    
}

-(void)directionsButtonPressedWithAnnotation:(MKPointAnnotation *)annotation {
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

-(void)goToMapsAppForDirectionsToAnnotation:(MKPointAnnotation *)annotation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    NSDictionary *dictionary = [[LocationController sharedInstance]addressDictionaryForLocationWithCLLocation:location];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:dictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 10000, 10000);
    [MKMapItem openMapsWithItems:@[mapItem] launchOptions:[NSDictionary dictionaryWithObjectsAndKeys: [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey, [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
}

-(void)locationMoreInfoPressedForAnnotaiton:(MKPointAnnotation *)annotation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    [[LocationController sharedInstance] findLocationMatchingLocation:location];

    self.locationInfoBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
//    UIView *locationInfoBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, locationInfoBackgroundView.frame.size.width, 300)];
    self.locationInfoBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.50];
    [self.view addSubview:self.locationInfoBackgroundView];
    
    UIView *locationInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, self.locationInfoBackgroundView.frame.size.width, 230)];
//    UIView *locationInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 125, self.view.frame.size.width, 300)];
//    locationInfoView.backgroundColor = [UIColor colorWithWhite:.50 alpha:.75];
    [self.locationInfoBackgroundView addSubview:locationInfoView];
    
//    self.tableView = [[UITableView alloc] initWithFrame:locationInfoView.bounds style:UITableViewStyleGrouped];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, locationInfoView.frame.size.width, locationInfoView.frame.size.height)];

    [locationInfoView addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    self.datasource = [MapTableViewDataSource new];
    self.tableView.dataSource = self.datasource;
    [self.datasource registerTableView:self.tableView];
    self.tableView.delegate = self;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float rowHeight;
    switch (indexPath.row) {
        case 0:
            rowHeight = 60;
            break;
        case 1:
            rowHeight = 90;
            break;
        default:
            rowHeight = 40;
            break;
    }
    return rowHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 2: //directions
            [self directionsButtonPressedWithAnnotation:self.selectedAnnotation];
            break;
        case 3: //go back to map
            [self.locationInfoBackgroundView removeFromSuperview];
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
